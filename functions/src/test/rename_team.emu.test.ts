import {beforeEach, describe, test} from "node:test";
import * as assert from "node:assert/strict";
import {Firestore, Timestamp} from "firebase-admin/firestore";
import {registerTeam} from "../teams/register_team";
import {renameTeam} from "../teams/rename_team";
import {clearDb, emulatorDb, reasonOf} from "./helpers";

const NOW = new Date("2026-11-08T10:00:00Z");
const DAY = 24 * 60 * 60 * 1000;
const inDays = (days: number) => Timestamp.fromDate(new Date(NOW.getTime() + days * DAY));

let db: Firestore;
const teams = () => db.collection("events").doc("e1").collection("teams");

async function seed(): Promise<string> {
  for (const [uid, first] of [["u1", "Victor"], ["u2", "Ana"]]) {
    await db.collection("users").doc(uid).set({uid, firstName: first, lastName: "Pop", email: `${uid}@x.ro`, role: "USER"});
  }
  await db.collection("events").doc("e1").set({
    eventId: "e1", name: "Harta", dateEvent: inDays(10), dateStartEnrollment: inDays(-5),
    dateDeadlineEnrollment: inDays(5), teamSizeMin: 2, teamSizeMax: 4,
  });
  const made = await registerTeam(db, "u1", {
    eventId: "e1", name: "Vulpile", size: 4, phone: "0722", rulesAccepted: true, dataAccepted: true, photoConsent: true,
  }, NOW, async () => {});
  await teams().doc("Vulpile").collection("messages").doc("m1").set({text: "Salut", sender: "ADMIN"});
  return made.crewId;
}

const rename = (uid: string, newName: string, now = NOW) =>
  renameTeam(db, uid, {eventId: "e1", teamName: "Vulpile", newName}, now);

async function refused(call: Promise<unknown>, reason: string): Promise<void> {
  await assert.rejects(call, (error) => {
    assert.equal(reasonOf(error), reason);
    return true;
  });
}

describe("renameTeam", () => {
  let crewId: string;
  beforeEach(async () => {
    db = emulatorDb();
    await clearDb();
    crewId = await seed();
  });

  test("the captain renames the team, its chat and its crew together", async () => {
    assert.deepEqual(await rename("u1", "  Lupii  "), {teamName: "Lupii"});

    assert.equal((await teams().doc("Vulpile").get()).exists, false);
    const renamed = (await teams().doc("Lupii").get()).data();
    assert.equal(renamed?.name, "Lupii");
    assert.equal(renamed?.nameKey, "lupii");
    assert.equal(renamed?.phoneNumber, "0722");
    assert.deepEqual(renamed?.userIds, ["u1"]);

    const moved = await teams().doc("Lupii").collection("messages").get();
    assert.deepEqual(moved.docs.map((m) => [m.id, m.data().text, m.data().moved]), [["m1", "Salut", true]]);
    assert.equal((await teams().doc("Vulpile").collection("messages").get()).size, 0);

    const crew = (await db.collection("crews").doc(crewId).get()).data();
    assert.equal(crew?.name, "Lupii");
    assert.deepEqual(crew?.teams, [{eventId: "e1", teamName: "Lupii"}]);
  });

  test("only the captain may rename", async () => {
    await refused(rename("u2", "Lupii"), "notCaptain");
  });

  test("not once the event has started, or the team has", async () => {
    await refused(rename("u1", "Lupii", new Date(NOW.getTime() + 10 * DAY)), "gameStarted");
    await teams().doc("Vulpile").update({hasStarted: true});
    await refused(rename("u1", "Lupii"), "gameStarted");
  });

  test("the new name must be valid and free at the event", async () => {
    await refused(rename("u1", "x"), "nameInvalid");
    await teams().doc("Ursii").set({name: "Ursii", nameKey: "ursii"});
    await refused(rename("u1", "URSII"), "nameTaken");
  });

  test("the same name changes nothing; a new spelling of it is allowed", async () => {
    assert.deepEqual(await rename("u1", "Vulpile"), {teamName: "Vulpile"});
    assert.equal((await teams().doc("Vulpile").collection("messages").get()).size, 1);
    assert.deepEqual(await rename("u1", "VULPILE"), {teamName: "VULPILE"});
    assert.equal((await teams().doc("VULPILE").get()).data()?.name, "VULPILE");
  });

  test("a rename retried after it went through answers with the new name", async () => {
    await rename("u1", "Lupii");
    assert.deepEqual(await rename("u1", "Lupii"), {teamName: "Lupii"});
    await refused(rename("u2", "Lupii"), "teamNotFound");
  });

  test("a team that does not exist", async () => {
    await refused(renameTeam(db, "u1", {eventId: "e1", teamName: "Nimeni", newName: "Lupii"}, NOW), "teamNotFound");
  });
});
