import * as logger from "firebase-functions/logger";
import {getFirestore} from "firebase-admin/firestore";
import {getMessaging} from "firebase-admin/messaging";

/** Tells the captain someone joined. A failure is only logged. */
export async function notifyCaptain(captainUid: string, displayName: string, crewName: string): Promise<void> {
  try {
    const captain = await getFirestore().collection("users").doc(captainUid).get();
    const token = captain.data()?.fcmToken;
    if (typeof token !== "string" || token === "") return;
    await getMessaging().send({
      token,
      notification: {title: "Echipa ta crește", body: `${displayName} a intrat în ${crewName}`},
    });
  } catch (error) {
    logger.warn("Could not tell the captain", {captainUid, error: String(error)});
  }
}
