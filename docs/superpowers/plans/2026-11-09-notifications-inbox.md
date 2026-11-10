# Notifications Inbox Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the bell on Acasă open a page of the player's notifications, stored per player by the Cloud Functions, with a red dot for unread ones.

**Architecture:** One small server module writes entries to `users/{uid}/notifications`, and each function that sends a push also calls it. The app streams that collection into a new `notifications` feature. Which group a row falls in and where a tap goes are pure functions.

**Tech Stack:** TypeScript Cloud Functions (firebase-functions 4.9 v2, Node 22), Firestore emulator tests, Flutter, provider.

**Spec:** `docs/superpowers/specs/2026-11-09-notifications-inbox-design.md`

## Global Constraints

- Branch `redesign/notifications`, cut from `redesign/mockups`. Merge with `--no-ff` into `redesign/mockups`.
- Never push. Never run `firebase deploy` (no `--dry-run` either). Install nothing. Don't upgrade `firebase-functions`.
- Lighter testing: tests first for logic and data; one overflow check per screen; no exact size or colour tests; full suite before merging; a final review of the whole branch.
- Follow `CLAUDE.md`: no `x!` in new code, one widget per file, screens stay thin, colours from `context.colors`. App text at least 12 px, main controls 44 px (`test/ui/readable_sizes_test.dart`). Section titles are plain text.
- Add a rule and a test for any new client write (`firestore.rules`, `functions/src/test/rules.emu.test.ts`).
- Keep each file's line endings; many are CRLF.
- Copy is Romanian and exactly as in the spec.
- End every commit message with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- App tests: `flutter test --timeout 60s --reporter expanded <path>`. Functions and rules tests: `npm --prefix functions test` (reuses the emulator on 127.0.0.1:8080).

## Review Focus

1. Writing the list fails: the push, the sign-up, the join or the results still complete, and it's only logged. Tests in Tasks 1 and 2.
2. Results worked out twice, or resumed after a crash: one list entry and one push per player. Test in Task 2.
3. A player with no push token still gets a list entry; an organiser's push with no tokens at all still refuses as today and stores nothing. Test in Task 1.
4. A tap whose target is gone (event not loaded, no memory, no team, a read fails): the row is marked read and nothing throws. Test in Task 3.
5. A malformed or unknown entry from a later app version: it still shows, with a plain bell icon. Test in Task 3.

---

### Task 1: The list on the server

**Files:**
- Create: `functions/src/notifications/inbox.ts`
- Modify: `functions/src/notifications/send_notification.ts`, `functions/src/index.ts`, `functions/src/teams/notify.ts`, `firestore.rules`, `functions/src/test/notifications.emu.test.ts`, `functions/src/test/rules.emu.test.ts`, `functions/src/test/teams.emu.test.ts`, `docs/data-model.md`, `docs/services-and-backend.md`

**Interfaces:**
- Produces, in `inbox.ts`:
  - `type InboxKind = "announcement" | "chat" | "team" | "results"`
  - `interface InboxItem {kind: InboxKind; title: string; body: string; eventId?: string; teamName?: string}`
  - `inboxEntry(item: InboxItem): DocumentData`: the item plus `read: false` and `createdAt: FieldValue.serverTimestamp()`; optional keys left out when absent
  - `addToInboxes(db: Firestore, uids: string[], item: InboxItem): Promise<void>`: skips empty ids, batches of 400, catches and logs every failure, never throws
  - `pushToUser(db: Firestore, uid: string, title: string, body: string): Promise<void>`: reads the token, sends one push, catches and logs, never throws
  - `chatInboxItem(eventId: string, teamName: string, text: unknown): InboxItem`: body cut at 100 characters as today, `A trimis o poză.` when the text is empty or not a string

- [ ] **Step 1: Create the branch**

```bash
git switch -c redesign/notifications redesign/mockups
git add docs/superpowers/specs/2026-11-09-notifications-inbox-design.md docs/superpowers/plans/2026-11-09-notifications-inbox.md
```

- [ ] **Step 2: Write the failing tests**

In `notifications.emu.test.ts`:

