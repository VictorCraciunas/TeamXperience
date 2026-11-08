import {Firestore} from "firebase-admin/firestore";
import {cleanTeamName, teamNameProblem} from "./names";
import {addNewCrew} from "./new_crew";
import {memberOf, refuse} from "./shared";

/** A new crew with the caller as captain and only member. */
export async function createCrew(
  db: Firestore,
  uid: string,
  data: {name?: string},
): Promise<{crewId: string; inviteCode: string}> {
  const raw = String(data.name ?? "");
  if (teamNameProblem(raw) !== null) throw refuse("nameInvalid");
  const name = cleanTeamName(raw);
  return db.runTransaction(async (tx) => {
    const user = await tx.get(db.collection("users").doc(uid));
    const crew = await addNewCrew(db, tx, name, memberOf(uid, user.data()));
    crew.write();
    return {crewId: crew.crewId, inviteCode: crew.inviteCode};
  });
}
