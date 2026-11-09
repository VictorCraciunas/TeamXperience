import {after, before, beforeEach, describe, test} from "node:test";
import {readFileSync} from "node:fs";
import {join} from "node:path";
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  RulesTestEnvironment,
} from "@firebase/rules-unit-testing";
import firebase from "firebase/compat/app";
import "firebase/compat/firestore";

const {FieldValue, Timestamp} = firebase.firestore;

const TEAM = "events/e1/teams/Vulpile";
const OLD_TEAM = "events/e1/teams/Vechi";
const MESSAGE = `${TEAM}/messages/m1`;

let env: RulesTestEnvironment;

const as = (uid: string) => env.authenticatedContext(uid, {email: `${uid}@x.ro`}).firestore();
const signedOut = () => env.unauthenticatedContext().firestore();

async function seed(): Promise<void> {
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    const stamp = Timestamp.fromDate(new Date("2026-11-01T10:00:00Z"));
    await db.doc("users/u1").set({role: "USER", firstName: "Ana", xp: 10, stats: {games: 1}, badges: []});
    await db.doc("users/u2").set({role: "USER", firstName: "Dan"});
    await db.doc("users/u3").set({role: "USER", firstName: "Ion"});
    await db.doc("users/admin").set({role: "ADMIN", firstName: "Org"});
    await db.doc("users/u1/memories/e0").set({eventName: "Vechi"});
    await db.doc("users/u1/notifications/n1").set({kind: "chat", title: "Salut", body: "B", read: false, createdAt: stamp});
    await db.doc("events/e1").set({name: "Harta", isStopped: false});
    await db.doc(TEAM).set({
      name: "Vulpile",
      userIds: ["u1", "u2"],
      captainUid: "u1",
      numberOfMembers: 4,
      phoneNumber: "0722",
      missionProgress: 1,
      puzzleNumber: 0,
      hasStarted: true,
      hasFinished: false,
      latitude: 0,
      longitude: 0,
      presence: {},
      walked: {u1: 100, u2: 50},
      attempts: {"1_0": 1},
      lockedUntil: {},
      hintsUsed: {"0_0": true},
      missionCompletedAt: {"0": stamp},
      photoApprovals: {
        "0_0_0": {status: "approved"},
        "1_0_0": {status: "pending", url: "a"},
      },
    });
    await db.doc(OLD_TEAM).set({name: "Vechi", userIds: ["u3"], phoneNumber: "1", missionProgress: 0});
    await db.doc(MESSAGE).set({sender: "USER", text: "Alo"});
    await db.doc("crews/c1").set({name: "Vulpile", memberUids: ["u1", "u2"], captainUid: "u1"});
    await db.doc("inviteCodes/VLP482").set({crewId: "c1"});
    await db.doc("stire/s1").set({title: "Veste"});
    await db.doc("seasons/2026-autumn").set({name: "Toamna 2026"});
    await db.doc("seasons/2026-autumn/standings/c1").set({points: 100});
  });
}