```ts
describe("the notification list", () => {
  test("an organiser's push reaches the list of everyone it was sent to, even with no token", ...);
  // users u1 (token, registered), u2 (no token, registered), u3 (token, not registered): with eventId,
  // u1 and u2 each have one entry {kind: "announcement", title, body, read: false, eventId}; u3 has none
  test("no tokens at all still refuses, and stores nothing", ...);
  test("a list that cannot be written does not stop the push", ...); // addToInboxes with a closed-over failing db never rejects
  test("skips empty ids", ...);
  test("writes more than one batch", ...); // 450 uids, all stored
});
test("a chat entry: cut at 100, and a picture has its own line", () => {
  assert.equal(chatInboxItem("e", "T", "x".repeat(150)).body.length, 103);
  assert.equal(chatInboxItem("e", "T", undefined).body, "A trimis o poză.");
  assert.deepEqual(chatInboxItem("e", "T", "Salut"), {kind: "chat", title: "Mesaj de la organizator", body: "Salut", eventId: "e", teamName: "T"});
});
```

In `teams.emu.test.ts`: a join writes `{kind: "team", title: "Echipa ta crește", body: "<name> a intrat în <crew>"}` to the captain's list, using the real `notifyCaptain` with a push that fails.

In `rules.emu.test.ts`, under `users`:

```ts
test("notifications: your own, and only read may change", async () => {
  await assertSucceeds(me.doc(NOTE).get());
  await assertFails(other.doc(NOTE).get());
  await assertSucceeds(me.doc(NOTE).update({read: true}));
  await assertFails(me.doc(NOTE).update({read: false}));
  await assertFails(me.doc(NOTE).update({title: "x"}));
  await assertFails(me.doc(NOTE).update({read: true, title: "x"}));
  await assertFails(me.doc(NEW_NOTE).set({title: "x"}));
  await assertFails(me.doc(NOTE).delete());
  await assertFails(admin.doc(NOTE).update({read: true}));
});
```

Use the file's existing helpers for the signed-in contexts and seeding.

- [ ] **Step 3: Run and watch them fail**

Run: `npm --prefix functions test`. Expected: the new tests fail, because `inbox.ts` doesn't exist.

- [ ] **Step 4: Implement**

- `inbox.ts` as above.
- `send_notification.ts`: after the `noRecipients` check, `await addToInboxes(db, recipients.docs.map((d) => d.id), {kind: "announcement", title, body: description, ...(eventId ? {eventId} : {})})`.
- `index.ts`, in the `senderRole === "ADMIN"` branch: right after `userIds` is read, and before the "no tokens" return, `await addToInboxes(db, userIds, chatInboxItem(eventId, teamName, messageText))`. `sendsPush` already stops "Anunț" copies first, so nothing is stored twice. Guard the current `messageText.length` so a picture message doesn't throw.
- `notify.ts`: `notifyCaptain` calls `addToInboxes` first, then pushes as today.
- `firestore.rules`, inside `match /users/{uid}`:

```
// Written only by the functions; a player can only mark their own as read.
match /notifications/{id} {
  allow read: if request.auth.uid == uid;
  allow update: if request.auth.uid == uid
    && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['read'])
    && request.resource.data.read == true;
  allow create, delete: if false;
}
```

- [ ] **Step 5: Run and watch them pass**

Run: `npm --prefix functions test`. Expected: exit 0.

- [ ] **Step 6: Document and commit**

Add the collection to `docs/data-model.md` and `inbox.ts` to `docs/services-and-backend.md`.

```bash
git add functions/src firestore.rules docs
git commit -m "A notification list per player, on the server"
```

### Task 2: Results and crew sign-up notifications

**Files:**
- Modify: `functions/src/results/apply_results.ts`, `functions/src/teams/register_team.ts`, `functions/src/test/results.emu.test.ts`, `functions/src/test/teams.emu.test.ts`, `docs/services-and-backend.md`

**Interfaces:**
- Consumes: `inboxEntry`, `addToInboxes`, `pushToUser`.
- Produces:
  - `ApplyOptions` gains `push?: (uid: string, title: string, body: string) => Promise<void>`, default `pushToUser` with the same `db`
  - `applyPlayer` returns `Promise<boolean>`: true when this run counted the player
  - `registerTeam` gains a last parameter `tell?: (uids: string[], item: InboxItem) => Promise<void>`
  - `shortDate(date: Date): string` in `functions/src/teams/shared.ts`: `14 nov`, Bucharest time, using `ian feb mar apr mai iun iul aug sep oct nov dec`

