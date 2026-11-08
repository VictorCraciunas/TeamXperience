# Redesign step 7b: the Profil tab — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Mockup 08's Profil (right phone), in the app's own colours:
- a header with a settings button;
- the account block: initials avatar, name, level, XP bar and "Următorul: …";
- four stats: games, km, missions, podiums;
- "Insigne" (earned out of 12) with a sheet of all of them;
- "Amintiri" (past games);
- a settings card: theme, notifications, sign-out.

**Architecture:**
- **Pure logic, tested alone:** the level and XP numbers, the badge catalogue, and the texts.
- **Plain-value widgets:** every widget takes plain values, and `ProfileView` assembles them.
- **One controller:** `ProfileController` follows the player's own user document and memories, and holds the notification state. Its streams and permission calls are passed in.
- **Starter values until 7c:** XP, stats, badges and memories are written by the results function (7c), which is parked with 3b. Until it runs, Profil shows level 1, zero stats, "0 din 12" and an empty Amintiri.
- **The admin's Profil tab:** `ProfileScreen` is also the admin shell's Profil tab. Admins keep only the account, settings and sign-out.

**Tech Stack:** Flutter (Dart 3.7), provider, cloud_firestore, firebase_messaging, geolocator (only for `openAppSettings`), flutter_tabler_icons.

**Spec:**
- `docs/roadmap/mockups-roadmap.md`: L7.3 (Profil), L1.5 (`users/{uid}`: `xp`, `stats`, `badges[]`; `users/{uid}/memories/{eventId}`), U3.9, U3.4 (stats), and the 2026-11-07 note "Step 7 is split in three".
- The mockup `docs/roadmap/mockups/08-finish-and-profile.html` (right phone), for layout and sizes.
- **Victor's decision:** server work (XP, badges, memories) waits with 3b.

## Global Constraints

- **Branch:** `redesign/step-7b-profile` from `redesign/mockups`; merge back with `--no-ff`; never push. Commits end with the attribution line the session gives.
- **Layout and colours:**
  - Layout and sizes come from mockup 08 (right). 1 CSS px = 1 logical px; line height 1.45; no box-sizing reset (a CSS width or height is the content box, so borders add to it).
  - Colours come from `context.colors` (the app's, not an event's). No literal colours in `lib/features`.
  - Mapping: page `#E7ECF3` → `page`; white cards → `panel`; `#CFD8E4` → `border`; `#E1E7EF` → `insetBorder`; avatar `#222F62` → `navy` with `onNavy` text; its ring and the bar fill `#2AA5A9` → `tick`; level text `#167A7E` → `accent`; badge `#DDF3F3` → `iconButtonBg`; gold badge `#FBEFD8`/`#B7791F` → `warningSoft`/`warning`; sign-out `#D13438` → `danger`.
- **Code rules:** no `x!` in new code; one widget per file; one controller per screen; `lib/ui` never imports `lib/features`.
- **Data:** new fields are optional with defaults; none is written by `toJson` (`UserRepo.saveUser` must not overwrite XP).
- **Docs:** `docs/data-model.md`, `docs/features.md`, `docs/screens.md` follow in the task that changes them. The roadmap's 7c note gets the badge ids and the memory shape.
- **Copy:**
  - Header "Profil".
  - Level line "Explorator · 640 / 1000 XP", then "Următorul: Cartograf". At the top level: "Legendă · 3100 XP", then "Nivel maxim".
  - Stats, plural-aware: "joc / jocuri", "km", "misiune / misiuni", "podium / podiumuri".
  - "Insigne" with "4 din 12"; the sheet title "Insigne".
  - "Amintiri"; the empty line "Aici apar jocurile tale terminate."
  - A memory line "Locul 2 · 1:48 · 6 poze" (parts left out when unknown; "1 poză").
  - Settings: "Temă" with "Sistem" / "Luminos" / "Întunecat"; "Notificări" with "Activate" / "Oprite"; "Deconectare".

## Rulings made while planning (report them to Victor)

