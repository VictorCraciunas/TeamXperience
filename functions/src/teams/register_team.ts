import {FieldValue, Firestore} from "firebase-admin/firestore";
import {cleanTeamName, nameKey, teamNameProblem} from "./names";
import {addNewCrew} from "./new_crew";
import * as logger from "firebase-functions/logger";
import {addToInboxes, InboxItem, pushToUser} from "../notifications/inbox";
import {enrolmentOpen, Member, memberOf, refuse, shortDate, teamsOf, toDate} from "./shared";

export interface RegisterInput {
  eventId?: string;
  name?: string;
  size?: number;
  phone?: string;
  rulesAccepted?: boolean;
  dataAccepted?: boolean;
  photoConsent?: boolean;
  crewId?: string;
}

export interface RegisterOutput {
  teamName: string;
  crewId: string;
  inviteCode: string;
  skippedUids: string[];
}

/** One transaction, refusing at the first failure; see the checks below. */
export async function registerTeam(
  db: Firestore,
  uid: string,
  data: RegisterInput,
  now: Date = new Date(),
  tell: (uids: string[], item: InboxItem) => Promise<void> = tellPlayers(db),
): Promise<RegisterOutput> {
  const eventId = String(data.eventId ?? "");
  if (eventId === "") throw refuse("eventNotFound");
  const eventRef = db.collection("events").doc(eventId);

  const done = await db.runTransaction(async (tx) => {
    const eventDoc = await tx.get(eventRef);
    const event = eventDoc.data();
    if (event === undefined || event.status === "draft") throw refuse("eventNotFound");
    if (!enrolmentOpen(event, now)) throw refuse("enrolmentClosed");

    const size = data.size;
    const min = typeof event.teamSizeMin === "number" ? event.teamSizeMin : 2;
    const max = typeof event.teamSizeMax === "number" ? event.teamSizeMax : 6;
    if (typeof size !== "number" || !Number.isInteger(size) || size < min || size > max) throw refuse("sizeInvalid");

    if (data.rulesAccepted !== true) throw refuse("rulesNotAccepted");

    const rawName = String(data.name ?? "");
    if (teamNameProblem(rawName) !== null) throw refuse("nameInvalid");
    const name = cleanTeamName(rawName);

    const teams = (await tx.get(teamsOf(db, eventId))).docs.map((doc) => doc.data());
    const key = nameKey(name);
    if (teams.some((team) => nameKey(String(team.name ?? "")) === key)) throw refuse("nameTaken");

    const inTeam = (who: string) =>
      teams.find((team) => Array.isArray(team.userIds) && team.userIds.includes(who));
    const own = inTeam(uid);
    if (own !== undefined) throw refuse("alreadyInTeam", {teamName: String(own.name ?? "")});

    if (typeof event.maxTeams === "number" && teams.length >= event.maxTeams) throw refuse("eventFull");

    const userDoc = await tx.get(db.collection("users").doc(uid));
    const captain = memberOf(uid, userDoc.data());

    // The team's players: the crew's who are free, or just the captain.
    let crewId: string;
    let inviteCode: string;
    let players: Member[] = [captain];
    let skippedUids: string[] = [];
    let writeCrew: () => void;
    const link = {eventId, teamName: name};

    if (data.crewId) {
      const crewRef = db.collection("crews").doc(data.crewId);
      const crew = (await tx.get(crewRef)).data();
      if (crew === undefined || crew.captainUid !== uid) throw refuse("notCaptain");
      if (teams.some((team) => team.crewId === data.crewId)) throw refuse("crewAlreadyRegistered");
      const members: Member[] = Array.isArray(crew.members) ? crew.members : [];
      if (members.length > size) throw refuse("sizeInvalid");
      skippedUids = members.filter((m) => inTeam(m.uid) !== undefined).map((m) => m.uid);
      players = members.filter((m) => !skippedUids.includes(m.uid));
      crewId = data.crewId;
      inviteCode = String(crew.inviteCode ?? "");
      // Signed up under a new name, the crew takes it too, as a rename does.
      const renamed = String(crew.name ?? "") !== name ? {name} : {};
      writeCrew = () => tx.update(crewRef, {teams: FieldValue.arrayUnion(link), ...renamed});
    } else {
      const made = await addNewCrew(db, tx, name, captain);
      crewId = made.crewId;
      inviteCode = made.inviteCode;
      writeCrew = () => made.write([link]);
    }

    writeCrew();
    tx.set(teamsOf(db, eventId).doc(name), {
      name,
      nameKey: key,
      crewId,
      captainUid: uid,
      captainName: captain.displayName,
      captainEmail: String(userDoc.data()?.email ?? ""),
      phoneNumber: String(data.phone ?? "").trim(),
      numberOfMembers: size,
      userIds: players.map((p) => p.uid),
      members: players,
      teamMembers: players.map((p) => p.displayName).join(", "),
      rulesAcceptedAt: FieldValue.serverTimestamp(),
      ...(data.dataAccepted === true ? {dataAcceptedAt: FieldValue.serverTimestamp()} : {}),
      photoConsent: data.photoConsent === true,
      missionProgress: 0,
      puzzleNumber: 0,
      hasStarted: false,
      hasFinished: false,
      latitude: 0,
      longitude: 0,
      photoApprovals: {},
    });
    for (const player of players) {
      tx.set(db.collection("users").doc(player.uid), {registeredEventIds: FieldValue.arrayUnion(eventId)}, {merge: true});
    }
    const others = players.map((p) => p.uid).filter((other) => other !== uid);
    const date = toDate(event.dateEvent);
    const item: InboxItem = {
      kind: "team",
      title: "Echipa ta s-a înscris",
      body: `${name} merge la ${String(event.name ?? "")}${date === null ? "" : `, pe ${shortDate(date)}`}`,
      eventId,
    };
    return {output: {teamName: name, crewId, inviteCode, skippedUids}, others, item};
  });

  // The others hear after the sign-up is saved; a failure only is logged.
  if (done.others.length > 0) {
    try {
      await tell(done.others, done.item);
    } catch (error) {
      logger.warn("Could not tell the crew it signed up", {eventId, error: String(error)});
    }
  }
  return done.output;
}

/** Each player's list, then their phone. */
function tellPlayers(db: Firestore): (uids: string[], item: InboxItem) => Promise<void> {
  return async (uids, item) => {
    await addToInboxes(db, uids, item);
    await Promise.all(uids.map((other) => pushToUser(db, other, item.title, item.body)));
  };
}