- [ ] **Step 1: Write the failing tests**

```ts
// results.emu.test.ts
test("a player's results reach their list and their phone, once", async () => {
  const pushed: string[] = [];
  const push = async (uid: string) => { pushed.push(uid); };
  await applyResults(db, "e1", {push});
  await applyResults(db, "e1", {push}); // again: nothing new
  const list = await db.collection("users/u1/notifications").get();
  assert.equal(list.size, 1);
  assert.deepEqual(pick(list.docs[0].data()), {kind: "results", title: "Rezultatele sunt gata", body: "Echipa Vulpile a ieșit pe locul 1 la Harta.", eventId: "e1", read: false});
  assert.deepEqual(pushed.filter((u) => u === "u1"), ["u1"]);
});
test("a push that fails holds nobody back", ...); // push rejects: results and resultsComputedAt are still written

// teams.emu.test.ts
test("signing a crew up tells the other players, not the captain", ...);
// body "Vulpile merge la <event>, pe 14 nov"; kind "team"; eventId set; the captain's list is empty
test("a captain alone tells nobody", ...);
test("a failure telling them does not undo the sign-up", ...);
test("shortDate uses Bucharest time", () => assert.equal(shortDate(new Date("2026-11-14T22:30:00Z")), "15 nov"));
```

- [ ] **Step 2: Run and watch them fail**

Run: `npm --prefix functions test`. Expected: the new tests fail.

- [ ] **Step 3: Implement**

`applyPlayer`: inside its transaction, `tx.set(userRef.collection("notifications").doc(`results_${eventId}`), inboxEntry(item))`, so it's written exactly once with the memory. It returns false when the memory already exists. In `applyResults`, after a player's transaction returns true, `await push(uid, item.title, item.body)`, caught so it can't count as a player failure.

`registerTeam`: the transaction also returns the other players' uids and the event's name and date. After the transaction, call `tell` (default: `addToInboxes`, then `pushToUser` per uid) in a try/catch. New crews have no other players, so nothing is sent.

- [ ] **Step 4: Run and watch them pass**

Run: `npm --prefix functions test`. Expected: exit 0.

- [ ] **Step 5: Document and commit**

```bash
git add functions/src docs/services-and-backend.md
git commit -m "Results and crew sign-up reach the notification list"
```

### Task 3: Notifications in the app

**Files:**
- Create: `lib/model/app_notification.dart`, `lib/backend/repo/notification_repo.dart`, `lib/features/notifications/logic/notification_view.dart`, `lib/features/notifications/controller/notifications_controller.dart`
- Modify: `lib/backend/repo/user_repo.dart`
- Test: `test/model/app_notification_test.dart`, `test/features/notifications/notification_view_test.dart`, `test/features/notifications/notifications_controller_test.dart`

**Interfaces:**
- Produces:
  - `enum NotificationKind { announcement, chat, team, results, other }`
  - `class AppNotification {id, kind, title, body, createdAt (DateTime?), read (bool), eventId (String?), teamName (String?)}` with `AppNotification.fromMap(String id, Map<String, dynamic> map)`: an unknown kind becomes `other`, bad fields become empty, a missing `read` counts as read
  - `NotificationRepo`: `stream(String uid, {int limit = 50}) → Stream<List<AppNotification>>` (newest first), `hasUnread(String uid) → Stream<bool>` (`read == false`, limit 1), `markRead(String uid, String id) → Future<void>`, `markAllRead(String uid, Iterable<String> ids) → Future<void>` (one batch)
  - `UserRepo.getMemory(String uid, String eventId) → Future<Memory?>`
  - In `notification_view.dart`:
    - `({List<AppNotification> today, List<AppNotification> earlier}) groupNotifications(List<AppNotification> items, DateTime now)`: today means the same local day; no date counts as earlier
    - `String notificationTime(DateTime? at, DateTime now)`: `chiar acum` under 1 min, `acum N min`, `acum N h` the same day, otherwise `dayAndMonth`, empty when null
    - `sealed class NotificationTarget` with `OpenChat(eventId, teamName)`, `OpenMemory(eventId)`, `OpenEvent(eventId)`, `OpenTeams()`, `StayHere()`
    - `NotificationTarget notificationTarget(AppNotification n, {required bool Function(String eventId) eventLoaded})`
  - `NotificationsController({required Stream<List<AppNotification>> stream, required Future<void> Function(String id) markRead, required Future<void> Function(Iterable<String> ids) markAllRead})` extending `ChangeNotifier`: `items`, `loading`, `failed`, `hasUnread`, `open(AppNotification n) → Future<void>` (marks read, ignores failure), `markAll() → Future<void>` (only unread ones; does nothing with none)

