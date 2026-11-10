import {beforeEach, describe, test} from "node:test";
import * as assert from "node:assert/strict";
import {Firestore} from "firebase-admin/firestore";
import {addToInboxes, chatInboxItem} from "../notifications/inbox";
import {notifyCaptain} from "../teams/notify";
import {clearDb, emulatorDb} from "./helpers";

let db: Firestore;

async function inbox(uid: string) {
  const snap = await db.collection("users").doc(uid).collection("notifications").get();
  return snap.docs.map((doc) => doc.data());
}

describe("the notification list", () => {
  beforeEach(async () => {
    db = emulatorDb();
    await clearDb();
  });

  test("one unread entry per player, with the server's time", async () => {
    await addToInboxes(db, ["u1", "u2"], {kind: "announcement", title: "Start", body: "La 18", eventId: "e1"});
    for (const uid of ["u1", "u2"]) {
      const [entry] = await inbox(uid);
      assert.equal(entry.kind, "announcement");
      assert.equal(entry.title, "Start");
      assert.equal(entry.body, "La 18");
      assert.equal(entry.eventId, "e1");
      assert.equal(entry.read, false);
      assert.ok(entry.createdAt);
      assert.equal("teamName" in entry, false);
    }
  });

  test("skips empty ids", async () => {
    await addToInboxes(db, ["", "u1", "a/b"], {kind: "team", title: "T", body: "B"});
    assert.equal((await inbox("u1")).length, 1);
  });

  test("writes more than one batch", async () => {
    const uids = Array.from({length: 450}, (_, i) => `p${i}`);
    await addToInboxes(db, uids, {kind: "announcement", title: "T", body: "B"});
    assert.equal((await inbox("p0")).length, 1);
    assert.equal((await inbox("p449")).length, 1);
  });

  test("a list that cannot be written never throws", async () => {
    const broken = {batch: () => {
      throw new Error("offline");
    }} as unknown as Firestore;
    await addToInboxes(broken, ["u1"], {kind: "team", title: "T", body: "B"});
  });

  test("a crew's captain hears about a new member in the list, even when the push fails", async () => {
    await notifyCaptain("cap", "Ana Pop", "Vulpile", async () => {
      throw new Error("no token");
    });
    const [entry] = await inbox("cap");
    assert.deepEqual(
      {kind: entry.kind, title: entry.title, body: entry.body},
      {kind: "team", title: "Echipa ta crește", body: "Ana Pop a intrat în Vulpile"},
    );
  });
});

test("a chat entry: cut at 100, and a picture has its own line", () => {
  assert.equal(chatInboxItem("e", "T", "x".repeat(150)).body.length, 103);
  assert.equal(chatInboxItem("e", "T", undefined).body, "A trimis o poză.");
  assert.equal(chatInboxItem("e", "T", "   ").body, "A trimis o poză.");
  assert.deepEqual(chatInboxItem("e", "T", "Salut"), {
    kind: "chat",
    title: "Mesaj de la organizator",
    body: "Salut",
    eventId: "e",
    teamName: "T",
  });
});