1. **Admins:** Profil takes a `player` flag. For `Role.ADMIN` it shows the account block (name and email instead of the level) and the settings card only.
2. **Fresh numbers:** the user loaded at sign-in is a snapshot. `ProfileController` follows `users/{uid}` and hands the fresh XP, stats and badges to `UserProvider.updateProfile`, so Home's greeting refreshes too. This is a small, tested method.
3. **The badge catalogue is static in the app** (`badge_catalog.dart`, 12 badges, stable ids); a user document stores only the earned ids. 7c must use the same ids (the roadmap's 7c note lists them).
4. **The badge row shows four:** the earned ones first, then locked ones, both in catalogue order. Tapping the section header's "4 din 12" or any badge opens the sheet with all 12 (locked ones show their rule).
5. **The gear in the header scrolls to the settings card** (the settings are on the same page, so there is nothing else for it to open).
6. **Notifications:** the row shows whether the phone allows them. Tapping asks for permission when not yet asked; when refused it opens the phone's app settings (`Geolocator.openAppSettings`, which opens the app's settings page; no new package).
7. **Memories:** up to three, newest first; a tap opens that event's page (found in `EventList`; if it is not loaded, nothing happens). No "see all" yet. `totalTime` is whole minutes.
8. **At the top level (Legendă)** the bar is full and the line has no "/ …".
9. **A single name word or none:** one initial, or empty.
10. **The XP bar is XP over the next level's XP** (640 / 1000 = 64 %, as the mockup's text and bar agree). Home's greeting keeps its own bar (progress within the level); `LevelInfo` carries both numbers.

## Review Focus

1. **An admin opens Profil:** no level, stats, badges or memories, and nothing crashes without XP or stats. (Task 4 view test.)
2. **A brand-new player** (XP 0, no stats, no badges, no memories): starter values, "0 din 12", the empty Amintiri line, no NaN or bar over 100 %. (Tasks 2 and 4.)
3. **XP on a boundary or past the top** (499, 500, 1000, 2499, 2500, 3100, negative): the right level name, the bar between 0 and 1, "Nivel maxim" only at the top. (Task 2.)
4. **Notifications refused, not asked, granted, and the permission call throwing:** the row text is right and nothing crashes. (Task 3.)
5. **A long name, a one-word name, 320 px at 1.3× text:** no overflow. (Task 4.)

---

### Task 1: Profile data and the fresh-user hand-off

**Files:**
- Create: `lib/model/memory.dart`
- Modify:
  - Models: `lib/model/user.dart` (`badges`, `copyWith`) and `lib/model/user_stats.dart` (`missions`, `podiums`).
  - Data: `lib/backend/repo/user_repo.dart` (`streamUser`, `streamMemories`) and `lib/state_management/user_provider.dart` (`updateProfile`).
  - Docs: `docs/data-model.md`.
- Test: `test/model/user_profile_fields_test.dart`, `test/model/memory_test.dart`, `test/state_management/user_provider_profile_test.dart`

**Interfaces:**
- `UserStats({games, distanceMeters, missions = 0, podiums = 0})`, read tolerantly (anything unreadable is 0).
- `AppUser.badges` (`List<String>`, default empty; ids that are not text are skipped).
- `AppUser.copyWith({registeredEventIds, fcmToken, xp, stats, badges})`.
- `toJson` still does not write XP, stats or badges.
- `class Memory { String eventId; String eventName; DateTime? date; int? place; int? totalMinutes; List<String> photoUrls; }` with `Memory.fromMap(String eventId, Map<String, dynamic>)`:
  - `date` reads a Timestamp or DateTime;
  - `place` and `totalTime` read whole numbers (`totalTime` becomes `totalMinutes`);
  - `photoUrls` keeps only text.
- `UserRepo.streamUser(String uid) → Stream<AppUser?>` and `UserRepo.streamMemories(String uid, {int limit = 3}) → Stream<List<Memory>>` (ordered by `date`, newest first).
- `UserProvider.updateProfile(AppUser fresh)`:
  - it copies `xp`, `stats` and `badges` onto the current user and notifies;
  - it does nothing when there is no current user or the uid differs.

- [ ] **Step 1: Write the failing tests:**
  - `UserStats.fromMap` reads missions and podiums; `{}` and a non-map give zeros.
  - `AppUser.fromFirestore` reads `badges`; a missing field gives `[]`; `[1, 'noHints']` keeps only `'noHints'`; `toJson` has none of `xp`, `stats`, `badges`.
  - `copyWith(xp: …, stats: …, badges: …)` changes only those.
  - `Memory.fromMap`: a full map; a missing date and place; a bad `totalTime`; non-text photo entries skipped.
  - `UserProvider.updateProfile` updates the current user's numbers and notifies once; ignores a different uid; ignores a signed-out provider.
