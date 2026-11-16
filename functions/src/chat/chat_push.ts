import {DocumentData, Firestore} from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import {addToInboxes, chatInboxItem} from "../notifications/inbox";
import {SendPush, sendToDevices, sendWithFcm, tokensOfAll} from "../notifications/tokens";
import {sendsPush} from "./sends_push";

const PREVIEW_LENGTH = 100;

/** Firestore's `in` takes at most 30 values. */
const IN_SIZE = 30;

/**
 * A new chat message: the organiser's reaches every device of the team's
 * players (and their notification lists); a player's reaches every
 * organiser's devices. The push carries `{type: "chat_message", eventId,
 * teamName}`, which the app opens as that team's chat.
 */
export async function sendChatPush(
  db: Firestore,
  eventId: string,
  teamName: string,
  message: DocumentData,
  send: SendPush = sendWithFcm,
): Promise<void> {
  if (!sendsPush(message)) return;
  const fromOrganiser = message.sender === "ADMIN";
  const text = message.text;

  let tokens: string[];
  if (fromOrganiser) {
    const team = await db.collection("events").doc(eventId).collection("teams").doc(teamName).get();
    if (!team.exists) {
      logger.warn("Team document not found", {eventId, teamName});
      return;
    }
    const userIds: string[] = team.data()?.userIds ?? [];
    // Kept in each player's list, whether or not their phone gets the push.
    await addToInboxes(db, userIds, chatInboxItem(eventId, teamName, text));
    const docs = [];
    for (let i = 0; i < userIds.length; i += IN_SIZE) {
      const batch = userIds.slice(i, i + IN_SIZE);
      docs.push(...(await db.collection("users").where("uid", "in", batch).get()).docs);
    }
    tokens = tokensOfAll(docs);
  } else {
    tokens = tokensOfAll((await db.collection("users").where("role", "==", "ADMIN").get()).docs);
  }
  if (tokens.length === 0) {
    logger.info("No valid FCM tokens found for notification");
    return;
  }

  const words = typeof text === "string" ? text : "";
  const body = words.length > PREVIEW_LENGTH ? words.substring(0, PREVIEW_LENGTH) + "..." : words;
  const result = await sendToDevices(db, {
    tokens,
    notification: {
      title: fromOrganiser ? "Mesaj nou de la Admin" : `Mesaj nou de la echipa ${teamName}`,
      body,
    },
    data: {type: "chat_message", eventId, teamName},
    android: {priority: "high", notification: {channelId: "chat_notifications"}},
  }, send);
  logger.info("Chat notification sent", {
    totalTokens: tokens.length,
    successCount: result.successCount,
    failureCount: result.failureCount,
  });
}
