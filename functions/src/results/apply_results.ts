import {DocumentData, DocumentReference, FieldValue, Firestore, Timestamp, WriteBatch} from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import {playTimeMs, teamsOf, toDate} from "../teams/shared";
import {EventFacts, isCompleted, playerResult, Previous, TeamFacts} from "./player";
import {inboxEntry, InboxItem, pushToUser} from "../notifications/inbox";
import {rankTeams} from "./ranking";
import {seasonOf, seasonPoints} from "./season";

const BATCH_SIZE = 400;
const READ_SIZE = 300;
const PARALLEL = 10;
const num = (value: unknown): number => (typeof value === "number" ? value : 0);

/** Old teams can hold an empty uid; a document id cannot be empty or hold a slash. */
const isDocId = (value: unknown): value is string =>
  typeof value === "string" && value !== "" && !value.includes("/");

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
    userIds: Array.isArray(data.userIds) ? data.userIds.filter(isDocId) : [],
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

/** What a player's list says when the results are in. */
export function resultsItem(eventId: string, team: TeamFacts, place: number, event: EventFacts): InboxItem {
  return {
    kind: "results",
    title: "Rezultatele sunt gata",
    body: `Echipa ${team.name} a ieșit pe locul ${place} la ${event.name}.`,
    eventId,
  };
}

/**
 * One player, once: the memory is the mark that this game was counted. The
 * list entry is written with it, so it is there exactly once. True when this
 * run counted the player.
 */
async function applyPlayer(db: Firestore, uid: string, eventId: string, team: TeamFacts, place: number, event: EventFacts): Promise<boolean> {
  const userRef = db.collection("users").doc(uid);
  const memoryRef = userRef.collection("memories").doc(eventId);
  return db.runTransaction(async (tx) => {
    const memory = await tx.get(memoryRef);
    if (memory.exists) return false;
    const user = (await tx.get(userRef)).data();
    if (user === undefined) return false;
    const result = playerResult(team, place, event, previousOf(user));
    tx.update(userRef, {xp: result.xp, level: result.level, stats: result.stats, badges: result.badges});
    tx.set(memoryRef, {...result.memory, date: Timestamp.fromDate(result.memory.date)});
    tx.set(userRef.collection("notifications").doc(`results_${eventId}`), inboxEntry(resultsItem(eventId, team, place, event)));
    return true;
  });
}

/** One crew, once: its stats and its season points. */
async function applyCrew(db: Firestore, crewId: string, eventId: string, team: TeamFacts, place: number, event: EventFacts): Promise<void> {
  const crewRef = db.collection("crews").doc(crewId);
  const markRef = crewRef.collection("results").doc(eventId);
  const season = seasonOf(event.date);
  const standingRef = db.collection("seasons").doc(season.id).collection("standings").doc(crewId);
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
    tx.set(standingRef, {
      crewName: String(crew.name ?? team.name),
      points: FieldValue.increment(seasonPoints(place)),
      games: FieldValue.increment(1),
    }, {merge: true});
  });
}

/** Runs [work] for each item, a few at a time. */
async function inParallel<T>(items: T[], work: (item: T) => Promise<void>): Promise<void> {
  let next = 0;
  const worker = async () => {
    while (next < items.length) await work(items[next++]);
  };
  await Promise.all(Array.from({length: Math.min(PARALLEL, items.length)}, worker));
}

/** Which of these documents exist. */
async function existing(db: Firestore, refs: DocumentReference[]): Promise<Set<string>> {
  const found = new Set<string>();
  for (let i = 0; i < refs.length; i += READ_SIZE) {
    const docs = await db.getAll(...refs.slice(i, i + READ_SIZE));
    for (const doc of docs) if (doc.exists) found.add(doc.ref.path);
  }
  return found;
}

export interface ApplyOptions {
  /** Called before each player's transaction (for tests). */
  beforePlayer?: (uid: string) => void;
  /** Sends a player's results push; by default to their phone. */
  push?: (uid: string, title: string, body: string) => Promise<void>;
}