- [ ] **Step 2: Run; expect failures.** `flutter test test/model test/state_management`
- [ ] **Step 3: Implement.** The repo streams are thin (no unit test; the same as the other repos).
- [ ] **Step 4: Run the same; expect PASS; then `flutter test`; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "Profile data: badges, more stats, memories; a fresh user reaches the provider"`

---

### Task 2: Profile logic: levels, badges, texts

**Files:**
- Create: `lib/features/profile/logic/badge_catalog.dart`, `lib/features/profile/logic/profile_texts.dart`
- Modify: `lib/features/home/logic/home_texts.dart` (`levelInfo`)
- Test: `test/features/profile/profile_logic_test.dart`, plus an addition to the existing Home texts test for `levelInfo`.

**Interfaces:**
- `class LevelInfo { String name; int xp; int? nextAt; String? nextName; double progress; double share; }` and `LevelInfo levelInfo(int xp)` next to `levelFor`, using the same levels (Începător 0, Explorator 500, Cartograf 1000, Legendă 2500). Negative XP counts as 0. `progress` is the way through the current level (what `levelFor` gives); `share` is `xp / nextAt` (what the Profil bar shows). At Legendă, `nextAt` and `nextName` are null and both are 1. Both stay between 0 and 1.
- `String levelLine(LevelInfo)`: "Explorator · 640 / 1000 XP", or "Legendă · 3100 XP" at the top.
- `String nextLevelLine(LevelInfo)`: "Următorul: Cartograf", or "Nivel maxim".
- `String initialsOf(String name)`: the first letter of the first two words, upper-case; "" for blank.
- `String statLabel(String kind, int n)` for `'games' | 'missions' | 'podiums'` (plural-aware) and `String km` stays "km".
- `String memoryLine(Memory)`: "Locul 2 · 1:48 · 6 poze"; parts left out when unknown; "1 poză".
- `class ProfileBadge { String id; String title; IconData icon; String rule; bool gold; }`, `const List<ProfileBadge> badgeCatalog` of exactly 12, and `List<ProfileBadge> badgesRow(List<String> earnedIds)` (up to 4: earned in catalogue order, then locked), `int earnedCount(List<String>)` (known ids only).
- The twelve ids and titles: `km10` "Primii 10 km", `noHints` "Fără indicii", `night` "Joc nocturn", `winner` "Câștigă un joc", `firstGame` "Primul joc", `games5` "5 jocuri", `km50` "50 km", `podium3` "3 podiumuri", `photo` "Poză aprobată", `fast` "Misiune sub 5 min", `missions50` "50 de misiuni", `crew` "Joc cu echipa completă". Each has a short rule line ("Parcurge 10 km în total") and a Tabler icon (shoe, bolt, moon, trophy, flag, run, route, medal, camera, clock, map_2, users_group; choose the nearest that exists).

- [ ] **Step 1: Write the failing tests:**
  - `levelInfo`:
    - 0 → Începător, progress 0, share 0, next 500 "Explorator";
    - 499 → Începător, progress and share just under 1;
    - 500 → Explorator, progress 0, share 0.5;
    - 640 → Explorator, progress 0.28, share 0.64;
    - 1000 → Cartograf;
    - 2499 → Cartograf;
    - 2500 → Legendă, progress 1, no next;
    - 3100 → Legendă;
    - -40 → Începător, 0.
  - `levelLine` / `nextLevelLine` for 640 and 3100.
  - `initialsOf`: "Victor Crăciunaș" → "VC"; "Ana" → "A"; "  " → ""; three words → two letters.
  - `statLabel`: 1 → "joc", 3 → "jocuri", 1 → "misiune", 17 → "misiuni", 1 → "podium", 2 → "podiumuri".
  - `memoryLine`: the mockup's line; no place; no photos; one photo; nothing known gives "".
  - `badgeCatalog`: 12 entries, unique ids, none without a title or rule.
  - `badgesRow`:
    - none earned → the first four locked;
    - `['noHints', 'km10']` → those two first (catalogue order), then two locked;
    - six earned → the first four earned;
    - unknown ids are ignored;
    - `earnedCount(['km10', 'x'])` is 1.
- [ ] **Step 2: Run; expect failures.**
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run; expect PASS; then `flutter test`; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "Profile logic: levels with their next step, the badge catalogue, texts"`

