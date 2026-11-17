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

/** A user whose devices are wanted, with their document when it is read already. */
export interface UserRef {
  uid: string;
  data?: DocumentData;
}

/**
 * The devices: `pushTokens/{token}` = `{uid, updatedAt}`, the token as the
 * id, so a phone belongs to the one account last signed in on it. Only the
 * app of that account writes it, and nobody else can read it.
 */
const DEVICES = "pushTokens";

/** FCM takes at most this many tokens in one multicast. */
const MULTICAST_SIZE = 500;

/** Firestore's `in` takes at most 30 values. */
const IN_SIZE = 30;

/** Documents read in one `getAll`. */
const READ_SIZE = 300;

/** The answers that mean a token is gone for good (app removed, token deleted at sign-out). */
const GONE = new Set([
  "messaging/registration-token-not-registered",
  "messaging/invalid-registration-token",
]);

const isToken = (value: unknown): value is string => typeof value === "string" && value.trim() !== "";

/**
 * The tokens older app versions left on a user's own document: the list
 * `fcmTokens` and the single `fcmToken`, once each. The new app deletes them
 * at its first start.
 */
export function legacyTokensOf(data: DocumentData | undefined): string[] {
  const tokens = new Set<string>();
  const list = data?.fcmTokens;
  if (Array.isArray(list)) list.filter(isToken).forEach((token) => tokens.add(token));
  const single: unknown = data?.fcmToken;
  if (isToken(single)) tokens.add(single);
  return [...tokens];
}

/**
 * Every device of these users, once each: their `pushTokens`, and the tokens
 * still on their documents unless another account has signed in on that
 * device since. Users whose [UserRef.data] is missing are read.
 */
export async function tokensOfUsers(db: Firestore, users: UserRef[]): Promise<string[]> {
  const uids = [...new Set(users.map((user) => user.uid).filter((uid) => uid !== "" && !uid.includes("/")))];
  const owner = new Map<string, string>();
  for (let i = 0; i < uids.length; i += IN_SIZE) {
    const devices = await db.collection(DEVICES).where("uid", "in", uids.slice(i, i + IN_SIZE)).get();
    devices.docs.forEach((doc) => owner.set(doc.id, doc.data().uid));
  }
  const tokens = new Set(owner.keys());

  // The older tokens, each with the uid whose document holds it.
  const known = new Map(users.filter((user) => user.data !== undefined).map((user) => [user.uid, user.data]));
  const unread = uids.filter((uid) => !known.has(uid));
  for (let i = 0; i < unread.length; i += READ_SIZE) {
    const refs = unread.slice(i, i + READ_SIZE).map((uid) => db.collection("users").doc(uid));
    (await db.getAll(...refs)).forEach((doc) => known.set(doc.id, doc.data()));
  }
  const legacy = new Map<string, Set<string>>();
  for (const uid of uids) {
    for (const token of legacyTokensOf(known.get(uid))) {
      if (owner.has(token)) continue;
      legacy.set(token, (legacy.get(token) ?? new Set()).add(uid));
    }
  }

  // An older token is used only while no other account has claimed its device.
  const candidates = [...legacy.keys()];
  for (let i = 0; i < candidates.length; i += READ_SIZE) {
    const refs = candidates.slice(i, i + READ_SIZE).map((token) => db.collection(DEVICES).doc(token));
    for (const doc of await db.getAll(...refs)) {
      const claimedBy: unknown = doc.data()?.uid;
      const holders = legacy.get(doc.id) ?? new Set();
      if (!doc.exists || (typeof claimedBy === "string" && holders.has(claimedBy))) tokens.add(doc.id);
    }
  }
  return [...tokens];
}

/** Every device of one user; their document is read when [data] is not given. */
export function tokensOfUser(db: Firestore, uid: string, data?: DocumentData): Promise<string[]> {
  return tokensOfUsers(db, [{uid, data}]);
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
 * Deletes [tokens]' devices and pulls them off the user documents of older
 * versions. Never throws: a token left behind only costs a failed send later.
 */
export async function forgetTokens(db: Firestore, tokens: string[]): Promise<void> {
  const users = db.collection("users");
  for (const token of new Set(tokens)) {
    try {
      await db.collection(DEVICES).doc(token).delete();
      const [inList, single] = await Promise.all([
        users.where("fcmTokens", "array-contains", token).get(),
        users.where("fcmToken", "==", token).get(),
      ]);
      const holders = new Map([...inList.docs, ...single.docs].map((doc) => [doc.id, doc]));
      await Promise.all([...holders.values()].map((doc) => doc.ref.update({
        fcmTokens: FieldValue.arrayRemove(token),
        ...(doc.data().fcmToken === token ? {fcmToken: ""} : {}),
      })));
    } catch (error) {
      logger.warn("Could not forget a push token", {error: String(error)});
    }
  }
}

/**
 * Sends [message] to its tokens, at most 500 at a time, then forgets the
 * tokens FCM says are gone. Returns the counts.
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
