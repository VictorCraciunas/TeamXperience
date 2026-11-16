import {DocumentData, FieldValue, Firestore} from "firebase-admin/firestore";
import {getMessaging} from "firebase-admin/messaging";
import * as logger from "firebase-functions/logger";

/** One push to many devices, as FCM's multicast takes it. Data values are text. */
export interface PushMessage {
  tokens: string[];
  notification: {title: string; body: string};
  data: Record<string, string>;
  android?: {priority: "high"; notification: {channelId: string}};
}

/** FCM's answer for one device, in the order of the tokens. */
export interface PushResponse {
  success: boolean;
  error?: {code?: string};
}

export type SendPush = (message: PushMessage) => Promise<{
  successCount: number;
  failureCount: number;
  responses?: PushResponse[];
}>;

export const sendWithFcm: SendPush = (message) => getMessaging().sendEachForMulticast(message);

/** FCM takes at most this many tokens in one multicast. */
const MULTICAST_SIZE = 500;

/** The answers that mean a token is gone for good (app removed, token deleted at sign-out). */
const GONE = new Set([
  "messaging/registration-token-not-registered",
  "messaging/invalid-registration-token",
]);

const isToken = (value: unknown): value is string => typeof value === "string" && value.trim() !== "";

/**
 * Every device a user's pushes go to: the list `fcmTokens` (one per phone or
 * tablet) and the older single `fcmToken`, once each.
 */
export function tokensOf(data: DocumentData | undefined): string[] {
  const tokens = new Set<string>();
  const list = data?.fcmTokens;
  if (Array.isArray(list)) list.filter(isToken).forEach((token) => tokens.add(token));
  const single: unknown = data?.fcmToken;
  if (isToken(single)) tokens.add(single);
  return [...tokens];
}

/** The devices of all these users, once each (one phone may hold two accounts' tokens). */
export function tokensOfAll(docs: Array<{data(): DocumentData | undefined}>): string[] {
  return [...new Set(docs.flatMap((doc) => tokensOf(doc.data())))];
}

/** The tokens FCM said no longer exist. */
export function goneTokens(tokens: string[], responses: PushResponse[] | undefined): string[] {
  if (!responses) return [];
  return tokens.filter((_, i) => {
    const response = responses[i];
    return response !== undefined && !response.success && GONE.has(response.error?.code ?? "");
  });
}

/**
 * Takes [tokens] off every user who holds them, except [keepUid]. Never
 * throws: a list left as it is only costs a failed send later.
 */
export async function forgetTokens(db: Firestore, tokens: string[], keepUid?: string): Promise<void> {
  const users = db.collection("users");
  for (const token of new Set(tokens)) {
    try {
      const [inList, single] = await Promise.all([
        users.where("fcmTokens", "array-contains", token).get(),
        users.where("fcmToken", "==", token).get(),
      ]);
      const holders = new Map([...inList.docs, ...single.docs].map((doc) => [doc.id, doc]));
      await Promise.all([...holders.values()]
        .filter((doc) => doc.id !== keepUid)
        .map((doc) => doc.ref.update({
          fcmTokens: FieldValue.arrayRemove(token),
          ...(doc.data().fcmToken === token ? {fcmToken: ""} : {}),
        })));
    } catch (error) {
      logger.warn("Could not take a push token off its users", {error: String(error)});
    }
  }
}

/**
 * Sends [message] to its tokens, at most 500 at a time, then takes the tokens
 * FCM says are gone off their users. Returns the counts.
 */
export async function sendToDevices(
  db: Firestore,
  message: PushMessage,
  send: SendPush = sendWithFcm,
): Promise<{successCount: number; failureCount: number}> {
  let successCount = 0;
  let failureCount = 0;
  const gone: string[] = [];
  for (let i = 0; i < message.tokens.length; i += MULTICAST_SIZE) {
    const tokens = message.tokens.slice(i, i + MULTICAST_SIZE);
    const result = await send({...message, tokens});
    successCount += result.successCount;
    failureCount += result.failureCount;
    gone.push(...goneTokens(tokens, result.responses));
  }
  if (gone.length > 0) await forgetTokens(db, gone);
  return {successCount, failureCount};
}

/**
 * A user's document changed: a token it gained belongs to this user only now,
 * so it comes off anyone else (the phone's previous account, signed out
 * before sign-out cleaned up after itself).
 */
export async function claimTokens(
  db: Firestore,
  uid: string,
  before: DocumentData | undefined,
  after: DocumentData | undefined,
): Promise<void> {
  // Each field on its own: an older user whose single token moves into the
  // list gains it too, so the account it was left on loses it at the
  // first start of the new app.
  const listOf = (data: DocumentData | undefined) => tokensOf({fcmTokens: data?.fcmTokens});
  const singleOf = (data: DocumentData | undefined) => tokensOf({fcmToken: data?.fcmToken});
  const hadList = new Set(listOf(before));
  const hadSingle = new Set(singleOf(before));
  const gained = [
    ...listOf(after).filter((token) => !hadList.has(token)),
    ...singleOf(after).filter((token) => !hadSingle.has(token)),
  ];
  if (gained.length > 0) await forgetTokens(db, gained, uid);
}
