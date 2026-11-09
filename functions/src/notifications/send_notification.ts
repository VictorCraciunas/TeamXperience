import {Firestore} from "firebase-admin/firestore";
import {getMessaging} from "firebase-admin/messaging";
import * as logger from "firebase-functions/logger";
import {refuse} from "../teams/shared";
import {addToInboxes} from "./inbox";

export interface PushMessage {
  tokens: string[];
  notification: {title: string; body: string};
  data: Record<string, string>;
}

export type SendPush = (message: PushMessage) => Promise<{successCount: number; failureCount: number}>;

export interface NotificationResult {
  recipients: number;
  sent: number;
  failed: number;
}

const sendWithFcm: SendPush = (message) => getMessaging().sendEachForMulticast(message);

function textOf(value: unknown): string {
  return typeof value === "string" ? value.trim() : "";
}

/**
 * An organiser's push: to an event's registered players, or to everyone when
 * no event is named. Anyone else is refused before any user is read.
 */
export async function sendNotification(
  db: Firestore,
  uid: string,
  data: Record<string, unknown>,
  send: SendPush = sendWithFcm,
): Promise<NotificationResult> {
  const caller = await db.collection("users").doc(uid).get();
  if (caller.data()?.role !== "ADMIN") throw refuse("notOrganiser");

  const title = textOf(data.title);
  const description = textOf(data.description);
  const eventId = data.eventId;
  const eventIdOk = eventId === undefined || eventId === null || (typeof eventId === "string" && eventId !== "");
  if (title === "" || description === "" || !eventIdOk) throw refuse("notificationInvalid");

  const users = db.collection("users");
  const recipients = await (eventId ? users.where("registeredEventIds", "array-contains", eventId) : users).get();
  const tokens = recipients.docs
    .map((doc) => doc.data().fcmToken)
    .filter((token): token is string => typeof token === "string" && token.trim() !== "");
  if (tokens.length === 0) throw refuse("noRecipients");

  // Everyone it is meant for keeps it, a player without a token too.
  await addToInboxes(db, recipients.docs.map((doc) => doc.id), {
    kind: "announcement",
    title,
    body: description,
    ...(typeof eventId === "string" ? {eventId} : {}),
  });

  const result = await send({
    tokens,
    notification: {title, body: description},
    data: {title, body: description, timestamp: new Date().toISOString(), type: "admin_notification"},
  });
  logger.info("Notification sent", {
    eventId: eventId ?? null,
    recipients: tokens.length,
    sent: result.successCount,
    failed: result.failureCount,
  });
  return {recipients: tokens.length, sent: result.successCount, failed: result.failureCount};
}