describe("firestore.rules", () => {
  before(async () => {
    env = await initializeTestEnvironment({
      projectId: "demo-teamxperience",
      firestore: {rules: readFileSync(join(__dirname, "../../../firestore.rules"), "utf8")},
    });
  });

  after(async () => {
    await env.cleanup();
  });

  beforeEach(async () => {
    await env.clearFirestore();
    await seed();
  });

  describe("reads", () => {
    test("a player reads events, teams, news and the season", async () => {
      const db = as("u3");
      await assertSucceeds(db.doc("events/e1").get());
      await assertSucceeds(db.doc(TEAM).get());
      await assertSucceeds(db.collection("events/e1/teams").get());
      await assertSucceeds(db.doc("stire/s1").get());
      await assertSucceeds(db.doc("seasons/2026-autumn/standings/c1").get());
    });

    test("signed out reads nothing", async () => {
      await assertFails(signedOut().doc("events/e1").get());
      await assertFails(signedOut().doc("users/u1").get());
    });

    test("an unknown collection is closed", async () => {
      await assertFails(as("admin").doc("secret/x").get());
    });
  });

  describe("users", () => {
    test("own doc: profile fields and the push token", async () => {
      await assertSucceeds(as("u1").doc("users/u1").update({firstName: "Anna", fcmToken: "t"}));
      await assertSucceeds(as("u1").doc("users/u1").update({registeredEventIds: FieldValue.arrayUnion("e1")}));
    });

    test("not someone else's", async () => {
      await assertFails(as("u2").doc("users/u1").update({firstName: "X"}));
    });

    for (const field of ["role", "xp", "level", "stats", "badges"]) {
      test(`not your own ${field}`, async () => {
        await assertFails(as("u1").doc("users/u1").update({[field]: field === "role" ? "ADMIN" : 9999}));
      });
    }

    test("notifications: your own, and only read may change, to true", async () => {
      const note = "users/u1/notifications/n1";
      await assertSucceeds(as("u1").doc(note).get());
      await assertSucceeds(as("u1").collection("users/u1/notifications").where("read", "==", false).get());
      await assertFails(as("u2").doc(note).get());
      await assertFails(as("admin").doc(note).update({read: true}));
      await assertFails(as("u1").doc(note).update({read: false}));
      await assertFails(as("u1").doc(note).update({title: "x"}));
      await assertFails(as("u1").doc(note).update({read: true, title: "x"}));
      await assertFails(as("u1").doc("users/u1/notifications/n2").set({title: "x", read: false}));
      await assertFails(as("u1").doc(note).delete());
      await assertSucceeds(as("u1").doc(note).update({read: true}));
    });

    const newUser = (uid: string, extra: Record<string, unknown> = {}) =>
      ({uid, role: "USER", email: `${uid}@x.ro`, ...extra});

    test("a new user is a USER with no xp, under their own uid and email", async () => {
      await assertSucceeds(as("u9").doc("users/u9").set(newUser("u9")));
      await assertSucceeds(as("u4").doc("users/u4").set(newUser("u4", {email: "U4@X.ro"})));
      await assertFails(as("u8").doc("users/u8").set(newUser("u8", {role: "ADMIN"})));
      await assertFails(as("u7").doc("users/u7").set(newUser("u7", {xp: 5000})));
      await assertFails(as("u6").doc("users/u5").set(newUser("u5")));
    });

    test("nobody signs up under another's uid or email", async () => {
      await assertFails(as("u8").doc("users/u8").set(newUser("u8", {uid: "u1"})));
      await assertFails(as("u8").doc("users/u8").set({role: "USER", email: "u8@x.ro"}));
      await assertFails(as("u8").doc("users/u8").set(newUser("u8", {email: "admin@x.ro"})));
    });

    test("your own uid and email cannot change", async () => {
      await assertFails(as("u1").doc("users/u1").update({uid: "u2"}));
      await assertFails(as("u1").doc("users/u1").update({email: "admin@x.ro"}));
    });

    test("an organiser may change a user (deleting a team removes its event)", async () => {
      await assertSucceeds(as("admin").doc("users/u1").update({registeredEventIds: []}));
    });

    test("memories: yours to read, nobody's to write", async () => {
      await assertSucceeds(as("u1").doc("users/u1/memories/e0").get());
      await assertFails(as("u2").doc("users/u1/memories/e0").get());
      await assertFails(as("u1").doc("users/u1/memories/e9").set({place: 1}));
      await assertFails(as("admin").doc("users/u1/memories/e9").set({place: 1}));
    });
  });

  describe("events", () => {
    test("an organiser writes, a player does not", async () => {
      await assertSucceeds(as("admin").doc("events/e2").set({name: "Nou"}));
      await assertSucceeds(as("admin").doc("events/e1").update({isStopped: true}));
      await assertFails(as("u1").doc("events/e2").set({name: "Nou"}));
      await assertFails(as("u1").doc("events/e1").update({isStopped: true}));
    });

    test("nobody sets resultsComputedAt, also an organiser", async () => {
      await assertFails(as("admin").doc("events/e1").update({resultsComputedAt: FieldValue.serverTimestamp()}));
      await assertFails(as("admin").doc("events/e3").set({resultsComputedAt: 1}));
    });

    test("saving an event that has results still works", async () => {
      await env.withSecurityRulesDisabled(async (context) => {
        await context.firestore().doc("events/e1").update({resultsComputedAt: 1});
      });
      await assertSucceeds(as("admin").doc("events/e1").set({name: "Harta"}));
    });

    test("feedback: only your own", async () => {
      await assertSucceeds(as("u1").doc("events/e1/feedback/u1").set({rating: 5, teamName: "Vulpile"}));
      await assertSucceeds(as("u1").doc("events/e1/feedback/u1").set({rating: 4, teamName: "Vulpile"}));
      await assertFails(as("u2").doc("events/e1/feedback/u1").set({rating: 1}));
    });
  });

  describe("a team", () => {
    const member = () => as("u2").doc(TEAM);

    test("nobody creates one from the app", async () => {
      await assertFails(as("u1").doc("events/e1/teams/Nou").set({name: "Nou", userIds: ["u1"]}));
      await assertFails(as("admin").doc("events/e1/teams/Nou").set({name: "Nou"}));
    });

    test("a non-member writes nothing", async () => {
      await assertFails(as("u3").doc(TEAM).update({latitude: 1}));
    });

    test("only an organiser deletes", async () => {
      await assertFails(as("u1").doc(TEAM).delete());
      await assertSucceeds(as("admin").doc(TEAM).delete());
    });

    test("location and puzzle number", async () => {
      await assertSucceeds(member().update({latitude: 45.7, longitude: 24.1}));
      await assertSucceeds(member().update({puzzleNumber: 2}));
    });

    for (const field of ["numberOfMembers", "userIds", "name", "captainUid", "place", "crewId", "inviteCode"]) {
      test(`a member cannot change ${field}`, async () => {
        await assertFails(member().update({[field]: 1}));
      });
    }

    test("progress moves one mission at a time, never back", async () => {
      await assertSucceeds(member().update({missionProgress: 2}));
      await assertFails(member().update({missionProgress: 1}));
      await assertFails(member().update({missionProgress: 9}));
    });

    test("a mission's time is set once", async () => {
      const now = FieldValue.serverTimestamp();
      await assertSucceeds(member().update({missionProgress: 2, "missionCompletedAt.1": now, puzzleNumber: 0}));
      await assertFails(member().update({"missionCompletedAt.1": now}));
      await assertFails(member().update({"missionCompletedAt.0": now}));
    });

    test("a mission's time is the server's, for the mission the team is on", async () => {
      const now = FieldValue.serverTimestamp();
      const old = Timestamp.fromDate(new Date("2020-01-01"));
      await assertFails(member().update({missionProgress: 2, "missionCompletedAt.1": old}));
      await assertFails(member().update({missionProgress: 2, "missionCompletedAt.99": now}));
      await assertFails(member().update({missionProgress: 2, "missionCompletedAt.2": now}));
      await assertFails(member().update({"missionCompletedAt.1": now, "missionCompletedAt.2": now}));
    });

    test("started and finished only go one way", async () => {
      await assertSucceeds(member().update({hasFinished: true}));
      await assertFails(member().update({hasFinished: false}));
      await assertFails(member().update({hasStarted: false}));
    });

    test("startedAt and finishedAt: once, with the server's time", async () => {
      const now = FieldValue.serverTimestamp();
      await assertFails(member().update({startedAt: Timestamp.fromDate(new Date("2020-01-01"))}));
      await assertFails(member().update({finishedAt: Timestamp.fromDate(new Date("2020-01-01"))}));
      await assertSucceeds(member().update({startedAt: now}));
      await assertFails(member().update({startedAt: now}));
      await assertSucceeds(member().update({finishedAt: now}));
      await assertFails(member().update({finishedAt: now}));
    });

    test("presence: your own, with the server's time", async () => {
      const now = FieldValue.serverTimestamp();
      await assertSucceeds(member().update({"presence.u2": now}));
      await assertFails(member().update({"presence.u1": now}));
      await assertFails(member().update({"presence.u2": Timestamp.fromDate(new Date("2020-01-01"))}));
    });

    test("walked: your own, only more", async () => {
      await assertSucceeds(member().update({"walked.u2": FieldValue.increment(10)}));
      await assertFails(member().update({"walked.u1": FieldValue.increment(10)}));
      await assertFails(member().update({"walked.u2": FieldValue.increment(-10)}));
    });

    test("team photos: any member, one at a time, in their own name", async () => {
      const at = FieldValue.serverTimestamp();
      const photo = (by: string) => ({url: "a", by, at});
      await assertSucceeds(member().update({"teamPhotos.start": photo("u2")}));
      await assertSucceeds(member().update({"teamPhotos.start": photo("u2")}));
      await assertSucceeds(member().update({"teamPhotos.finish": photo("u2")}));
      await assertFails(member().update({"teamPhotos.middle": photo("u2")}));
      await assertFails(member().update({"teamPhotos.start": photo("u1")}));
      await assertFails(member().update({"teamPhotos.start": {url: "a", by: "u2", at, extra: 1}}));
      await assertFails(member().update({"teamPhotos.start": {url: 7, by: "u2", at}}));
      await assertFails(member().update({"teamPhotos.start": {url: "a", by: "u2", at: Timestamp.fromDate(new Date("2020-01-01"))}}));
      await assertFails(member().update({"teamPhotos.start": FieldValue.delete()}));
      await assertFails(member().update({"teamPhotos.start": photo("u2"), "teamPhotos.finish": photo("u2")}));
      await assertFails(as("stranger").doc(TEAM).update({"teamPhotos.start": photo("stranger")}));
    });

    test("attempts, locks and hints", async () => {
      await assertSucceeds(member().update({"attempts.1_0": FieldValue.increment(1)}));
      const until = Timestamp.fromDate(new Date("2026-11-08T12:00:00Z"));
      await assertSucceeds(member().update({"lockedUntil.1_0": until, "attempts.1_0": 0}));
      await assertSucceeds(member().update({"hintsUsed.1_0": true}));
    });

    test("an opened hint cannot be taken back", async () => {
      await assertFails(member().update({"hintsUsed.0_0": FieldValue.delete()}));
      await assertFails(member().update({"hintsUsed.0_0": false}));
    });

    test("a photo: only as pending, with its picture", async () => {
      const at = FieldValue.serverTimestamp();
      await assertSucceeds(member().update({
        "photoApprovals.2_0_0": {status: "pending", url: "b", at},
        "lastPhotoKey": "2_0_0",
      }));
      await assertFails(member().update({
        "photoApprovals.3_0_0": {status: "approved", url: "b", at},
        "lastPhotoKey": "3_0_0",
      }));
      await assertFails(member().update({
        "photoApprovals.3_0_0": {status: "pending", url: "b", reason: "x", at},
        "lastPhotoKey": "3_0_0",
      }));
    });

    test("a member cannot rewrite a decided photo or smuggle a second one", async () => {
      const at = FieldValue.serverTimestamp();
      await assertFails(member().update({
        "photoApprovals.0_0_0": {status: "pending", url: "b", at},
        "lastPhotoKey": "0_0_0",
      }));
      await assertFails(member().update({
        "photoApprovals.1_0_0": {status: "approved", at},
        "photoApprovals.3_0_0": {status: "pending", url: "b", at},
        "lastPhotoKey": "3_0_0",
      }));
      await assertFails(member().update({"photoApprovals.3_0_0": {status: "pending", url: "b", at}}));
      await assertFails(member().update({lastPhotoKey: "x"}));
    });

    test("an organiser decides a photo", async () => {
      const at = FieldValue.serverTimestamp();
      await assertSucceeds(as("admin").doc(TEAM).update({
        "photoApprovals.1_0_0": {status: "denied", reason: "Nu se vede", url: "a", at},
      }));
    });

    test("the unread mark: a member sets it, only an organiser clears it", async () => {
      const at = FieldValue.serverTimestamp();
      await assertSucceeds(member().update({unreadByAdmin: {text: "Alo", at}}));
      await assertFails(member().update({unreadByAdmin: FieldValue.delete()}));
      await assertFails(member().update({unreadByAdmin: {text: "Alo", at, extra: 1}}));
      await assertSucceeds(as("admin").doc(TEAM).update({unreadByAdmin: FieldValue.delete()}));
    });

    test("the phone: the captain, or anyone on an old team", async () => {
      await assertSucceeds(as("u1").doc(TEAM).update({phoneNumber: "0733"}));
      await assertFails(as("u2").doc(TEAM).update({phoneNumber: "0744"}));
      await assertSucceeds(as("u3").doc(OLD_TEAM).update({phoneNumber: "0755"}));
    });

    test("an organiser may change anything", async () => {
      await assertSucceeds(as("admin").doc(TEAM).update({numberOfMembers: 5, place: 1}));
    });
  });

  describe("messages", () => {
    test("a member reads and writes; a non-member does neither", async () => {
      await assertSucceeds(as("u1").doc(MESSAGE).get());
      await assertSucceeds(as("u1").collection(`${TEAM}/messages`).get());
      await assertSucceeds(as("u1").collection(`${TEAM}/messages`).add({sender: "USER", text: "Hei"}));
      await assertFails(as("u3").doc(MESSAGE).get());
      await assertFails(as("u3").collection(`${TEAM}/messages`).add({sender: "USER", text: "Hei"}));
    });

    test("a player cannot speak as the organiser or announce", async () => {
      await assertFails(as("u1").collection(`${TEAM}/messages`).add({sender: "ADMIN", text: "Hei"}));
      await assertFails(as("u1").collection(`${TEAM}/messages`).add({sender: "USER", announcement: true}));
    });

    test("an organiser posts, edits and deletes; a player does not", async () => {
      await assertSucceeds(as("admin").collection(`${TEAM}/messages`).add({sender: "ADMIN", announcement: true}));
      await assertSucceeds(as("admin").doc(MESSAGE).update({text: "x"}));
      await assertFails(as("u1").doc(MESSAGE).update({text: "x"}));
      await assertFails(as("u1").doc(MESSAGE).delete());
      await assertSucceeds(as("admin").doc(MESSAGE).delete());
    });
  });

  describe("functions only", () => {
    test("a member reads their crew, a non-member does not, nobody writes", async () => {
      await assertSucceeds(as("u1").doc("crews/c1").get());
      await assertSucceeds(as("u1").collection("crews").where("memberUids", "array-contains", "u1").get());
      await assertSucceeds(as("admin").doc("crews/c1").get());
      await assertFails(as("u3").doc("crews/c1").get());
      await assertFails(as("u1").doc("crews/c1").update({name: "X"}));
      await assertFails(as("admin").doc("crews/c1").update({name: "X"}));
    });

    test("invite codes are closed to everyone", async () => {
      await assertFails(as("u1").doc("inviteCodes/VLP482").get());
      await assertFails(as("admin").doc("inviteCodes/VLP482").get());
      await assertFails(as("admin").doc("inviteCodes/XXX111").set({crewId: "c1"}));
    });

    test("nobody writes seasons", async () => {
      await assertFails(as("admin").doc("seasons/2026-autumn/standings/c1").set({points: 9999}));
      await assertFails(as("u1").doc("seasons/x").set({name: "x"}));
    });
  });

  describe("news", () => {
    test("an organiser writes, a player does not", async () => {
      await assertSucceeds(as("admin").doc("stire/s2").set({title: "Nou"}));
      await assertSucceeds(as("admin").doc("categories/c2").set({name: "Nou"}));
      await assertFails(as("u1").doc("stire/s2").set({title: "Nou"}));
      await assertFails(as("u1").doc("categories/c2").set({name: "Nou"}));
    });
  });
});
