import {beforeEach, describe, test} from "node:test";
import * as assert from "node:assert/strict";
import {Firestore, Timestamp} from "firebase-admin/firestore";
import {sendChatPush} from "../chat/chat_push";
import {pushData, pushToUser} from "../notifications/inbox";
import {
  forgetTokens,
  goneTokens,
  legacyTokensOf,
  PushMessage,
  PushResponse,
  sendToDevices,
  tokensOfUser,
  tokensOfUsers,
} from "../notifications/tokens";
import {clearDb, emulatorDb} from "./helpers";

let db: Firestore;
let sent: PushMessage[];

const send = async (message: PushMessage) => {
  sent.push(message);
  return {successCount: message.tokens.length, failureCount: 0};
};

/** FCM saying the tokens in [gone] are not registered any more. */
const sendSaying = (gone: string[]) => async (message: PushMessage) => {
  sent.push(message);
  const responses: PushResponse[] = message.tokens.map((token) => gone.includes(token) ?
    {success: false, error: {code: "messaging/registration-token-not-registered"}} :
    {success: true});
  const failureCount = responses.filter((r) => !r.success).length;
  return {successCount: responses.length - failureCount, failureCount, responses};
};

const userDoc = async (uid: string) => (await db.collection("users").doc(uid).get()).data();

async function seedUser(uid: string, extra: Record<string, unknown> = {}): Promise<void> {
  await db.collection("users").doc(uid).set({uid, role: "USER", ...extra});
}

/** A device signed in to [uid], as the app saves it. */
async function seedDevice(token: string, uid: string): Promise<void> {
  await db.collection("pushTokens").doc(token).set({uid, updatedAt: Timestamp.now()});
}

const sorted = (tokens: string[]) => [...tokens].sort();

describe("the tokens a user doc still holds from older versions", () => {
  test("the list and the single token, once each, blanks left out", () => {
    assert.deepEqual(legacyTokensOf({fcmTokens: ["a", "b", "", 5, "  "], fcmToken: "a"}), ["a", "b"]);
    assert.deepEqual(legacyTokensOf({fcmToken: "old"}), ["old"]);
    assert.deepEqual(legacyTokensOf({fcmTokens: "not a list", fcmToken: " "}), []);
    assert.deepEqual(legacyTokensOf(undefined), []);
  });

  test("only tokens FCM calls gone are dropped, not those that failed for a while", () => {
    const responses: PushResponse[] = [
      {success: true},
      {success: false, error: {code: "messaging/registration-token-not-registered"}},
      {success: false, error: {code: "messaging/internal-error"}},
      {success: false, error: {code: "messaging/invalid-registration-token"}},
    ];
    assert.deepEqual(goneTokens(["a", "b", "c", "d"], responses), ["b", "d"]);
    assert.deepEqual(goneTokens(["a"], undefined), []);
  });

  test("a push's data: its kind, and the event and team when there are any", () => {
    assert.deepEqual(pushData({kind: "results", title: "T", body: "B", eventId: "e1"}), {type: "results", eventId: "e1"});
    assert.deepEqual(pushData({kind: "chat", title: "T", body: "B", eventId: "e1", teamName: "Vulpile"}),
      {type: "chat", eventId: "e1", teamName: "Vulpile"});
    assert.deepEqual(pushData({kind: "team", title: "T", body: "B"}), {type: "team"});
  });
});

describe("a user's devices", () => {
  beforeEach(async () => {
    db = emulatorDb();
    await clearDb();
  });

  test("every device signed in to the user: phone and tablet", async () => {
    await seedDevice("phone", "ana");
    await seedDevice("tablet", "ana");
    await seedDevice("other", "dan");
    assert.deepEqual(sorted(await tokensOfUser(db, "ana")), ["phone", "tablet"]);
  });

  test("an older user's token on their doc still counts, once", async () => {
    await seedDevice("phone", "ana");
    assert.deepEqual(sorted(await tokensOfUser(db, "ana", {fcmTokens: ["phone", "old-tablet"], fcmToken: "phone"})),
      ["old-tablet", "phone"]);
  });

  test("Rareș's case: the phone signs out of the organiser and in as Rareș", async () => {
    // Signed in as the organiser, the phone was saved for them...
    await seedDevice("rares-phone", "admin");
    await seedUser("admin", {role: "ADMIN", fcmToken: "rares-phone"});
    // ...then signed in as Rareș: the same token now belongs to him.
    await seedDevice("rares-phone", "rares");
    assert.deepEqual(await tokensOfUser(db, "admin", await userDoc("admin")), []);
    assert.deepEqual(await tokensOfUser(db, "rares"), ["rares-phone"]);
  });

  test("a token left on an older doc but claimed by someone else is not used", async () => {
    await seedDevice("shared", "rares");
    assert.deepEqual(await tokensOfUser(db, "admin", {fcmToken: "shared", fcmTokens: ["shared"]}), []);
  });

  test("many users at once, past Firestore's 30 per query", async () => {
    const uids = Array.from({length: 31}, (_, i) => `p${i}`);
    for (const uid of uids) await seedDevice(`t-${uid}`, uid);
    const tokens = await tokensOfUsers(db, uids.map((uid) => ({uid})));
    assert.equal(tokens.length, 31);
  });

  test("forgetting a token deletes its device and pulls it off older docs", async () => {
    await seedDevice("dead", "ana");
    await seedUser("ana", {fcmTokens: ["dead", "live"], fcmToken: "dead"});
    await forgetTokens(db, ["dead", "nobody"]);
    assert.equal((await db.collection("pushTokens").doc("dead").get()).exists, false);
    const ana = await userDoc("ana");
    assert.deepEqual(ana?.fcmTokens, ["live"]);
    assert.equal(ana?.fcmToken, "");
  });
});

