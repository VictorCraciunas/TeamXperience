import {beforeEach, describe, test} from "node:test";
import * as assert from "node:assert/strict";
import {Firestore, Timestamp} from "firebase-admin/firestore";
import {callerOf} from "../teams/callables";
import {checkTeamName} from "../teams/check_team_name";
import {createCrew} from "../teams/create_crew";
import {joinTeam} from "../teams/join_team";
import {previewInvite} from "../teams/preview_invite";
import {registerTeam, RegisterInput} from "../teams/register_team";
import {InboxItem} from "../notifications/inbox";
import {shortDate} from "../teams/shared";
import {clearDb, emulatorDb, reasonOf, retryLostRace} from "./helpers";

const NOW = new Date("2026-11-08T10:00:00Z");
const DAY = 24 * 60 * 60 * 1000;
const inDays = (days: number) => Timestamp.fromDate(new Date(NOW.getTime() + days * DAY));

let db: Firestore;
const noNotify = async () => {};

async function seedUser(uid: string, firstName: string, lastName: string): Promise<void> {
  await db.collection("users").doc(uid).set({uid, firstName, lastName, email: `${uid}@x.ro`, role: "USER"});
}

async function seedEvent(id = "e1", extra: Record<string, unknown> = {}): Promise<void> {
  await db.collection("events").doc(id).set({
    eventId: id,
    name: "Harta",
    dateEvent: inDays(10),
    dateStartEnrollment: inDays(-5),
    dateDeadlineEnrollment: inDays(5),
    teamSizeMin: 2,
    teamSizeMax: 4,
    maxTeams: 3,
    ...extra,
  });
}

const input = (extra: RegisterInput = {}): RegisterInput => ({
  eventId: "e1",
  name: "Vulpile",
  size: 4,
  phone: " 0722 ",
  rulesAccepted: true,
  photoConsent: true,
  ...extra,
});

const register = (uid: string, extra: RegisterInput = {}) => registerTeam(db, uid, input(extra), NOW);

const team = async (name = "Vulpile", event = "e1") =>
  (await db.collection("events").doc(event).collection("teams").doc(name).get()).data();

const userOf = async (uid: string) => (await db.collection("users").doc(uid).get()).data();

async function refused(call: Promise<unknown>, reason: string): Promise<void> {
  await assert.rejects(call, (error) => {
    assert.equal(reasonOf(error), reason);
    return true;
  });
}

test("shortDate is the day in Romania", () => {
  assert.equal(shortDate(new Date("2026-11-14T22:30:00Z")), "15 nov");
  assert.equal(shortDate(new Date("2027-01-03T10:00:00Z")), "3 ian");
});