- [ ] **Step 1: Write the failing tests**

```dart
test('an unknown kind still shows', () => expect(AppNotification.fromMap('a', {'kind': 'later', 'title': 'T'}).kind, NotificationKind.other));
test('bad data does not throw', () => AppNotification.fromMap('a', {'title': 7, 'read': 'x', 'createdAt': 'x'}));

test('today and earlier, and no date is earlier', ...);          // 23:59 yesterday is earlier; 00:01 today is today
test('the time line', () {
  expect(notificationTime(now.subtract(const Duration(seconds: 20)), now), 'chiar acum');
  expect(notificationTime(now.subtract(const Duration(minutes: 10)), now), 'acum 10 min');
  expect(notificationTime(now.subtract(const Duration(hours: 1)), now), 'acum 1 h');
  expect(notificationTime(DateTime(2026, 11, 7), now), '7 nov');
  expect(notificationTime(null, now), '');
});
test('where a tap goes', () {
  // chat with event and team -> OpenChat; chat without team -> StayHere
  // results with event -> OpenMemory; results without -> StayHere
  // team or announcement with a loaded event -> OpenEvent; with an event not loaded -> StayHere
  // team with no event -> OpenTeams; announcement with no event, other -> StayHere
});

test('follows the stream; loading ends, a failure says so', ...);
test('opening marks an unread row read, and a read one not again', ...);
test('a failing mark does not throw', ...);
test('hasUnread and mark all, with only the unread ids', ...);
test('mark all with nothing unread writes nothing', ...);
```

- [ ] **Step 2: Run and watch them fail**

Run: `flutter test --timeout 60s test/model/app_notification_test.dart test/features/notifications`. Expected: FAIL, the files don't exist.

- [ ] **Step 3: Implement as in Interfaces**

- [ ] **Step 4: Run and watch them pass**

