import {beforeEach, describe, test} from "node:test";
import * as assert from "node:assert/strict";
import {DocumentData, Firestore, Timestamp} from "firebase-admin/firestore";
import {applyResults, expiredEventIds, teamFacts} from "../results/apply_results";
import {clearDb, emulatorDb} from "./helpers";

// 14:00 in Romania, in the autumn season.
const T0 = new Date("2026-11-14T12:00:00Z");
const at = (minutes: number) => Timestamp.fromDate(new Date(T0.getTime() + minutes * 60000));
const SEASON = "seasons/2026-autumn";

let db: Firestore;

const user = (uid: string, extra: DocumentData = {}) =>
  db.collection("users").doc(uid).set({uid, firstName: uid, role: "USER", ...extra});

const teamDoc = (name: string, data: DocumentData) =>
  db.doc(`events/e1/teams/${name}`).set({name, hasStarted: true, hasFinished: false, ...data});

const read = async (path: string) => (await db.doc(path).get()).data();

async function seedEvent(extra: DocumentData = {}): Promise<void> {
  await db.doc("events/e1").set({
    eventId: "e1",
    name: "Harta",
    dateEvent: Timestamp.fromDate(T0),
    isStopped: true,
    missions: [{id: "m0"}, {id: "m1"}, {id: "m2"}],
    ...extra,
  });
}

async function seedGame(): Promise<void> {
  await seedEvent();
  await user("u1", {xp: 400, stats: {games: 1, distanceMeters: 500, missions: 3, podiums: 0}, badges: ["firstGame"]});
  await user("u2");
  await user("u3");
  await db.doc("crews/c1").set({name: "Vulpile", memberUids: ["u1", "u2"], stats: {games: 2, wins: 1, distanceMeters: 100}});
  await db.doc("crews/c2").set({name: "Lupii", memberUids: ["u3"]});
  await teamDoc("Vulpile", {
    crewId: "c1",
    userIds: ["u1", "u2"],
    numberOfMembers: 2,
    missionProgress: 3,
    startedAt: at(0),
    finishedAt: at(90),
    missionCompletedAt: {"0": at(30), "1": at(60), "2": at(90)},
    walked: {u1: 3000, u2: 2500},
    hintsUsed: {"0_0": true},
    photoApprovals: {
      "0_0_0": {status: "approved", url: "https://a"},
      "1_0_0": {status: "denied", url: "https://b"},
      "1_0_1": {status: "approved", url: "https://c"},
      "2_0_0": {status: "pending", url: "https://d"},
    },
  });
  await teamDoc("Lupii", {
    crewId: "c2",
    userIds: ["u3"],
    numberOfMembers: 4,
    missionProgress: 1,
    startedAt: at(5),
    missionCompletedAt: {"0": at(40)},
    walked: {u3: 1000},
  });
  await db.doc("events/e1/teams/Pisicile").set({name: "Pisicile", hasStarted: false, userIds: ["u9"], crewId: "c9"});
}

