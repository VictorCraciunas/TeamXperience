import {Firestore} from "firebase-admin/firestore";
import {nameKey, TeamNameProblem, teamNameProblem} from "./names";
import {teamsOf} from "./shared";

/**
 * Whether a name can be used in an event. Reads every team and compares their
 * names, because teams made before `nameKey` existed do not store one.
 */
export async function checkTeamName(
  db: Firestore,
  _uid: string,
  data: {eventId?: string; name?: string},
): Promise<{free: boolean; problem?: TeamNameProblem}> {
  const name = String(data.name ?? "");
  const problem = teamNameProblem(name);
  if (problem !== null) return {free: false, problem};
  const key = nameKey(name);
  const teams = await teamsOf(db, String(data.eventId ?? "-")).get();
  return {free: !teams.docs.some((team) => nameKey(String(team.data().name ?? "")) === key)};
}
