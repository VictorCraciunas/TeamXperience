import * as logger from "firebase-functions/logger";
import {getFirestore} from "firebase-admin/firestore";
import {addToInboxes, pushToUser} from "../notifications/inbox";

type Push = (uid: string, title: string, body: string) => Promise<void>;

/** Tells the captain someone joined, in their list and by push. A failure is only logged. */
export async function notifyCaptain(
  captainUid: string,
  displayName: string,
  crewName: string,
  push: Push = (uid, title, body) => pushToUser(getFirestore(), uid, title, body),
): Promise<void> {
  const title = "Echipa ta crește";
  const body = `${displayName} a intrat în ${crewName}`;
  await addToInboxes(getFirestore(), [captainUid], {kind: "team", title, body});
  try {
    await push(captainUid, title, body);
  } catch (error) {
    logger.warn("Could not tell the captain", {captainUid, error: String(error)});
  }
}
