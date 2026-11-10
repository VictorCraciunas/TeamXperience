import {DocumentData, FieldValue, Firestore} from "firebase-admin/firestore";
import {getMessaging} from "firebase-admin/messaging";
import * as logger from "firebase-functions/logger";

/** What a notification is about, which decides its icon and where a tap goes. */
export type InboxKind = "announcement" | "chat" | "team" | "results";

export interface InboxItem {
  kind: InboxKind;
  title: string;
  body: string;
  eventId?: string;
  teamName?: string;
}

const BATCH_SIZE = 400;
const CHAT_LENGTH = 100;

const isDocId = (value: string): boolean => value !== "" && !value.includes("/");

/** The stored form of [item]: unread, with the server's time. */
export function inboxEntry(item: InboxItem): DocumentData {
  return {
    kind: item.kind,
    title: item.title,
    body: item.body,
    ...(item.eventId ? {eventId: item.eventId} : {}),
    ...(item.teamName ? {teamName: item.teamName} : {}),
    read: false,
    createdAt: FieldValue.serverTimestamp(),
  };
}

/**
 * Adds [item] to each player's list (`users/{uid}/notifications`). Never
 * throws: a list that cannot be written must not stop the push or the work
 * it belongs to.
 */
export async function addToInboxes(db: Firestore, uids: string[], item: InboxItem): Promise<void> {
  try {
    const ids = [...new Set(uids.filter(isDocId))];
    for (let i = 0; i < ids.length; i += BATCH_SIZE) {
      const batch = db.batch();
      for (const uid of ids.slice(i, i + BATCH_SIZE)) {
        batch.set(db.collection("users").doc(uid).collection("notifications").doc(), inboxEntry(item));
      }
      await batch.commit();
    }
  } catch (error) {
    logger.warn("Could not add to the notification lists", {kind: item.kind, error: String(error)});
  }
}

/** One push to one player's phone, when it has a token. Never throws. */
export async function pushToUser(db: Firestore, uid: string, title: string, body: string): Promise<void> {
  try {
    const token = (await db.collection("users").doc(uid).get()).data()?.fcmToken;
    if (typeof token !== "string" || token.trim() === "") return;
    await getMessaging().send({token, notification: {title, body}});
  } catch (error) {
    logger.warn("Could not send a push", {uid, error: String(error)});
  }
}

/** An organiser's chat message, for the list of each player in the team. */
export function chatInboxItem(eventId: string, teamName: string, text: unknown): InboxItem {
  const words = typeof text === "string" ? text.trim() : "";
  const body = words === "" ?
    "A trimis o poză." :
    words.length > CHAT_LENGTH ? words.substring(0, CHAT_LENGTH) + "..." : words;
  return {kind: "chat", title: "Mesaj de la organizator", body, eventId, teamName};
}