/**
 * Works out an event's results. Safe to run again, and to resume after a crash:
 * each player and crew is counted once on their own. One failing holds nobody
 * else back; `resultsComputedAt` is written only when all went through, so the
 * schedule tries the rest again.
 */
export async function applyResults(db: Firestore, eventId: string, options: ApplyOptions = {}): Promise<void> {
  const eventRef = db.collection("events").doc(eventId);
  const data = (await eventRef.get()).data();
  if (data === undefined || data.resultsComputedAt !== undefined || data.status === "draft") return;

  const event: EventFacts = {
    name: String(data.name ?? ""),
    date: toDate(data.dateEvent) ?? new Date(),
    missionCount: Array.isArray(data.missions) ? data.missions.length : 0,
    playMs: playTimeMs(data),
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

  // Who is left: a rerun skips those counted before without a transaction each.
  const players = ranked.flatMap((team, i) => team.userIds.map((uid) => ({uid, team, place: i + 1})));
  const memoryOf = (uid: string) => db.collection("users").doc(uid).collection("memories").doc(eventId);
  const counted = await existing(db, players.map((p) => memoryOf(p.uid)));
  const crews = ranked.flatMap((team, i) => (team.crewId === undefined ? [] : [{crewId: team.crewId, team, place: i + 1}]));
  const markOf = (crewId: string) => db.collection("crews").doc(crewId).collection("results").doc(eventId);
  const marked = await existing(db, crews.map((c) => markOf(c.crewId)));

  // Written once here: in each crew's transaction it would make them queue.
  if (crews.length > 0) {
    const season = seasonOf(event.date);
    await db.collection("seasons").doc(season.id).set({
      name: season.name,
      startsAt: Timestamp.fromDate(season.startsAt),
      endsAt: Timestamp.fromDate(season.endsAt),
    }, {merge: true});
  }

  const push = options.push ?? ((uid: string, title: string, body: string) => pushToUser(db, uid, title, body));
  // A push that fails is only logged: the player is counted already.
  const sendResultsPush = async (uid: string, item: InboxItem) => {
    try {
      await push(uid, item.title, item.body);
    } catch (error) {
      logger.warn("Could not send the results push", {eventId, uid, error: String(error)});
    }
  };

  let failures = 0;
  const failed = (what: string, error: unknown) => {
    failures++;
    logger.error("Could not count a result", {eventId, what, error: String(error)});
  };
  await inParallel(players.filter((p) => !counted.has(memoryOf(p.uid).path)), async ({uid, team, place}) => {
    try {
      options.beforePlayer?.(uid);
      const counted = await applyPlayer(db, uid, eventId, team, place, event);
      if (counted) await sendResultsPush(uid, resultsItem(eventId, team, place, event));
    } catch (error) {
      failed(uid, error);
    }
  });
  await inParallel(crews.filter((c) => !marked.has(markOf(c.crewId).path)), async ({crewId, team, place}) => {
    try {
      await applyCrew(db, crewId, eventId, team, place, event);
    } catch (error) {
      failed(crewId, error);
    }
  });

  if (failures === 0) await eventRef.update({resultsComputedAt: FieldValue.serverTimestamp()});
}

const LOOK_BACK_MS = 7 * 24 * 60 * 60 * 1000;

/**
 * Events whose time ran out (their duration, else three hours) in about the
 * past week and that have no results. The week keeps a first deploy from
 * scoring every game ever played.
 */
export async function expiredEventIds(db: Firestore, now: Date): Promise<string[]> {
  const from = new Date(now.getTime() - LOOK_BACK_MS);
  const events = await db.collection("events")
    .where("dateEvent", ">=", Timestamp.fromDate(from))
    .where("dateEvent", "<", Timestamp.fromDate(now))
    .get();
  return events.docs
    .filter((doc) => {
      const data = doc.data();
      const start = toDate(data.dateEvent);
      return data.resultsComputedAt === undefined && data.status !== "draft" &&
        start !== null && now.getTime() > start.getTime() + playTimeMs(data);
    })
    .map((doc) => doc.id);
}
