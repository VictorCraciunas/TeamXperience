import {beforeEach, describe, test} from "node:test";
import * as assert from "node:assert/strict";
import {Firestore} from "firebase-admin/firestore";
import {sendChatPush} from "../chat/chat_push";
import {pushData, pushToUser} from "../notifications/inbox";
import {
  claimTokens,
  forgetTokens,
  goneTokens,
  PushMessage,
  PushResponse,
  sendToDevices,
  tokensOf,
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

describe("a user's devices", () => {
  test("the list and the older single token, once each, blanks left out", () => {
    assert.deepEqual(tokensOf({fcmTokens: ["a", "b", "", 5, "  "], fcmToken: "a"}), ["a", "b"]);
    assert.deepEqual(tokensOf({fcmToken: "old"}), ["old"]);
    assert.deepEqual(tokensOf({fcmTokens: "not a list", fcmToken: " "}), []);
    assert.deepEqual(tokensOf(undefined), []);
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

describe("pushes to every device", () => {
  beforeEach(async () => {
    db = emulatorDb();
    await clearDb();
    sent = [];
  });

  test("one player's push reaches their phone and tablet, with its data", async () => {
    await seedUser("ana", {fcmTokens: ["phone", "tablet"], fcmToken: "phone"});
    await pushToUser(db, "ana", "Rezultate", "Locul 1", {type: "results", eventId: "e1"}, send);
    assert.equal(sent.length, 1);
    assert.deepEqual([...sent[0].tokens].sort(), ["phone", "tablet"]);
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

  test("a token FCM calls gone comes off the user, the list and the single one", async () => {
    await seedUser("ana", {fcmTokens: ["phone", "dead"], fcmToken: "dead"});
    await pushToUser(db, "ana", "T", "B", {}, sendSaying(["dead"]));
    const ana = await userDoc("ana");
    assert.deepEqual(ana?.fcmTokens, ["phone"]);
    assert.equal(ana?.fcmToken, "");
  });

  test("more than 500 devices go in several sends", async () => {
    const tokens = Array.from({length: 501}, (_, i) => `t${i}`);
    const result = await sendToDevices(db, {tokens, notification: {title: "T", body: "B"}, data: {}}, send);
    assert.deepEqual(sent.map((m) => m.tokens.length), [500, 1]);
    assert.deepEqual(result, {successCount: 501, failureCount: 0});
  });
});

describe("one device, one account", () => {
  beforeEach(async () => {
    db = emulatorDb();
    await clearDb();
  });

  test("a token another account gains comes off the one that had it", async () => {
    // Rareș's phone was signed in as the organiser, then as Rareș.
    await seedUser("admin", {role: "ADMIN", fcmTokens: ["rares-phone", "office"], fcmToken: "rares-phone"});
    await seedUser("rares", {fcmTokens: ["rares-phone"], fcmToken: "rares-phone"});
    await claimTokens(db, "rares", {fcmTokens: []}, await userDoc("rares"));
    const admin = await userDoc("admin");
    assert.deepEqual(admin?.fcmTokens, ["office"]);
    assert.equal(admin?.fcmToken, "");
    assert.deepEqual((await userDoc("rares"))?.fcmTokens, ["rares-phone"]);
  });

  test("an older account holding it only as the single token loses it too", async () => {
    await seedUser("old", {fcmToken: "shared"});
    await claimTokens(db, "new", undefined, {fcmTokens: ["shared"]});
    assert.equal((await userDoc("old"))?.fcmToken, "");
  });

  test("a write that gains no token changes nobody", async () => {
    await seedUser("admin", {fcmTokens: ["t"]});
    await claimTokens(db, "ana", {fcmTokens: ["t"], xp: 1}, {fcmTokens: ["t"], xp: 2});
    assert.deepEqual((await userDoc("admin"))?.fcmTokens, ["t"]);
  });

  test("forgetting a token nobody has does no harm", async () => {
    await forgetTokens(db, ["nobody"]);
  });
});

describe("chat pushes", () => {
  beforeEach(async () => {
    db = emulatorDb();
    await clearDb();
    sent = [];
    await seedUser("boss", {role: "ADMIN", fcmTokens: ["boss-phone", "boss-tablet"]});
    await seedUser("ana", {fcmTokens: ["ana-phone"], fcmToken: "ana-old"});
    await seedUser("dan", {fcmToken: "dan-phone"});
    await seedUser("ion", {fcmTokens: ["ion-phone"]});
    await db.doc("events/e1/teams/Vulpile").set({name: "Vulpile", userIds: ["ana", "dan"]});
  });

  test("the organiser's message reaches every device of the team, and opens its chat", async () => {
    await sendChatPush(db, "e1", "Vulpile", {sender: "ADMIN", text: "Salut"}, send);
    assert.equal(sent.length, 1);
    assert.deepEqual([...sent[0].tokens].sort(), ["ana-old", "ana-phone", "dan-phone"]);
    assert.deepEqual(sent[0].data, {type: "chat_message", eventId: "e1", teamName: "Vulpile"});
    assert.deepEqual(sent[0].notification, {title: "Mesaj nou de la Admin", body: "Salut"});
    const inbox = await db.collection("users").doc("ana").collection("notifications").get();
    assert.equal(inbox.size, 1);
  });

  test("a player's message reaches every organiser device", async () => {
    await sendChatPush(db, "e1", "Vulpile", {sender: "USER", text: "x".repeat(150)}, send);
    assert.deepEqual([...sent[0].tokens].sort(), ["boss-phone", "boss-tablet"]);
    assert.equal(sent[0].notification.title, "Mesaj nou de la echipa Vulpile");
    assert.equal(sent[0].notification.body.length, 103);
    assert.deepEqual(sent[0].data, {type: "chat_message", eventId: "e1", teamName: "Vulpile"});
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
