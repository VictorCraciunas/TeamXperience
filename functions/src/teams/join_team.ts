import {FieldValue, Firestore} from "firebase-admin/firestore";
import {isWellFormedCode, normaliseCode} from "./codes";
import {notifyCaptain} from "./notify";
import {nextOf} from "./preview_invite";
import {crewTeams, eventIsOver, memberOf, refuse, teamsOf} from "./shared";

export type NotifyJoin = (captainUid: string, displayName: string, crewName: string) => Promise<void>;

/**
 * Joins the crew behind a code, and its teams in events that are not over. The
 * next event decides: a full team there, or being in another team there,
 * refuses the whole join; later events are just skipped. Joining again returns
 * the player's events, since a join that timed out may have gone through.
 */
export async function joinTeam(
  db: Firestore,
  uid: string,
  data: {code?: string},
  options: {now?: Date; notify?: NotifyJoin} = {},
): Promise<{crewId: string; eventIds: string[]}> {
  const now = options.now ?? new Date();
  const raw = String(data.code ?? "");
  if (!isWellFormedCode(raw)) throw refuse("codeUnknown");
  const inviteRef = db.collection("inviteCodes").doc(normaliseCode(raw));
  const userRef = db.collection("users").doc(uid);

  const joined = await db.runTransaction(async (tx) => {
    const crewId = (await tx.get(inviteRef)).data()?.crewId;
    if (typeof crewId !== "string") throw refuse("codeUnknown");
    const crewRef = db.collection("crews").doc(crewId);
    const crew = (await tx.get(crewRef)).data();
    if (crew === undefined) throw refuse("codeUnknown");

    const links = crewTeams(crew);
    const events = await Promise.all(links.map((l) => tx.get(db.collection("events").doc(l.eventId))));
    const teamDocs = await Promise.all(links.map((l) => tx.get(teamsOf(db, l.eventId).doc(l.teamName))));

    const uids: string[] = Array.isArray(crew.memberUids) ? crew.memberUids : [];
    if (uids.includes(uid)) {
      const mine = links.filter((_, i) => {
        const ids = teamDocs[i].data()?.userIds;
        return Array.isArray(ids) && ids.includes(uid);
      });
      return {crewId, eventIds: mine.map((l) => l.eventId), newMember: null};
    }

    const me = memberOf(uid, (await tx.get(userRef)).data());
    const next = nextOf(links, events.map((d) => d.data()), teamDocs.map((d) => d.data()), now);

    const eventIds: string[] = [];
    const writes: (() => void)[] = [];
    for (let i = 0; i < links.length; i++) {
      const event = events[i].data();
      const team = teamDocs[i].data();
      if (event === undefined || team === undefined || eventIsOver(event, now)) continue;
      const link = links[i];
      const isNext = next !== null && link.eventId === next.eventId;

      const others = await tx.get(teamsOf(db, link.eventId).where("userIds", "array-contains", uid));
      if (!others.empty) {
        if (isNext) throw refuse("alreadyInTeam", {teamName: String(others.docs[0].data().name ?? "")});
        continue;
      }
      const ids: string[] = Array.isArray(team.userIds) ? team.userIds : [];
      if (ids.length >= Number(team.numberOfMembers ?? 0)) {
        if (isNext) throw refuse("teamFull");
        continue;
      }
      const names = String(team.teamMembers ?? "");
      writes.push(() => tx.update(teamDocs[i].ref, {
        userIds: FieldValue.arrayUnion(uid),
        members: FieldValue.arrayUnion(me),
        teamMembers: names === "" ? me.displayName : `${names}, ${me.displayName}`,
      }));
      eventIds.push(link.eventId);
    }

    tx.update(crewRef, {memberUids: FieldValue.arrayUnion(uid), members: FieldValue.arrayUnion(me)});
    writes.forEach((write) => write());
    if (eventIds.length > 0) {
      tx.set(userRef, {registeredEventIds: FieldValue.arrayUnion(...eventIds)}, {merge: true});
    }
    return {
      crewId,
      eventIds,
      newMember: {captainUid: String(crew.captainUid ?? ""), displayName: me.displayName, crewName: String(crew.name ?? "")},
    };
  });

  if (joined.newMember !== null) {
    const {captainUid, displayName, crewName} = joined.newMember;
    await (options.notify ?? notifyCaptain)(captainUid, displayName, crewName);
  }
  return {crewId: joined.crewId, eventIds: joined.eventIds};
}
