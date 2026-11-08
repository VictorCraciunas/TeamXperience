import {DocumentData, FieldValue, Firestore, Timestamp, WriteBatch} from "firebase-admin/firestore";
import {teamsOf, toDate} from "../teams/shared";
import {EventFacts, isCompleted, playerResult, Previous, TeamFacts} from "./player";
import {rankTeams} from "./ranking";
import {seasonOf, seasonPoints} from "./season";

const BATCH_SIZE = 400;
const num = (value: unknown): number => (typeof value === "number" ? value : 0);

/** A team document as plain facts, whatever old data it holds. */
export function teamFacts(data: DocumentData, id: string): TeamFacts {
  const times = new Map<number, Date>();
  for (const [key, value] of Object.entries(data.missionCompletedAt ?? {})) {
    const at = toDate(value);
    const index = Number(key);
    if (at !== null && Number.isInteger(index)) times.set(index, at);
  }
  const walked = Object.values(data.walked ?? {}).map(num);
  const photos: (string | null)[] = [];
  const approvals = data.photoApprovals ?? {};
  for (const key of Object.keys(approvals).sort()) {
    const value = approvals[key];
    if (value === "approved") photos.push(null);
    else if (value?.status === "approved") photos.push(typeof value.url === "string" ? value.url : null);
  }
  return {
    name: typeof data.name === "string" && data.name !== "" ? data.name : id,
    crewId: typeof data.crewId === "string" ? data.crewId : undefined,
    userIds: Array.isArray(data.userIds) ? data.userIds : [],
    numberOfMembers: num(data.numberOfMembers),
    missionProgress: num(data.missionProgress),
    startedAt: toDate(data.startedAt),
    finishedAt: toDate(data.finishedAt),
    missionTimes: times,
    hintsUsed: Object.values(data.hintsUsed ?? {}).filter((used) => used === true).length,
    walkedMeters: walked.length === 0 ? 0 : Math.max(...walked),
    approvedPhotos: photos,
  };
}

function previousOf(user: DocumentData): Previous {
  const stats = user.stats ?? {};
  return {
    xp: num(user.xp),
    stats: {
      games: num(stats.games),
      distanceMeters: num(stats.distanceMeters),
      missions: num(stats.missions),
      podiums: num(stats.podiums),
    },
    badges: Array.isArray(user.badges) ? user.badges : [],
  };
}

/** One player, once: the memory is the mark that this game was counted. */
async function applyPlayer(db: Firestore, uid: string, eventId: string, team: TeamFacts, place: number, event: EventFacts): Promise<void> {
  const userRef = db.collection("users").doc(uid);
  const memoryRef = userRef.collection("memories").doc(eventId);
  await db.runTransaction(async (tx) => {
    const memory = await tx.get(memoryRef);
    if (memory.exists) return;
    const user = (await tx.get(userRef)).data();
    if (user === undefined) return;
    const result = playerResult(team, place, event, previousOf(user));
    tx.update(userRef, {xp: result.xp, level: result.level, stats: result.stats, badges: result.badges});
    tx.set(memoryRef, {...result.memory, date: Timestamp.fromDate(result.memory.date)});
  });
}

/** One crew, once: its stats and its season points. */
async function applyCrew(db: Firestore, crewId: string, eventId: string, team: TeamFacts, place: number, event: EventFacts): Promise<void> {
  const crewRef = db.collection("crews").doc(crewId);
  const markRef = crewRef.collection("results").doc(eventId);
  const season = seasonOf(event.date);
  const seasonRef = db.collection("seasons").doc(season.id);
  const standingRef = seasonRef.collection("standings").doc(crewId);
  const won = place === 1 && isCompleted(team, event.missionCount);
  await db.runTransaction(async (tx) => {
    const mark = await tx.get(markRef);
    if (mark.exists) return;
    const crew = (await tx.get(crewRef)).data();
    if (crew === undefined) return;
    tx.set(markRef, {place});
    tx.set(crewRef, {
      stats: {
        games: FieldValue.increment(1),
        wins: FieldValue.increment(won ? 1 : 0),
        distanceMeters: FieldValue.increment(team.walkedMeters),
      },
    }, {merge: true});
    tx.set(seasonRef, {
      name: season.name,
      startsAt: Timestamp.fromDate(season.startsAt),
      endsAt: Timestamp.fromDate(season.endsAt),
    }, {merge: true});
    tx.set(standingRef, {
      crewName: String(crew.name ?? team.name),
      points: FieldValue.increment(seasonPoints(place)),
      games: FieldValue.increment(1),
    }, {merge: true});
  });
}

/**
 * Works out an event's results. Safe to run again, and to resume after a crash:
 * each player and crew is counted once on their own, and `resultsComputedAt` is
 * written last.
 */
export async function applyResults(db: Firestore, eventId: string): Promise<void> {
  const eventRef = db.collection("events").doc(eventId);
  const data = (await eventRef.get()).data();
  if (data === undefined || data.resultsComputedAt !== undefined || data.status === "draft") return;

  const event: EventFacts = {
    name: String(data.name ?? ""),
    date: toDate(data.dateEvent) ?? new Date(),
    missionCount: Array.isArray(data.missions) ? data.missions.length : 0,
  };

  const docs = (await teamsOf(db, eventId).get()).docs;
  const started = docs
    .filter((doc) => doc.data().hasStarted === true || doc.data().hasFinished === true)
    .map((doc) => ({doc, facts: teamFacts(doc.data(), doc.id)}));
  const byName = new Map(started.map((entry) => [entry.facts.name, entry.doc.ref]));
  const ranked = rankTeams(started.map((entry) => entry.facts), event.missionCount);

  let batch: WriteBatch = db.batch();
  let pending = 0;
  for (let i = 0; i < ranked.length; i++) {
    const ref = byName.get(ranked[i].name);
    if (ref === undefined) continue;
    batch.update(ref, {place: i + 1});
    if (++pending === BATCH_SIZE) {
      await batch.commit();
      batch = db.batch();
      pending = 0;
    }
  }
  if (pending > 0) await batch.commit();

  for (let i = 0; i < ranked.length; i++) {
    const team = ranked[i];
    const place = i + 1;
    for (const uid of team.userIds) await applyPlayer(db, uid, eventId, team, place, event);
    if (team.crewId !== undefined) await applyCrew(db, team.crewId, eventId, team, place, event);
  }

  await eventRef.update({resultsComputedAt: FieldValue.serverTimestamp()});
}

const LOOK_BACK_MS = 7 * 24 * 60 * 60 * 1000;
const MAX_DURATION_MS = 3 * 60 * 60 * 1000;

/**
 * Events whose three hours ran out in the past week and that have no results.
 * The week keeps a first deploy from scoring every game ever played.
 */
export async function expiredEventIds(db: Firestore, now: Date): Promise<string[]> {
  const until = new Date(now.getTime() - MAX_DURATION_MS);
  const from = new Date(until.getTime() - LOOK_BACK_MS);
  const events = await db.collection("events")
    .where("dateEvent", ">=", Timestamp.fromDate(from))
    .where("dateEvent", "<", Timestamp.fromDate(until))
    .get();
  return events.docs
    .filter((doc) => doc.data().resultsComputedAt === undefined && doc.data().status !== "draft")
    .map((doc) => doc.id);
}