---

### Task 3: The profile controller and notification access

**Files:**
- Create: `lib/features/profile/logic/notification_access.dart`
- Modify: `lib/features/profile/controller/profile_controller.dart` (becomes a `ChangeNotifier`; `logout()` stays)
- Test: `test/features/profile/profile_controller_test.dart`

**Interfaces:**
- `class NotificationAccess { NotificationAccess({Future<NotifStatus> Function()? read, Future<NotifStatus> Function()? ask, Future<void> Function()? openSettings}) }`
  - `enum NotifStatus { allowed, notAsked, refused }`
  - `Future<NotifStatus> status()`: failure reads as `refused`.
  - `Future<NotifStatus> askOrOpenSettings()`:
    - `notAsked` → `ask`;
    - `refused` → `openSettings`, then reads again;
    - `allowed` → unchanged;
    - any throw → `refused`.
  - The defaults use `FirebaseMessaging.instance.getNotificationSettings()` / `requestPermission()` and `Geolocator.openAppSettings()`.
- `ProfileController(BuildContext context, {required AppUser user, required Stream<AppUser?> userStream, required Stream<List<Memory>> memoriesStream, required NotificationAccess notifications, required void Function(AppUser) onFreshUser})`:
  - exposes `user` (starts as the one given; replaced by each fresh one, which also goes to `onFreshUser`), `memories`, `notifications` (`NotifStatus?`, null until read), `notificationsLabel` ("Activate" / "Oprite" / "Oprite" until read), `onNotificationsTap()`, `dispose()`, and the existing `logout()`.
  - A null from the user stream (document missing) keeps the current user.

- [ ] **Step 1: Write the failing tests:**
  - `NotificationAccess`: allowed stays allowed; not asked asks; refused opens the settings and reads again; a throwing read is `refused`; a throwing ask is `refused`.
  - `ProfileController`, with `StreamController`s:
    - starts with the given user and no memories;
    - a fresh user replaces it and reaches `onFreshUser`;
    - a null keeps the user;
    - memories arrive;
    - notifications read once on start; the label follows the status;
    - a tap on a refused status opens the settings;
    - disposing cancels the streams (nothing is delivered afterwards).
