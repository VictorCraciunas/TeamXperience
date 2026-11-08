import {DocumentData, Firestore} from "firebase-admin/firestore";
import {isWellFormedCode, normaliseCode} from "./codes";
import {crewTeams, CrewTeam, eventIsOver, Member, refuse, teamsOf, toDate} from "./shared";

/** A crew's team in the soonest event that is not over. */
export interface NextTeam extends CrewTeam {
  event: DocumentData;
  team: DocumentData;
}

/** Finds it from documents already read, in the order of [links]. */
export function nextOf(links: CrewTeam[], events: (DocumentData | undefined)[], teams: (DocumentData | undefined)[], now: Date): NextTeam | null {
  let best: NextTeam | null = null;
  links.forEach((link, i) => {
    const event = events[i];
    const team = teams[i];
    if (event === undefined || team === undefined || eventIsOver(event, now)) return;
    const when = toDate(event.dateEvent)?.getTime() ?? Infinity;
    const bestWhen = best === null ? Infinity : toDate(best.event.dateEvent)?.getTime() ?? Infinity;
    if (best === null || when < bestWhen) best = {...link, event, team};
  });
  return best;
}

export interface PreviewOutput {
  crewId: string;
  crewName: string;
  captainName: string;
  members: Member[];
  alreadyMember: boolean;
  event?: {eventId: string; name: string; dateEvent: string; teamName: string; size: number; count: number};
}

/** Who is behind a code, before joining. Reads only. */
export async function previewInvite(
  db: Firestore,
  uid: string,
  data: {code?: string},
  now: Date = new Date(),
): Promise<PreviewOutput> {
  const raw = String(data.code ?? "");
  if (!isWellFormedCode(raw)) throw refuse("codeUnknown");
  const invite = await db.collection("inviteCodes").doc(normaliseCode(raw)).get();
  const crewId = invite.data()?.crewId;
  if (typeof crewId !== "string") throw refuse("codeUnknown");
  const crew = (await db.collection("crews").doc(crewId).get()).data();
  if (crew === undefined) throw refuse("codeUnknown");

  const links = crewTeams(crew);
  const events = await Promise.all(links.map((l) => db.collection("events").doc(l.eventId).get()));
  const teams = await Promise.all(links.map((l) => teamsOf(db, l.eventId).doc(l.teamName).get()));
  const next = nextOf(links, events.map((d) => d.data()), teams.map((d) => d.data()), now);

  const crewMembers: Member[] = Array.isArray(crew.members) ? crew.members : [];
  const members: Member[] = next !== null && Array.isArray(next.team.members) ? next.team.members : crewMembers;
  const captain = crewMembers.find((m) => m.uid === crew.captainUid);
  const uids: string[] = Array.isArray(crew.memberUids) ? crew.memberUids : [];

  const output: PreviewOutput = {
    crewId,
    crewName: String(crew.name ?? ""),
    captainName: captain?.displayName ?? "",
    members,
    alreadyMember: uids.includes(uid),
  };
  if (next !== null) {
    const when = toDate(next.event.dateEvent);
    output.event = {
      eventId: next.eventId,
      name: String(next.event.name ?? ""),
      dateEvent: when === null ? "" : when.toISOString(),
      teamName: next.teamName,
      size: Number(next.team.numberOfMembers ?? 0),
      count: Array.isArray(next.team.userIds) ? next.team.userIds.length : 0,
    };
  }
  return output;
}