describe("team functions", () => {
  beforeEach(async () => {
    db = emulatorDb();
    await clearDb();
    await seedUser("u1", "Victor", "Crăciunaș");
    await seedUser("u2", "Ana", "Pop");
    await seedUser("u3", "Dan", "Ion");
    await seedUser("u4", "Ema", "Rus");
    await seedUser("u5", "Ion", "Lup");
    await seedEvent();
  });

  test("a signed-out call is refused", () => {
    assert.throws(() => callerOf({auth: undefined}), (error) => {
      assert.equal(reasonOf(error), "notSignedIn");
      assert.equal((error as {code?: string}).code, "unauthenticated");
      return true;
    });
  });

  describe("registerTeam", () => {
    test("makes the team, the crew and the code", async () => {
      const result = await register("u1");
      assert.match(result.inviteCode, /^VLP\d{3}$/);
      assert.deepEqual(result.skippedUids, []);
      assert.equal(result.teamName, "Vulpile");

      const made = await team();
      assert.ok(made);
      assert.deepEqual(made.userIds, ["u1"]);
      assert.equal(made.members[0].initials, "VC");
      assert.equal(made.members[0].displayName, "Victor Crăciunaș");
      assert.equal(made.teamMembers, "Victor Crăciunaș");
      assert.equal(made.nameKey, "vulpile");
      assert.equal(made.inviteCode, undefined, "anyone signed in can read a team");
      assert.equal(made.captainUid, "u1");
      assert.equal(made.captainName, "Victor Crăciunaș");
      assert.equal(made.captainEmail, "u1@x.ro");
      assert.equal(made.phoneNumber, "0722");
      assert.equal(made.numberOfMembers, 4);
      assert.equal(made.photoConsent, true);
      assert.equal(made.missionProgress, 0);
      assert.equal(made.hasStarted, false);
      assert.ok(made.rulesAcceptedAt);

      assert.deepEqual((await userOf("u1"))?.registeredEventIds, ["e1"]);
      const crew = (await db.collection("crews").doc(result.crewId).get()).data();
      assert.equal(crew?.captainUid, "u1");
      assert.deepEqual(crew?.memberUids, ["u1"]);
      assert.deepEqual(crew?.teams, [{eventId: "e1", teamName: "Vulpile"}]);
      assert.equal((await db.collection("inviteCodes").doc(result.inviteCode).get()).data()?.crewId, result.crewId);
    });

    test("cleans the name it is given", async () => {
      const result = await register("u1", {name: "  Lupii   de  Cetate "});
      assert.equal(result.teamName, "Lupii de Cetate");
      assert.ok(await team("Lupii de Cetate"));
    });

    test("the same name in other capitals is taken", async () => {
      await register("u1");
      await refused(register("u2", {name: "VULPILE "}), "nameTaken");
    });

    test("a name made before nameKey existed still counts", async () => {
      await db.collection("events").doc("e1").collection("teams").doc("Vechi").set({name: "Vechi", userIds: []});
      await refused(register("u1", {name: "vechi"}), "nameTaken");
    });

    test("you are in one team per event", async () => {
      await register("u1");
      await assert.rejects(register("u1", {name: "Lupii"}), (error) => {
        assert.equal(reasonOf(error), "alreadyInTeam");
        assert.equal((error as {details: {teamName: string}}).details.teamName, "Vulpile");
        return true;
      });
    });

    test("every refusal", async () => {
      await refused(register("u1", {size: 5}), "sizeInvalid");
      await refused(register("u1", {size: 1}), "sizeInvalid");
      await refused(register("u1", {size: 2.5}), "sizeInvalid");
      await refused(register("u1", {rulesAccepted: false}), "rulesNotAccepted");
      await refused(register("u1", {name: "A"}), "nameInvalid");
      await refused(register("u1", {name: "a/b"}), "nameInvalid");
      await refused(register("u1", {eventId: "nope"}), "eventNotFound");
      await refused(register("u1", {eventId: ""}), "eventNotFound");
    });

    test("a draft is not there", async () => {
      await seedEvent("draft", {status: "draft"});
      await refused(register("u1", {eventId: "draft"}), "eventNotFound");
    });

    test("enrolment: before it opens, after the deadline, after the start", async () => {
      await seedEvent("later", {dateStartEnrollment: inDays(1)});
      await refused(register("u1", {eventId: "later"}), "enrolmentClosed");
      await seedEvent("past", {dateDeadlineEnrollment: inDays(-1)});
      await refused(register("u1", {eventId: "past"}), "enrolmentClosed");
      await seedEvent("started", {dateEvent: inDays(-1)});
      await refused(register("u1", {eventId: "started"}), "enrolmentClosed");
    });

    test("a deadline at midnight in Romania lasts that whole day", async () => {
      // 8 November 00:00 in Bucharest is 7 November 22:00 UTC.
      const midnight = Timestamp.fromDate(new Date("2026-11-07T22:00:00Z"));
      await seedEvent("today", {dateDeadlineEnrollment: midnight});
      const result = await register("u1", {eventId: "today"});
      assert.equal(result.teamName, "Vulpile");
    });

    test("no more than maxTeams", async () => {
      await seedEvent("small", {maxTeams: 1});
      await register("u1", {eventId: "small"});
      await refused(register("u2", {eventId: "small", name: "Lupii"}), "eventFull");
    });

    test("two captains with one name at once: one gets it", async () => {
      const results = await Promise.allSettled([
        retryLostRace(() => register("u1")),
        retryLostRace(() => register("u2", {name: "vulpile"})),
      ]);
      const fulfilled = results.filter((r) => r.status === "fulfilled");
      const rejected = results.filter((r): r is PromiseRejectedResult => r.status === "rejected");
      assert.equal(fulfilled.length, 1);
      assert.equal(reasonOf(rejected[0].reason), "nameTaken");
    });

    describe("with a crew", () => {
      async function crewOfTwo(): Promise<string> {
        const {crewId, inviteCode} = await createCrew(db, "u1", {name: "Vulpile"});
        await joinTeam(db, "u2", {code: inviteCode}, {now: NOW, notify: noNotify});
        return crewId;
      }

      test("its members come along, and the code stays", async () => {
        const crewId = await crewOfTwo();
        const crew = (await db.collection("crews").doc(crewId).get()).data();
        const result = await register("u1", {crewId});
        assert.equal(result.inviteCode, crew?.inviteCode);
        assert.deepEqual((await team())?.userIds, ["u1", "u2"]);
        assert.deepEqual((await userOf("u2"))?.registeredEventIds, ["e1"]);
        const after = (await db.collection("crews").doc(crewId).get()).data();
        assert.deepEqual(after?.teams, [{eventId: "e1", teamName: "Vulpile"}]);
      });

      test("signed up under a new name, the crew takes the name; earlier teams keep theirs", async () => {
        const crewId = await crewOfTwo();
        await register("u1", {crewId});
        await seedEvent("other");
        await register("u1", {crewId, eventId: "other", name: "Bufnițele"});
        const crew = (await db.collection("crews").doc(crewId).get()).data();
        assert.equal(crew?.name, "Bufnițele");
        assert.deepEqual(crew?.teams, [
          {eventId: "e1", teamName: "Vulpile"},
          {eventId: "other", teamName: "Bufnițele"},
        ]);
        assert.equal((await team("Vulpile"))?.name, "Vulpile");
      });

      test("a refused sign-up leaves the crew's name", async () => {
        const crewId = await crewOfTwo();
        await register("u1", {crewId});
        await refused(register("u1", {crewId, name: "Alt nume"}), "alreadyInTeam");
        await db.collection("events").doc("e1").collection("teams").doc("Vulpile").update({userIds: ["u3"]});
        await refused(register("u1", {crewId, name: "Alt nume"}), "crewAlreadyRegistered");
        assert.equal((await db.collection("crews").doc(crewId).get()).data()?.name, "Vulpile");
      });

      test("signing a crew up tells the other players, not the captain", async () => {
        const crewId = await crewOfTwo();
        const told: Array<{uids: string[]; item: InboxItem}> = [];
        await registerTeam(db, "u1", input({crewId}), NOW, async (uids, item) => {
          told.push({uids, item});
        });
        assert.deepEqual(told, [{
          uids: ["u2"],
          item: {kind: "team", title: "Echipa ta s-a înscris", body: "Vulpile merge la Harta, pe 18 nov", eventId: "e1"},
        }]);
      });

      test("by default the others get it in their list", async () => {
        const crewId = await crewOfTwo();
        await register("u1", {crewId});
        const list = (uid: string) => db.collection("users").doc(uid).collection("notifications").get();
        assert.equal((await list("u2")).size, 1);
        assert.equal((await list("u1")).size, 0);
      });

      test("a failure telling them does not undo the sign-up", async () => {
        const crewId = await crewOfTwo();
        await registerTeam(db, "u1", input({crewId}), NOW, async () => {
          throw new Error("offline");
        });
        assert.deepEqual((await team())?.userIds, ["u1", "u2"]);
      });

      test("not twice in one event; only the captain; only if they fit", async () => {
        const crewId = await crewOfTwo();
        await refused(register("u2", {crewId, name: "Alt nume"}), "notCaptain");
        await refused(register("u1", {crewId, size: 2, eventId: "nope"}), "eventNotFound");
        await seedEvent("tiny", {teamSizeMin: 1, teamSizeMax: 4});
        await refused(register("u1", {crewId, size: 1, eventId: "tiny"}), "sizeInvalid");
        await register("u1", {crewId});
        await seedEvent("other");
        await register("u1", {crewId, eventId: "other", name: "Vulpile"});
        const crew = (await db.collection("crews").doc(crewId).get()).data();
        assert.equal(crew?.teams.length, 2);
      });

      test("a crew registered already in this event is refused", async () => {
        const crewId = await crewOfTwo();
        await register("u1", {crewId});
        await db.collection("events").doc("e1").collection("teams").doc("Vulpile").update({userIds: ["u2"]});
        await refused(register("u1", {crewId, name: "Alt nume"}), "crewAlreadyRegistered");
      });

      test("a member already in another team here is left out and reported", async () => {
        const crewId = await crewOfTwo();
        await register("u2", {name: "Lupii"});
        const result = await register("u1", {crewId});
        assert.deepEqual(result.skippedUids, ["u2"]);
        assert.deepEqual((await team())?.userIds, ["u1"]);
      });
    });
  });

  describe("checkTeamName", () => {
    test("free, taken and invalid", async () => {
      await register("u1");
      assert.deepEqual(await checkTeamName(db, "u2", {eventId: "e1", name: "vulpile "}), {free: false});
      assert.deepEqual(await checkTeamName(db, "u2", {eventId: "e1", name: "Lupii"}), {free: true});
      assert.deepEqual(await checkTeamName(db, "u2", {eventId: "e1", name: "A"}), {free: false, problem: "short"});
    });
  });

  describe("createCrew", () => {
    test("the data consent is kept when given", async () => {
      await register("u1", {dataAccepted: true});
      assert.ok((await team())?.dataAcceptedAt);
      await register("u2", {name: "Lupii"});
      assert.equal((await team("Lupii"))?.dataAcceptedAt, undefined);
    });

    test("a captain alone tells nobody", async () => {
      let calls = 0;
      await registerTeam(db, "u1", input(), NOW, async () => {
        calls++;
      });
      assert.equal(calls, 0);
    });

    test("a crew of one, with a code", async () => {
      const {crewId, inviteCode} = await createCrew(db, "u1", {name: " Bufnițele "});
      assert.match(inviteCode, /^[A-Z]{3}\d{3}$/);
      const crew = (await db.collection("crews").doc(crewId).get()).data();
      assert.equal(crew?.name, "Bufnițele");
      assert.deepEqual(crew?.memberUids, ["u1"]);
      assert.deepEqual(crew?.stats, {games: 0, wins: 0, distanceMeters: 0});
    });

    test("a bad name is refused", async () => {
      await refused(createCrew(db, "u1", {name: "x"}), "nameInvalid");
    });
  });

  describe("previewInvite", () => {
    test("the team's people and the slot, with the code typed loosely", async () => {
      const {inviteCode} = await register("u1");
      const loose = ` ${inviteCode.slice(0, 3).toLowerCase()}-${inviteCode.slice(3)} `;
      const preview = await previewInvite(db, "u2", {code: loose}, NOW);
      assert.equal(preview.crewName, "Vulpile");
      assert.equal(preview.captainName, "Victor Crăciunaș");
      assert.deepEqual(preview.members.map((m) => m.uid), ["u1"]);
      assert.equal(preview.alreadyMember, false);
      assert.equal(preview.event?.eventId, "e1");
      assert.equal(preview.event?.teamName, "Vulpile");
      assert.equal(preview.event?.size, 4);
      assert.equal(preview.event?.count, 1);
      assert.equal(preview.event?.dateEvent, inDays(10).toDate().toISOString());
    });

    test("it writes nothing, and knows a member", async () => {
      const {inviteCode} = await register("u1");
      const preview = await previewInvite(db, "u1", {code: inviteCode}, NOW);
      assert.equal(preview.alreadyMember, true);
      assert.deepEqual((await team())?.userIds, ["u1"]);
    });

    test("the soonest event that is not over", async () => {
      const {crewId, inviteCode} = await register("u1");
      await seedEvent("sooner", {dateEvent: inDays(3), dateDeadlineEnrollment: inDays(2)});
      await register("u1", {crewId, eventId: "sooner", name: "Vulpile"});
      await seedEvent("done", {dateEvent: inDays(4), isStopped: true, dateDeadlineEnrollment: inDays(2)});
      await register("u1", {crewId, eventId: "done", name: "Vulpile"});
      const preview = await previewInvite(db, "u2", {code: inviteCode}, NOW);
      assert.equal(preview.event?.eventId, "sooner");
    });

    test("a crew with no team has no event, and shows the crew's people", async () => {
      const {inviteCode} = await createCrew(db, "u1", {name: "Vulpile"});
      const preview = await previewInvite(db, "u2", {code: inviteCode}, NOW);
      assert.equal(preview.event, undefined);
      assert.deepEqual(preview.members.map((m) => m.uid), ["u1"]);
    });

    test("an unknown or malformed code", async () => {
      await refused(previewInvite(db, "u2", {code: "ZZZ999"}, NOW), "codeUnknown");
      await refused(previewInvite(db, "u2", {code: "nope"}, NOW), "codeUnknown");
      await refused(previewInvite(db, "u2", {}, NOW), "codeUnknown");
    });
  });

  describe("joinTeam", () => {
    const join = (uid: string, code: string, notify = noNotify as (a: string, b: string, c: string) => Promise<void>) =>
      joinTeam(db, uid, {code}, {now: NOW, notify});

    test("into the crew and the team, and the captain hears", async () => {
      const {crewId, inviteCode} = await register("u1");
      const heard: string[] = [];
      const result = await join("u2", inviteCode, async (captain, name, crew) => {
        heard.push(`${captain} ${name} ${crew}`);
      });
      assert.deepEqual(result, {crewId, eventIds: ["e1"]});
      const made = await team();
      assert.deepEqual(made?.userIds, ["u1", "u2"]);
      assert.equal(made?.teamMembers, "Victor Crăciunaș, Ana Pop");
      assert.deepEqual((await userOf("u2"))?.registeredEventIds, ["e1"]);
      const crew = (await db.collection("crews").doc(crewId).get()).data();
      assert.deepEqual(crew?.memberUids, ["u1", "u2"]);
      assert.equal(crew?.members[1].initials, "AP");
      assert.deepEqual(heard, ["u1 Ana Pop Vulpile"]);
    });

    test("joining again returns the events, nothing changes, nobody is told", async () => {
      const {crewId, inviteCode} = await register("u1");
      await join("u2", inviteCode);
      const heard: string[] = [];
      const again = await join("u2", inviteCode, async (a) => {
        heard.push(a);
      });
      assert.deepEqual(again, {crewId, eventIds: ["e1"]});
      assert.deepEqual((await team())?.userIds, ["u1", "u2"]);
      assert.deepEqual(heard, []);
    });

    test("a crew with no team: just the crew", async () => {
      const {crewId, inviteCode} = await createCrew(db, "u1", {name: "Vulpile"});
      assert.deepEqual(await join("u2", inviteCode), {crewId, eventIds: []});
    });

    test("an unknown code", async () => {
      await refused(join("u2", "ZZZ999"), "codeUnknown");
    });

    test("a full team refuses, and nothing changes", async () => {
      const {crewId, inviteCode} = await register("u1", {size: 2});
      await join("u2", inviteCode);
      await refused(join("u3", inviteCode), "teamFull");
      const crew = (await db.collection("crews").doc(crewId).get()).data();
      assert.deepEqual(crew?.memberUids, ["u1", "u2"]);
    });

    test("two at once for the last place: exactly one gets in", async () => {
      const {inviteCode} = await register("u1");
      await join("u2", inviteCode);
      await join("u3", inviteCode);
      const results = await Promise.allSettled([
        retryLostRace(() => join("u4", inviteCode)),
        retryLostRace(() => join("u5", inviteCode)),
      ]);
      const rejected = results.filter((r): r is PromiseRejectedResult => r.status === "rejected");
      assert.equal(rejected.length, 1);
      assert.equal(reasonOf(rejected[0].reason), "teamFull");
      assert.equal((await team())?.userIds.length, 4);
    });

    test("already in another team of the next event: refused with its name", async () => {
      const {crewId, inviteCode} = await register("u1");
      await register("u3", {name: "Lupii"});
      await assert.rejects(join("u3", inviteCode), (error) => {
        assert.equal(reasonOf(error), "alreadyInTeam");
        assert.equal((error as {details: {teamName: string}}).details.teamName, "Lupii");
        return true;
      });
      const crew = (await db.collection("crews").doc(crewId).get()).data();
      assert.deepEqual(crew?.memberUids, ["u1"]);
    });

    test("a later event that cannot take them is just skipped", async () => {
      const {crewId, inviteCode} = await register("u1");
      await seedEvent("later", {dateEvent: inDays(20), dateDeadlineEnrollment: inDays(15)});
      await register("u1", {crewId, eventId: "later", name: "Vulpile"});
      await register("u3", {eventId: "later", name: "Lupii"});
      const result = await join("u3", inviteCode);
      assert.deepEqual(result.eventIds, ["e1"]);
    });

    test("an event that is over is left alone", async () => {
      const {crewId, inviteCode} = await register("u1");
      await db.collection("events").doc("e1").update({isStopped: true});
      assert.deepEqual(await join("u2", inviteCode), {crewId, eventIds: []});
      assert.deepEqual((await team())?.userIds, ["u1"]);
    });
  });
});