describe("results", () => {
  beforeEach(async () => {
    db = emulatorDb();
    await clearDb();
  });

  test("places, for the teams that played", async () => {
    await seedGame();
    await applyResults(db, "e1");
    assert.equal((await read("events/e1/teams/Vulpile"))?.place, 1);
    assert.equal((await read("events/e1/teams/Lupii"))?.place, 2);
    assert.equal((await read("events/e1/teams/Pisicile"))?.place, undefined);
  });

  test("a player's xp, level, stats and badges", async () => {
    await seedGame();
    await applyResults(db, "e1");
    const u1 = await read("users/u1");
    // 400 + 100 finished + 60 missions; new badges winner, photo, crew: 150.
    assert.equal(u1?.xp, 710);
    assert.equal(u1?.level, "Explorator");
    assert.deepEqual(u1?.stats, {games: 2, distanceMeters: 3500, missions: 6, podiums: 1});
    assert.deepEqual([...u1?.badges].sort(), ["crew", "firstGame", "photo", "winner"]);
    const u3 = await read("users/u3");
    assert.equal(u3?.xp, 20);
    assert.deepEqual(u3?.badges, []);
    assert.deepEqual(u3?.stats, {games: 1, distanceMeters: 1000, missions: 1, podiums: 1});
  });

  test("the rest of the user is left alone", async () => {
    await seedGame();
    await applyResults(db, "e1");
    const u1 = await read("users/u1");
    assert.equal(u1?.firstName, "u1");
    assert.equal(u1?.role, "USER");
  });

  test("a memory, as Profil reads it", async () => {
    await seedGame();
    await applyResults(db, "e1");
    const memory = await read("users/u2/memories/e1");
    assert.equal(memory?.eventName, "Harta");
    assert.ok(memory?.date instanceof Timestamp);
    assert.equal(memory?.date.toMillis(), T0.getTime());
    assert.equal(memory?.place, 1);
    assert.equal(memory?.totalTime, 90);
    assert.deepEqual(memory?.photoUrls, ["https://a", "https://c"]);
  });

  test("crew stats and the season", async () => {
    await seedGame();
    await applyResults(db, "e1");
    assert.deepEqual((await read("crews/c1"))?.stats, {games: 3, wins: 2, distanceMeters: 3100});
    assert.deepEqual((await read("crews/c2"))?.stats, {games: 1, wins: 0, distanceMeters: 1000});
    const season = await read(SEASON);
    assert.equal(season?.name, "Toamna 2026");
    const standing = await read(`${SEASON}/standings/c1`);
    assert.deepEqual(standing, {crewName: "Vulpile", points: 100, games: 1});
    assert.equal((await read(`${SEASON}/standings/c2`))?.points, 75);
  });

  test("season points add up over events", async () => {
    await seedGame();
    await db.doc(`${SEASON}/standings/c1`).set({crewName: "Vulpile", points: 60, games: 2});
    await applyResults(db, "e1");
    assert.deepEqual(await read(`${SEASON}/standings/c1`), {crewName: "Vulpile", points: 160, games: 3});
  });

  test("resultsComputedAt comes last, and a second run changes nothing", async () => {
    await seedGame();
    await applyResults(db, "e1");
    assert.ok((await read("events/e1"))?.resultsComputedAt);
    const before = await read("users/u1");
    const crew = await read("crews/c1");
    await applyResults(db, "e1");
    assert.deepEqual(await read("users/u1"), before);
    assert.deepEqual(await read("crews/c1"), crew);
  });

  test("running twice at once counts nobody twice", async () => {
    await seedGame();
    await Promise.all([applyResults(db, "e1"), applyResults(db, "e1")]);
    assert.equal((await read("users/u1"))?.xp, 710);
    assert.equal((await read("crews/c1"))?.stats.games, 3);
    assert.equal((await read(`${SEASON}/standings/c1`))?.points, 100);
  });

  test("a crash halfway resumes: who was counted is not counted again", async () => {
    await seedGame();
    // As if u1 and crew c1 went through before the crash.
    await db.doc("users/u1/memories/e1").set({place: 1});
    await db.doc("crews/c1/results/e1").set({place: 1});
    await applyResults(db, "e1");
    assert.equal((await read("users/u1"))?.xp, 400);
    assert.equal((await read("crews/c1"))?.stats.games, 2);
    assert.ok(await read("users/u2/memories/e1"));
    assert.equal((await read("users/u3"))?.xp, 20);
    assert.equal((await read("crews/c2"))?.stats.games, 1);
    assert.ok((await read("events/e1"))?.resultsComputedAt);
  });

  test("results can be recomputed after an event was saved: still nobody twice", async () => {
    await seedGame();
    await applyResults(db, "e1");
    await db.doc("events/e1").set({name: "Harta", dateEvent: Timestamp.fromDate(T0), isStopped: true, missions: [{}, {}, {}]});
    await applyResults(db, "e1");
    assert.equal((await read("users/u1"))?.xp, 710);
  });

  test("a member with no user doc is skipped, and the rest go on", async () => {
    await seedEvent();
    await user("u1");
    await teamDoc("Vulpile", {userIds: ["ghost", "u1"], missionProgress: 1, missionCompletedAt: {"0": at(10)}});
    await applyResults(db, "e1");
    assert.equal(await read("users/ghost"), undefined);
    assert.equal((await read("users/u1"))?.xp, 20);
  });

  test("an old team with no crew gets a place and its players score", async () => {
    await seedEvent();
    await user("u1");
    await teamDoc("Vechi", {userIds: ["u1"], missionProgress: 2, missionCompletedAt: {"0": at(10), "1": at(30)}});
    await applyResults(db, "e1");
    assert.equal((await read("events/e1/teams/Vechi"))?.place, 1);
    assert.equal((await read("users/u1"))?.xp, 40);
    assert.equal((await db.collection(`${SEASON}/standings`).get()).size, 0);
  });

  test("a crew that is gone is skipped", async () => {
    await seedEvent();
    await user("u1");
    await teamDoc("Vulpile", {crewId: "gone", userIds: ["u1"], missionProgress: 1});
    await applyResults(db, "e1");
    assert.ok((await read("events/e1"))?.resultsComputedAt);
    assert.equal(await read("crews/gone"), undefined);
  });

  test("no teams, no missions, a missing event, a draft: no trouble", async () => {
    await seedEvent({missions: []});
    await applyResults(db, "e1");
    assert.ok((await read("events/e1"))?.resultsComputedAt);
    await applyResults(db, "nope");
    await db.doc("events/draft").set({status: "draft", dateEvent: Timestamp.fromDate(T0)});
    await applyResults(db, "draft");
    assert.equal((await read("events/draft"))?.resultsComputedAt, undefined);
  });

  test("more teams than a batch holds", async () => {
    await seedEvent();
    const write = db.bulkWriter();
    for (let i = 0; i < 450; i++) {
      const name = `T${String(i).padStart(3, "0")}`;
      void write.set(db.doc(`events/e1/teams/${name}`), {name, hasStarted: true, userIds: [], missionProgress: 0});
    }
    await write.close();
    await applyResults(db, "e1");
    assert.equal((await read("events/e1/teams/T449"))?.place, 450);
    assert.equal((await read("events/e1/teams/T000"))?.place, 1);
  });

  describe("expiredEventIds", () => {
    const NOW = new Date(T0.getTime() + 4 * 60 * 60000);
    const event = (id: string, hoursAgo: number, extra: DocumentData = {}) =>
      db.doc(`events/${id}`).set({dateEvent: Timestamp.fromDate(new Date(NOW.getTime() - hoursAgo * 3600000)), ...extra});

    test("only what ran out in the past week, with no results, and no drafts", async () => {
      await event("ran-out", 4);
      await event("running", 2);
      await event("future", -5);
      await event("done", 5, {resultsComputedAt: Timestamp.fromDate(T0)});
      await event("draft", 5, {status: "draft"});
      await event("ancient", 24 * 8);
      assert.deepEqual(await expiredEventIds(db, NOW), ["ran-out"]);
    });
  });

  describe("teamFacts", () => {
    test("odd old data does not throw", () => {
      const facts = teamFacts({userIds: "x", walked: {a: "far"}, photoApprovals: {a: "approved", b: 7}, missionCompletedAt: {x: 1}}, "Doc");
      assert.equal(facts.name, "Doc");
      assert.deepEqual(facts.userIds, []);
      assert.equal(facts.walkedMeters, 0);
      assert.deepEqual(facts.approvedPhotos, [null]);
      assert.equal(facts.missionTimes.size, 0);
    });

    test("the walk is the longest phone's; hints are the true ones", () => {
      const facts = teamFacts({walked: {a: 10, b: 30}, hintsUsed: {x: true, y: false}}, "D");
      assert.equal(facts.walkedMeters, 30);
      assert.equal(facts.hintsUsed, 1);
    });
  });
});
