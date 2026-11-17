import {beforeEach, describe, test} from "node:test";
import * as assert from "node:assert/strict";
import {Firestore} from "firebase-admin/firestore";
import {PushMessage, sendNotification} from "../notifications/send_notification";
import {clearDb, emulatorDb, reasonOf} from "./helpers";

let db: Firestore;
let sent: PushMessage[];

const send = async (message: PushMessage) => {
  sent.push(message);
  return {successCount: message.tokens.length, failureCount: 0};
};

async function seedUser(uid: string, extra: Record<string, unknown> = {}): Promise<void> {
  await db.collection("users").doc(uid).set({uid, role: "USER", ...extra});
}

const NEWS = {title: "Start", description: "Ne vedem la 18"};

describe("sendNotification", () => {
  beforeEach(async () => {
    db = emulatorDb();
    await clearDb();
    sent = [];
    await seedUser("boss", {role: "ADMIN", fcmToken: "t-boss"});
    await seedUser("ana", {fcmToken: "t-ana", registeredEventIds: ["e1"]});
    await seedUser("dan", {fcmToken: "t-dan", registeredEventIds: ["e2"]});
  });

  test("a player cannot send, and nothing goes out", async () => {
    await assert.rejects(sendNotification(db, "ana", NEWS, send), (e) => reasonOf(e) === "notOrganiser");
    assert.equal(sent.length, 0);
  });

  test("a signed-in user with no document cannot send", async () => {
    await assert.rejects(sendNotification(db, "ghost", NEWS, send), (e) => reasonOf(e) === "notOrganiser");
    assert.equal(sent.length, 0);
  });

  test("an organiser reaches everyone with a token", async () => {
    await seedUser("empty", {fcmToken: "  "});
    await seedUser("none");
    const result = await sendNotification(db, "boss", NEWS, send);
    assert.deepEqual([...sent[0].tokens].sort(), ["t-ana", "t-boss", "t-dan"]);
    assert.deepEqual(result, {recipients: 3, sent: 3, failed: 0});
  });

  test("an event's notification reaches only its players", async () => {
    await sendNotification(db, "boss", {...NEWS, eventId: "e1"}, send);
    assert.deepEqual(sent[0].tokens, ["t-ana"]);
  });

  test("every device of a player, once, and the older single token too", async () => {
    await seedUser("eva", {fcmToken: "t-eva-phone", registeredEventIds: ["e1"]});
    for (const token of ["t-eva-phone", "t-eva-tablet"]) {
      await db.collection("pushTokens").doc(token).set({uid: "eva", updatedAt: new Date()});
    }
    await sendNotification(db, "boss", {...NEWS, eventId: "e1"}, send);
    assert.deepEqual([...sent[0].tokens].sort(), ["t-ana", "t-eva-phone", "t-eva-tablet"]);
  });

  test("a phone now signed in to another account is not reached for the old one", async () => {
    // Ana's old doc still says t-ana, but Dan signed in on that phone since.
    await db.collection("pushTokens").doc("t-ana").set({uid: "dan", updatedAt: new Date()});
    await sendNotification(db, "boss", {...NEWS, eventId: "e2"}, send);
    assert.deepEqual([...sent[0].tokens].sort(), ["t-ana", "t-dan"]);
    await sendNotification(db, "boss", {...NEWS, eventId: "e1"}, send).catch(() => undefined);
    assert.equal(sent.length, 1);
  });

  test("an event's push says so in its data, for the app to open the event", async () => {
    await sendNotification(db, "boss", {...NEWS, eventId: "e1"}, send);
    assert.equal(sent[0].data.type, "admin_notification");
    assert.equal(sent[0].data.eventId, "e1");
    await sendNotification(db, "boss", NEWS, send);
    assert.equal(sent[1].data.type, "admin_notification");
    assert.equal("eventId" in sent[1].data, false);
    for (const value of Object.values(sent[0].data)) assert.equal(typeof value, "string");
  });

  test("the message carries the trimmed title and text", async () => {
    await sendNotification(db, "boss", {title: "  Start ", description: " Ne vedem "}, send);
    assert.deepEqual(sent[0].notification, {title: "Start", body: "Ne vedem"});
  });

  test("a missing or blank title or text is refused", async () => {
    for (const input of [{description: "x"}, {title: "x"}, {title: " ", description: "x"}, {title: 5, description: "x"}]) {
      await assert.rejects(sendNotification(db, "boss", input, send), (e) => reasonOf(e) === "notificationInvalid");
    }
    assert.equal(sent.length, 0);
  });

  test("an empty or non-text event id is refused rather than reaching everyone", async () => {
    for (const eventId of ["", 0, false, 7]) {
      await assert.rejects(
        sendNotification(db, "boss", {...NEWS, eventId}, send),
        (e) => reasonOf(e) === "notificationInvalid",
      );
    }
    assert.equal(sent.length, 0);
  });

  test("nobody to reach is said plainly", async () => {
    await assert.rejects(
      sendNotification(db, "boss", {...NEWS, eventId: "nobody"}, send),
      (e) => reasonOf(e) === "noRecipients",
    );
    assert.equal(sent.length, 0);
  });

  test("everyone it reaches has it in their list, a player without a token too", async () => {
    await seedUser("silent", {registeredEventIds: ["e1"]});
    await sendNotification(db, "boss", {...NEWS, eventId: "e1"}, send);
    const listOf = async (uid: string) =>
      (await db.collection("users").doc(uid).collection("notifications").get()).docs.map((d) => d.data());
    for (const uid of ["ana", "silent"]) {
      const [entry] = await listOf(uid);
      assert.deepEqual(
        {kind: entry.kind, title: entry.title, body: entry.body, eventId: entry.eventId, read: entry.read},
        {kind: "announcement", title: "Start", body: "Ne vedem la 18", eventId: "e1", read: false},
      );
    }
    assert.equal((await listOf("dan")).length, 0);
  });

  test("nobody with a token: refused, and nothing is kept", async () => {
    await db.collection("users").doc("lone").set({uid: "lone", role: "USER", registeredEventIds: ["e9"]});
    await assert.rejects(sendNotification(db, "boss", {...NEWS, eventId: "e9"}, send), (e) => reasonOf(e) === "noRecipients");
    assert.equal((await db.collection("users").doc("lone").collection("notifications").get()).size, 0);
  });

  test("failed sends are counted", async () => {
    const half = async (message: PushMessage) => ({successCount: message.tokens.length - 1, failureCount: 1});
    assert.deepEqual(await sendNotification(db, "boss", NEWS, half), {recipients: 3, sent: 2, failed: 1});
  });
});