describe("pushes to every device", () => {
  beforeEach(async () => {
    db = emulatorDb();
    await clearDb();
    sent = [];
  });

  test("one player's push reaches their phone and tablet, with its data", async () => {
    await seedUser("ana");
    await seedDevice("phone", "ana");
    await seedDevice("tablet", "ana");
    await pushToUser(db, "ana", "Rezultate", "Locul 1", {type: "results", eventId: "e1"}, send);
    assert.equal(sent.length, 1);
    assert.deepEqual(sorted(sent[0].tokens), ["phone", "tablet"]);
    assert.deepEqual(sent[0].notification, {title: "Rezultate", body: "Locul 1"});
    assert.deepEqual(sent[0].data, {type: "results", eventId: "e1"});
  });

  test("an older user with only the single token still gets it; one with none gets nothing", async () => {
    await seedUser("old", {fcmToken: "legacy"});
    await seedUser("none");
    await pushToUser(db, "old", "T", "B", {}, send);
    await pushToUser(db, "none", "T", "B", {}, send);
    assert.deepEqual(sent.map((m) => m.tokens), [["legacy"]]);
  });

  test("a token FCM calls gone is deleted, as a device and on the older doc", async () => {
    await seedUser("ana", {fcmToken: "dead-old"});
    await seedDevice("phone", "ana");
    await seedDevice("dead", "ana");
    await pushToUser(db, "ana", "T", "B", {}, sendSaying(["dead", "dead-old"]));
    assert.equal((await db.collection("pushTokens").doc("dead").get()).exists, false);
    assert.equal((await db.collection("pushTokens").doc("phone").get()).exists, true);
    assert.equal((await userDoc("ana"))?.fcmToken, "");
  });

  test("more than 500 devices go in several sends", async () => {
    const tokens = Array.from({length: 501}, (_, i) => `t${i}`);
    const result = await sendToDevices(db, {tokens, notification: {title: "T", body: "B"}, data: {}}, send);
    assert.deepEqual(sent.map((m) => m.tokens.length), [500, 1]);
    assert.deepEqual(result, {successCount: 501, failureCount: 0});
  });
});

describe("chat pushes", () => {
  beforeEach(async () => {
    db = emulatorDb();
    await clearDb();
    sent = [];
    await seedUser("boss", {role: "ADMIN"});
    await seedDevice("boss-phone", "boss");
    await seedDevice("boss-tablet", "boss");
    await seedUser("ana", {fcmToken: "ana-old"});
    await seedDevice("ana-phone", "ana");
    await seedUser("dan", {fcmToken: "dan-phone"});
    await seedUser("ion");
    await seedDevice("ion-phone", "ion");
    await db.doc("events/e1/teams/Vulpile").set({name: "Vulpile", userIds: ["ana", "dan"]});
  });

  test("the organiser's message reaches every device of the team, and opens its chat", async () => {
    await sendChatPush(db, "e1", "Vulpile", {sender: "ADMIN", text: "Salut"}, send);
    assert.equal(sent.length, 1);
    assert.deepEqual(sorted(sent[0].tokens), ["ana-old", "ana-phone", "dan-phone"]);
    assert.deepEqual(sent[0].data, {type: "chat_message", eventId: "e1", teamName: "Vulpile"});
    assert.deepEqual(sent[0].notification, {title: "Mesaj nou de la Admin", body: "Salut"});
    const inbox = await db.collection("users").doc("ana").collection("notifications").get();
    assert.equal(inbox.size, 1);
  });

  test("a player's message reaches every organiser device", async () => {
    await sendChatPush(db, "e1", "Vulpile", {sender: "USER", text: "x".repeat(150)}, send);
    assert.deepEqual(sorted(sent[0].tokens), ["boss-phone", "boss-tablet"]);
    assert.equal(sent[0].notification.title, "Mesaj nou de la echipa Vulpile");
    assert.equal(sent[0].notification.body.length, 103);
    assert.deepEqual(sent[0].data, {type: "chat_message", eventId: "e1", teamName: "Vulpile"});
  });

  test("an organiser's phone now signed in as a player gets the player's chat, not the organisers'", async () => {
    await seedDevice("boss-tablet", "ion");
    await sendChatPush(db, "e1", "Vulpile", {sender: "USER", text: "Alo"}, send);
    assert.deepEqual(sent[0].tokens, ["boss-phone"]);
  });

  test("an announcement's copy or a moved message sends nothing", async () => {
    await sendChatPush(db, "e1", "Vulpile", {sender: "ADMIN", text: "A", announcement: true}, send);
    await sendChatPush(db, "e1", "Vulpile", {sender: "ADMIN", text: "A", moved: true}, send);
    assert.equal(sent.length, 0);
  });

  test("a team that is gone sends nothing", async () => {
    await sendChatPush(db, "e1", "Nimeni", {sender: "ADMIN", text: "A"}, send);
    assert.equal(sent.length, 0);
  });
});