Same command. Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/model/app_notification.dart lib/backend/repo lib/features/notifications test/model/app_notification_test.dart test/features/notifications
git commit -m "Notifications in the app: data, groups and where a tap goes"
```

### Task 4: The Notificări page

**Files:**
- Create: `lib/features/notifications/screen/notifications_screen.dart`, `lib/features/notifications/widgets/notifications_view.dart`, `lib/features/notifications/widgets/notification_row.dart`
- Modify: `lib/constants/routes.dart`, `lib/main.dart`, `docs/features.md`, `docs/screens.md`
- Test: `test/features/notifications/notifications_view_test.dart`

**Interfaces:**
- Consumes: everything from Task 3.
- Produces:
  - `Routes.notifications = '/notifications'`, no arguments
  - `NotificationsView({required List<AppNotification> items, required bool failed, required DateTime now, required ValueChanged<AppNotification> onOpen})`
  - `NotificationRow({required AppNotification item, required DateTime now, required VoidCallback onTap})`

- [ ] **Step 1: Write the failing tests**

```dart
testWidgets('rows under Azi and Mai devreme', ...);                     // titles, bodies and times show
testWidgets('a group with nothing leaves its title out', ...);
testWidgets('unread rows have the dot, read ones not', ...);            // ValueKey('notification-unread')
testWidgets('tapping a row opens it', ...);
testWidgets('empty: the two lines', ...);                               // exact spec copy
testWidgets('failed: its line', ...);                                   // 'Nu am putut încărca notificările.'
testWidgets('an unknown kind has the plain bell', ...);                 // find.byIcon(TablerIcons.bell)
testWidgets('fits 320 px at 1.3x text, light and dark', ...);           // long title and body
```

- [ ] **Step 2: Run and watch them fail**

Run: `flutter test --timeout 60s test/features/notifications/notifications_view_test.dart`. Expected: FAIL.

- [ ] **Step 3: Build, as drawn on the canvas**

- Icons: `announcement` `speakerphone`, `chat` `message_circle`, `team` `users_group`, `results` `trophy`, `other` `bell`.
- The row is an `OutlineCard`, unread tinted with `navActivePill`, and the whole row is the tap target.
- `NotificationsScreen`: `MyAppBar(appBarText: 'Notificări', trailing: …)` with `Marchează citite` while `hasUnread`, a spinner while loading, and `DateTime.now()` read on each build. It's a list that scrolls.
- On tap, the screen calls `controller.open(n)`, then acts on `notificationTarget`:
  - `OpenChat`: loads the team with `TeamService().getUserTeamForEvent`, then pushes `Routes.chatScreen` with `{'eventId', 'team'}`.
  - `OpenMemory`: `UserRepo.getMemory`, then `Routes.memory`.
  - `OpenEvent`: `Routes.eventDetails` with the event from `EventList`.
  - `OpenTeams`: `ShellController.select(PlayerTab.teams)`, then pop.
  - A read that fails or returns nothing stays on the page.

- [ ] **Step 4: Run and watch them pass**

Same command. Expected: PASS.

- [ ] **Step 5: Document and commit**

Add the route to `docs/features.md`, a `notifications` feature line, and a `NotificationsScreen` entry in `docs/screens.md`.

```bash
git add lib/constants/routes.dart lib/main.dart lib/features/notifications test/features/notifications docs/features.md docs/screens.md
git commit -m "The Notificări page"
```

### Task 5: The bell

**Files:**
- Modify: `lib/features/home/controller/home_extras_controller.dart`, `lib/features/home/controller/home_controller.dart`, `lib/features/home/screen/home.dart`, `lib/dev/home_preview.dart`, `test/features/home/home_extras_controller_test.dart`, `CLAUDE.md`, `docs/screens.md`
- Delete: `lib/features/home/logic/news_seen.dart`, `test/features/home/news_seen_test.dart`

**Interfaces:**
- Consumes: `NotificationRepo.hasUnread`, `Routes.notifications`.
- Produces:
  - `HomeExtrasController` gains `required Stream<bool> Function(String uid) unread` and `bool get hasUnread`, followed and cancelled with the same `watch(uid)`
  - `HomeController.openNotifications()`; `openNews` is removed

- [ ] **Step 1: Write the failing tests**

```dart
test('follows unread notifications for the player', ...);   // stream true -> hasUnread true, false -> false
test('a failing stream means no dot', ...);
test('watch(null) clears the dot', ...);
```

- [ ] **Step 2: Run and watch them fail**

Run: `flutter test --timeout 60s test/features/home/home_extras_controller_test.dart`. Expected: FAIL.

- [ ] **Step 3: Implement**

`Home` passes `HomeHeader(unread: _extras.hasUnread, onBell: controller.openNotifications)`, with `_extras` listened to around the header too. Remove `_newsSeen`, `_lastSeenNews`, `_openNews` and the `hasUnreadNews` use. `HomeHeader`'s `Semantics` label becomes `Notificări noi` or `Notificări`; update its test.

- [ ] **Step 4: Run all Home tests**

Run: `flutter test --timeout 60s test/features/home`. Expected: PASS.

- [ ] **Step 5: Document and commit**

Update the Notifications part of `CLAUDE.md` and `HomeHeader` in `docs/screens.md`.

```bash
git add lib/features/home lib/dev/home_preview.dart test/features/home CLAUDE.md docs/screens.md
git commit -m "The bell opens the notifications"
```

### Task 6: Check everything and merge

- [ ] **Step 1: Run everything**

Run: `flutter analyze`, then `flutter test --timeout 60s --reporter expanded` into a file and read its tail, then `npm --prefix functions test` and `npm --prefix functions run build`. Expected: no new analyzer errors, all tests pass, the build succeeds.

- [ ] **Step 2: Final review**

A fresh review of the whole branch against the spec and this plan's Review Focus. Fix what it finds, each fix with a test that failed first, then run Step 1 again.

- [ ] **Step 3: Merge**

```bash
git switch redesign/mockups
git merge --no-ff redesign/notifications -m "Merge: notifications behind the bell"
```

- [ ] **Step 4: Tell Victor what is left for him**

The deploy list from the spec, to run himself: functions, then rules. Until then the page stays empty. What couldn't be tested: real pushes, and the page on a phone.