- [ ] **Step 2: Run; expect failures.**
- [ ] **Step 3: Implement.** In the screen (Task 5) the real streams come from `UserRepo`.
- [ ] **Step 4: Run; expect PASS; then `flutter test`; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "Profile controller: the player's own numbers, memories and notification access"`

---

### Task 4: The Profil widgets and view

**Files:**
- Create in `lib/features/profile/widgets/`:
  - `profile_account_card.dart`: padding 14; a 54 px `navy` avatar with a 3 px `tick` ring (60 across) and 17 w500 `onNavy` initials; the name at 15 w500; for players, the level line at 11 w500 in `accent`, a 5 px bar (track `insetBorder`, fill `tick`, 4 px above), "Următorul: …" at 11 `muted` 2 px below; for admins, the email at 11 `muted` instead.
  - `profile_stats_row.dart`: four `OutlineCard`-style tiles (padding 6/8, gap 6, centred, value 15 w500, label 11 `muted`).
  - `badge_tile.dart`: a 44 px circle and the 11 px title (3 apart, centred). Earned: teal (`iconButtonBg` and an `accent` 22 px icon) or gold (`warningSoft` and `warning`). Locked: a dashed 2 px `muted` ring with an 18 px lock, at 45 % opacity.
  - `badges_section.dart`: `SectionHeader("Insigne", trailing: "4 din 12")` and the row (padding 0/18, space-between); a tap on the header's note or a badge calls `onOpenAll`.
  - `badge_sheet.dart`: `showBadgeSheet(context, earned)`, a bottom sheet with the title, "4 din 12" and a 4-column grid of all 12 (locked ones show their rule under the title).
  - `memory_card.dart`: a card (margin 0/14, padding 8, gap 10): a 40 px radius-8 thumbnail (the first photo, else an `inset` block with a map icon), the event name at 12 w500, the memory line at 11 `muted`, a 16 px chevron.
  - `memories_section.dart`: `SectionHeader("Amintiri")` and up to three cards, or the empty line.
  - `profile_settings_card.dart`: a card (margin 12/14/12, padding 0) with three rows (padding 9/12, gap 10, a 1 px `insetBorder` between): sun-moon "Temă" with the mode name; bell "Notificări" with its label and a chevron; logout in `danger`.
- Modify: `lib/features/profile/widgets/profile_view.dart` (assembles them) and `test/features/profile/profile_view_test.dart`.
- Test: `test/features/profile/profile_widgets_test.dart`

**Interfaces:**
- `ProfileView({required bool player, required String name, required String email, int xp = 0, UserStats stats, List<String> badges, List<Memory> memories, required String themeLabel, required String notificationsLabel, required VoidCallback onTheme, required VoidCallback onNotifications, required VoidCallback onLogout, required VoidCallback onOpenBadges, required ValueChanged<Memory> onOpenMemory, Key? settingsKey})`:
  - players see everything;
  - admins see the account card and the settings card.

- [ ] **Step 1: Write the failing tests:**
  - **Account card:**
    - "VC" in a 60-across avatar;
    - "Explorator · 640 / 1000 XP" and "Următorul: Cartograf";
    - the bar is 64 % full for 640 XP;
    - at 3100 XP: "Legendă · 3100 XP", "Nivel maxim", full bar;
    - for an admin: the email, no level.
  - **Stats row:** "3 jocuri", "12,4 km", "17 misiuni", "1 podium" with their values.
  - **Badges:** "4 din 12" for four earned; locked tiles are at 45 %; the gold one uses the warning colours; tapping the note and a badge calls `onOpenBadges`.
  - **Sheet:** all 12 titles; a locked one shows its rule.
  - **Memories:** the mockup's card ("Moștenirea Cartografului", "Locul 2 · 1:48 · 6 poze"); a tap passes the memory; empty shows "Aici apar jocurile tale terminate."; four memories show three.
  - **Settings:** the theme name, "Activate"/"Oprite", and the three callbacks.
  - **View:** a brand-new player shows "Începător · 0 / 500 XP", zeros, "0 din 12" and the empty memories line; an admin shows no "Insigne", "Amintiri" or stats.
  - A one-word name, an empty name, a very long name; 320 px at 1.3× text, light and dark, no overflow.
- [ ] **Step 2: Run; expect failures.**
- [ ] **Step 3: Implement.** Reuse `SectionHeader`, `OutlineCard`, `MiniStatCard`'s look where it fits.
- [ ] **Step 4: Run; expect PASS; then `flutter test`; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "Profil as mockup 08: account and level, stats, badges, memories, settings"`

---

### Task 5: The screen, the gallery and docs

**Files:**
- Modify:
  - `lib/features/profile/screen/profile_screen.dart`: a `StatefulWidget` that builds the controller with the real streams (`UserRepo.streamUser`, `UserRepo.streamMemories`), `NotificationAccess()` and `UserProvider.updateProfile`; a `TabHeader("Profil")` with the 32 px gear (`iconButtonBg`, 17 px icon) that scrolls to the settings card; "Temă" opens `ThemeModeSheet`; a memory tap finds its event in `EventList` and opens `Routes.eventDetails` with `{'event': event, 'isAdmin': false}`; the badge opener calls `showBadgeSheet`. The admin shell passes nothing different: the role decides.
  - `lib/dev/sample_event.dart`: `sampleMemories()`.
  - `lib/dev/profile_preview.dart` (new): "Începător (nou)", "Explorator (mockup)", "Legendă" and "Admin"; light and dark follow the gallery.
  - `lib/dev/shell_previews_launcher.dart`: "Profil".
  - Docs: `docs/features.md`, `docs/screens.md`, `docs/data-model.md` (the memory shape), `docs/roadmap/mockups-roadmap.md` (7b done; the 7c note: the twelve badge ids and the memory fields, minutes for `totalTime`).
- Test: `test/dev/shell_previews_test.dart` (the preview, its four states, light and dark; the launcher opens it).

- [ ] **Step 1: Write the failing test** (the preview renders each state; "Admin" shows no "Insigne").
- [ ] **Step 2: Run; expect failure.**
- [ ] **Step 3: Implement and update the docs.**
- [ ] **Step 4: Run `flutter test` and `flutter analyze`; expect PASS and no new issues.**
- [ ] **Step 5: Commit** — `git commit -m "Profil screen on real data; gallery preview; docs"`
