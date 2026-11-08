import {FieldValue, Firestore, Transaction} from "firebase-admin/firestore";
import {makeCode} from "./codes";
import {Member} from "./shared";

/**
 * Writes a new crew with its unused invite code inside [tx]. Reads come first,
 * so call it before the transaction's other writes.
 */
export async function addNewCrew(
  db: Firestore,
  tx: Transaction,
  name: string,
  captain: Member,
  random: () => number = Math.random,
): Promise<{crewId: string; inviteCode: string; write: (teams?: {eventId: string; teamName: string}[]) => void}> {
  let inviteCode = "";
  for (let attempt = 0; attempt < 10 && inviteCode === ""; attempt++) {
    const candidate = makeCode(name, random);
    const taken = await tx.get(db.collection("inviteCodes").doc(candidate));
    if (!taken.exists) inviteCode = candidate;
  }
  if (inviteCode === "") throw new Error(`No free invite code for ${name}`);

  const crew = db.collection("crews").doc();
  return {
    crewId: crew.id,
    inviteCode,
    write: (teams = []) => {
      tx.set(crew, {
        name,
        captainUid: captain.uid,
        memberUids: [captain.uid],
        members: [captain],
        inviteCode,
        teams,
        stats: {games: 0, wins: 0, distanceMeters: 0},
        createdAt: FieldValue.serverTimestamp(),
      });
      tx.set(db.collection("inviteCodes").doc(inviteCode), {crewId: crew.id});
    },
  };
}
