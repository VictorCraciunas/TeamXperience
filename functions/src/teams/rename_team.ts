import {Firestore} from "firebase-admin/firestore";
import {cleanTeamName, nameKey, teamNameProblem} from "./names";
import {crewTeams, refuse, teamsOf, toDate} from "./shared";

export interface RenameInput {
  eventId?: string;
  teamName?: string;
  newName?: string;
}

/**
 * The captain renames their team before the game starts. A team's name is its
 * document id, so the team moves to a new document with its chat (each message
 * marked `moved`, so it is not pushed again), and its crew takes the name too.
 */
export async function renameTeam(
  db: Firestore,
  uid: string,
  data: RenameInput,
  now: Date = new Date(),
): Promise<{teamName: string}> {
  const eventId = String(data.eventId ?? "");
  if (eventId === "") throw refuse("eventNotFound");
  const oldName = String(data.teamName ?? "");
  if (oldName === "") throw refuse("teamNotFound");
  const raw = String(data.newName ?? "");
  if (teamNameProblem(raw) !== null) throw refuse("nameInvalid");
  const newName = cleanTeamName(raw);

  return db.runTransaction(async (tx) => {
    const event = (await tx.get(db.collection("events").doc(eventId))).data();
    if (event === undefined) throw refuse("eventNotFound");
    const oldRef = teamsOf(db, eventId).doc(oldName);
    const team = (await tx.get(oldRef)).data();
    if (team === undefined) throw refuse("teamNotFound");
    if (team.captainUid !== uid) throw refuse("notCaptain");
    const start = toDate(event.dateEvent);
    if (team.hasStarted === true || (start !== null && now.getTime() >= start.getTime())) throw refuse("gameStarted");
    if (newName === oldName) return {teamName: oldName};

    const key = nameKey(newName);
    const others = (await tx.get(teamsOf(db, eventId))).docs.filter((doc) => doc.id !== oldName);
    if (others.some((doc) => nameKey(String(doc.data().name ?? doc.id)) === key)) throw refuse("nameTaken");

    const messages = await tx.get(oldRef.collection("messages"));
    const crewRef = typeof team.crewId === "string" && team.crewId !== "" ? db.collection("crews").doc(team.crewId) : null;
    const crew = crewRef === null ? undefined : (await tx.get(crewRef)).data();

    const newRef = teamsOf(db, eventId).doc(newName);
    tx.set(newRef, {...team, name: newName, nameKey: key});
    for (const message of messages.docs) {
      tx.set(newRef.collection("messages").doc(message.id), {...message.data(), moved: true});
      tx.delete(message.ref);
    }
    tx.delete(oldRef);
    if (crewRef !== null && crew !== undefined) {
      const links = crewTeams(crew).map((link) =>
        link.eventId === eventId && link.teamName === oldName ? {eventId, teamName: newName} : link);
      tx.update(crewRef, {name: newName, teams: links});
    }
    return {teamName: newName};
  });
}
