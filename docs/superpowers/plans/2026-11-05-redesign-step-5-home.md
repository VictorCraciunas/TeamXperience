# Redesign step 5: Home before and during an event — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** The player Home tab looks and works exactly like mockup 02: before an event (greeting with stats, next-game card with countdown and team preparation, new events) and during one (live card with timer and progress, live leaderboard, who is playing).

**Architecture:** Pure logic files (ranking, texts, level, preparation) feed view widgets that take plain values; a small `HomeLiveController` streams the live event's teams and ranks them. The game screen starts writing two new team fields (`presence`, `missionCompletedAt`) that the live Home reads. Old Home panels the mockup does not draw are removed.

**Tech Stack:** Flutter (Dart 3.7), provider, cloud_firestore, shared_preferences, flutter_tabler_icons.

**Spec:** `docs/roadmap/mockups-roadmap.md` (step 5 = L4 + U3.5) and the binding mockup `docs/roadmap/mockups/02-home.html`.

## Global Constraints

- Branch `redesign/step-5-home` from `redesign/mockups`; merge back with `--no-ff`; never push.
- The mockup binds over this plan's prose: 1 CSS px = 1 logical px, line height 1.45, CSS borders sit outside padding (add them to the padding).
- Colours only from `context.colors` (no literal colours in `lib/features`; `test/ui/no_hardcoded_colors_test.dart` must keep passing with no allow-list additions). Opacities from the mockup are applied to tokens: `colors.onNavy.withValues(alpha: .8)`.
- Icons: Tabler, snake_case (`TablerIcons.route`, `bell`, `check`, `flag`, `message_circle`, `chevron_right`).
- `lib/ui/` never imports from `lib/features/`; generic widgets go in `lib/ui/components/` and take texts and callbacks as parameters.
- No `x!` in new code; one widget per file; one controller per screen.
- Romanian copy exactly as in the mockup: "Salut, {firstName}", "jocuri", "pe jos", "Următorul tău joc", "zile", "ore", "min", "Pregătirea echipei {team}", "Înscriși", "Echipă completă", "Cod de start", "Evenimente noi", "Vezi toate", "LIVE", "rămase", "Echipa {team} · misiunea {n} din {total}", "Continuă jocul", "Clasament live", "Tot", "{team} · voi", "Echipa ta", "{n} jucători activi", "Ultima misiune rezolvată acum {n} min".
- New Firestore fields are optional with defaults, so old documents still load. Update `docs/data-model.md` in the same task.
- Levels (roadmap "My calls"): Începător 0, Explorator 500, Cartograf 1000, Legendă 2500 XP.

## Rulings made while planning (report them to Victor)

1. **The bell opens Știri.** Mockup 02 has no news section but a bell with a red dot; news therefore sits behind the bell, and the dot shows while a news item is newer than the player's last visit to Știri (kept on the device). Cost if wrong: one tap target changes.
2. **Panels the mockup does not draw are removed from Home:** "Cum funcționează", "Înscrierile tale" (it lives on Evenimente), the news panel. Cost if wrong: they come back from git.
3. **Amintiri waits for step 7.** Memories are written by the end-of-event Cloud Function (L7); before it exists the section would always be empty. Cost if wrong: Home lacks its last section until step 7.
4. **Stats read `users/{uid}.xp` and `.stats`** (new optional fields, written by L7). Until step 7 they show "0 jocuri · 0 km · Începător". The redesign does not reach `main` before step 7.
5. **The leaderboard's "4/6" is the mission the team is on** (`missionProgress + 1`, capped at the total), matching the live card's "misiunea 4 din 6"; a finished team shows total/total and ranks first.
6. **The leaderboard card shows three rows:** the top three, or the top two and the player's team when it is lower. "Tot" opens a sheet with every team.
7. **Team avatars reuse `AvatarStack`** (navy, amber, accent, tick) instead of mockup 02's navy/accent/grey, so a player's colour is the same on every screen.
8. **The two hero states the mockup does not draw** (code window open, recommended event) use the same navy card: a badge, the title, one line, one tick button.
9. **The live card's background is a new token `liveCard`:** `#0C092A` light (the mockup), `#1B1446` dark.
10. **Presence is written by the game screen** (every 60 s while it is open); the start screen joins in step 6. "Activ" = seen in the last 2 minutes.
11. **Tapping the next-game card opens the team's registration details** (the old "Detalii înscriere" action); the mockup draws no button.

## Review Focus

1. An event with `nrMissions == 0` while live: the progress line draws only the flag, the mission line is "Echipa {team}", the leaderboard score is "–". (Task 2, Task 4 tests.)
2. A presence or mission time whose server timestamp is still pending (null in the local snapshot), or a value that is not a Timestamp: parsing skips it without throwing. (Task 1 test.)
3. The player's own team missing from the teams stream (renamed, or stream error): the leaderboard hides, "Echipa ta" falls back to the provider's active team. (Task 5 test.)
4. The game's end passing while Home is open: the clock shows "0:00:00", never a negative time. (Task 2 test.)
5. Whole Home at 320 px with 1.3× text, light and dark: no overflow, including the three stat tiles, the countdown and the three checkpoint labels. (Task 7 test.)

---

### Task 1: Team and user fields

**Files:**
- Modify: `lib/model/team.dart`, `lib/model/user.dart`, `lib/state_management/user_provider.dart`, `lib/backend/repo/teamRepo.dart`, `lib/service/team_service/team_service.dart`, `lib/features/event_game/controller/puzzle_game_controller.dart:136-141`, `docs/data-model.md`
- Create: `lib/model/user_stats.dart`
- Test: `test/model/team_live_fields_test.dart`, `test/model/user_stats_test.dart`

**Interfaces:**
- Produces: `Team.presence: Map<String, DateTime>` (uid → last seen), `Team.missionCompletedAt: Map<int, DateTime>` (mission index → time), `Team.lastMissionAt: DateTime?` (latest value); `AppUser.xp: int` (default 0), `AppUser.stats: UserStats` (`games: int`, `distanceMeters: double`, both default 0); `AppUser.copyWith({List<String>? registeredEventIds, String? fcmToken})`; `TeamService.markPresent(String eventId, String teamName, String uid): Future<void>`; `TeamService.updateMissionProgress(eventId, teamName, progress, {int? completedMission})`.

- [ ] **Step 1: Write the failing tests**

`team_live_fields_test.dart`:
- `reads presence and mission times from Timestamps`: `Team.fromMap({..., 'presence': {'u1': Timestamp.fromDate(t)}, 'missionCompletedAt': {'0': Timestamp.fromDate(a), '2': Timestamp.fromDate(b)}})` → `presence['u1'] == t`, `missionCompletedAt == {0: a, 2: b}`, `lastMissionAt == b` (b later than a).
- `skips pending and malformed values`: `'presence': {'u1': null, 'u2': 'x'}`, `'missionCompletedAt': {'x': Timestamp.now(), '1': null}` → both maps empty, `lastMissionAt` null; no throw.
- `old documents load with empty maps`: no keys → empty maps.
- `toJson does not write presence or mission times` (they are only ever written field by field with server timestamps): `toJson()` has neither key.

`user_stats_test.dart`:
- `AppUser.fromMap` with `'xp': 620, 'stats': {'games': 3, 'distanceMeters': 12400}` → `xp == 620`, `stats.games == 3`, `stats.distanceMeters == 12400.0`; without them → 0, 0, 0.
- `copyWith keeps xp and stats`: a user with xp 620, `copyWith(registeredEventIds: ['e'])` → xp still 620, ids `['e']`.

- [ ] **Step 2: Run them; expect compile failures** — `flutter test test/model/team_live_fields_test.dart test/model/user_stats_test.dart`

- [ ] **Step 3: Implement**
- `Team`: the two maps (constructor defaults `{}`), parsed with a private helper that accepts `Timestamp` or `DateTime` and skips anything else; `lastMissionAt` getter. Not added to `toJson`.
- `UserStats` in `lib/model/user_stats.dart` with `fromMap`/`toJson`; `AppUser` gains `xp`, `stats`, `copyWith`. `UserProvider.addRegisteredEvent` (`user_provider.dart:37`, which rebuilds `AppUser` field by field) uses `copyWith`; sign-up and log-in construct new users and keep the defaults.
- `TeamRepo.markPresent` → `update({'presence.$uid': FieldValue.serverTimestamp()})`; `updateMissionProgress` gains `completedMission` and, when set, also writes `'missionCompletedAt.$completedMission': FieldValue.serverTimestamp()` in the same `update`.
- `PuzzleGameController` passes `completedMission: team.missionProgress - 1` (the index just finished) after incrementing.
- `docs/data-model.md`: the two team fields and the user's `xp`/`stats` (who writes them: the game screen, the puzzle controller, L7).

- [ ] **Step 4: Run the two test files; expect PASS. Run `flutter test test/model test/features/event_game`; expect PASS.**

- [ ] **Step 5: Commit** — `git commit -m "Team presence and mission times, user xp and stats"`

---

### Task 2: Pure logic — ranking, live texts, level, preparation

**Files:**
- Create: `lib/service/leaderboard.dart`, `lib/features/home/logic/live_texts.dart`, `lib/features/home/logic/home_texts.dart`
- Modify: `lib/features/home/logic/preparation_steps.dart` (replace its content)
- Test: `test/service/leaderboard_test.dart`, `test/features/home/live_texts_test.dart`, `test/features/home/home_texts_test.dart`, `test/features/home/preparation_steps_test.dart` (rewrite)

**Interfaces:**
- Consumes: Task 1's `Team.presence`, `Team.missionCompletedAt`, `Team.lastMissionAt`, `AppUser.xp`.
- Produces:
  - `class RankedTeam { final Team team; final int place; final int mission; }` and `List<RankedTeam> rankTeams(List<Team> teams, {required int missionCount})` — finished first; then `missionProgress` descending; then `lastMissionAt` ascending (null last); then name. Places 1..n, no shared places. `mission` = `missionCount` when finished, else `(missionProgress + 1).clamp(1, missionCount)`; 0 when `missionCount <= 0`.
  - `String liveClock(Duration left)` → `"1:17:42"`, negative → `"0:00:00"`.
  - `String missionLine(Team team, int total)` → `"Echipa Vulpile · misiunea 4 din 6"`, or `"Echipa Vulpile"` when `total <= 0`.
  - `List<TeamMember> activeMembers(Team team, DateTime now)` — members whose uid is in `presence` within 2 minutes (a future time counts as now).
  - `String activeLine(int count)` → `"3 jucători activi"`, `"1 jucător activ"`, `"Niciun jucător activ acum"`.
  - `String lastMissionLine(DateTime? at, DateTime now)` → `"Ultima misiune rezolvată acum 6 min"`; under a minute `"… acum câteva secunde"`; 60 min or more `"… acum 2 h"`; null → `"Nicio misiune rezolvată încă"`.
  - `List<RankedTeam> leaderboardPreview(List<RankedTeam> ranked, String ownName)` — the top three, or the top two plus the own team when it is lower.
  - `String heroDateLine(DateTime start, String? place)` → `"Sâm 14 nov · 10:00 · Piața Mare"` (no place part when null or blank). Callers pass the event's start point `punctDeStart` (the mockup's "Piața Mare"), not `location` (the city).
  - `class PlayerLevel { final String name; final double progress; }` and `PlayerLevel levelFor(int xp)` — progress through the current band (Explorator at 800 → 0.6); Legendă → 1.0.
  - `String kmStat(double meters)` → `"12,4 km"` (reuse `formatKm`).
  - Preparation: `class PreparationTrail { final String teamName; final int done; }` and `PreparationTrail preparationTrail(Event event, Team team, DateTime now)` — step 1 done (registered), step 2 done when `memberList.length >= numberOfMembers > 0`, step 3 done from the event's day (today's rule). `done` counts leading done steps only (a later step never shows done before an earlier one). Labels are the constant `preparationLabels = ['Înscriși', 'Echipă completă', 'Cod de start']`.

- [ ] **Step 1: Write the failing tests**, one per bullet above with the exact strings shown, plus:
  - `rankTeams`: finished team with fewer missions still first; two teams on mission 4 — the one whose `lastMissionAt` is earlier ranks higher; missing times rank after present ones; `missionCount: 0` → every `mission` is 0.
  - `leaderboardPreview`: own team 2nd of 5 → places 1,2,3; own team 5th → places 1,2,5; fewer than three teams → all of them; own team absent → top three.
  - `liveClock(Duration(hours: 1, minutes: 17, seconds: 42)) == '1:17:42'`; `liveClock(Duration(seconds: -5)) == '0:00:00'`.
  - `levelFor(0)` Începător 0.0; `levelFor(800)` Explorator 0.6; `levelFor(1000)` Cartograf 0.0; `levelFor(3000)` Legendă 1.0.
  - `preparationTrail`: team of 4 with 3 members, event in 3 days → done 1; full team, event in 3 days → 2; full team on the event's day → 3; not full on the event's day → 1.
- [ ] **Step 2: Run them; expect failures.** `flutter test test/service/leaderboard_test.dart test/features/home`
- [ ] **Step 3: Implement the functions in the files above.** Remove the old `PreparationStep`/`preparationSteps` and the `PreparationPanel` that used it (and its tests in `home_panels_test.dart`, `home_text_scale_test.dart`).
- [ ] **Step 4: Run them; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "Home logic: ranking, live texts, level and preparation trail"`

---

### Task 3: Shared components

**Files:**
- Create in `lib/ui/components/`: `layout/mini_stat_card.dart`, `event/countdown_boxes.dart`, `route/checkpoint_line.dart`, `route/mission_progress_line.dart`, `team/leaderboard_card.dart`, `event/event_mini_card.dart`
- Modify: `lib/ui/components/misc/section_header.dart` (a `top` margin, default 14), `lib/ui/theme/app_colors.dart` (token `liveCard`)
- Test: `test/ui/components/home_pieces_test.dart`

**Interfaces (all take plain values; sizes from the mockup):**
- `MiniStatCard({required String value, String? label, double? progress, bool accent = false})` — `.card` with padding 6/8 (+1 border): value 14 w500 (accent colour when `accent`); then the 11 px muted label, or, when `progress` is set, a 4 px bar (track `insetBorder`, fill `tick`, radius 99, 4 px above).
- `CountdownBoxes({required Duration left})` — three boxes, gap 6, `onNavy` 10 % fill, radius 10, padding 5/0; value 17 w500 unpadded (`3`, not `03`), label 11 at 80 %: "zile", "ore", "min". Negative → zeros.
- `CheckpointLine({required List<String> labels, required int done})` — 18 px circles: done = `tickOnNavy` fill with a 12 px check in `onTick`; not done = 2 px ring of `onNavy` 50 %. Between circles a 2 px line: solid `tickOnNavy` when both ends are done, else dashed `onNavy` 40 %. Labels below, 3 px gap, 11 px at 85 %, first left, last right, the rest centred (`spaceBetween`).
- `MissionProgressLine({required int total, required int done})` — margin 14/2/4: `done` dots (14, `tickOnNavy`), then the current mission as a 22 px `soon` circle with its number (11 w500, `onTick`), then rings (14, 2 px `onNavy` 40 %) for the rest, then a 16 px flag at 60 %; 2 px lines between, solid `tickOnNavy` up to the current circle, dashed `onNavy` 35 % after. `total <= 0` → only the flag. `done >= total` → all dots, no current circle.
- `LeaderboardCard({required List<LeaderboardRow> rows})` with `class LeaderboardRow { final int place; final String name; final String score; final bool own; }` — `.card` with no padding, rows padding 8/12, gap 8: place 18 wide w500, name (flex, ellipsis), score muted; the own row has `navActivePill` fill, name w500, score accent w500; 1 px `insetBorder` between rows.
- `EventMiniCard({required String title, required String date, required String facts, String? imageUrl, required VoidCallback onTap})` — 150 wide `.card`; a 70 px strip (radius 10, `accent` under the image) inset 6 px from the card edge (the mockup's −4/−6 margins), with a `panel` date pill (11 px, padding 1/7, radius 99) 6 px from its bottom-left; 6 px gap; title 12 w500 one line; facts 11 muted.
- `SectionHeader(top: 16)` for Home (mockup 02's `.hd` margin is 16 14 8).
- `AppColors.liveCard`: light `0xFF0C092A`, dark `0xFF1B1446` (also in `copyWith` and `lerp`).

- [ ] **Step 1: Write the failing tests** in `home_pieces_test.dart`, one per component: the sizes above (e.g. `CountdownBoxes` shows `'3'`, `'14'`, `'22'` for 3 d 14 h 22 min; `CheckpointLine(done: 2)` finds two check icons and one ring; `MissionProgressLine(total: 6, done: 3)` finds the text `'4'` and one flag, and `total: 0` finds only the flag; the own `LeaderboardCard` row's fill is `navActivePill`; `EventMiniCard` is 150 wide with the strip key `mini-strip` 70 high; `SectionHeader(top: 16)` puts the dot 16 below its top). Plus `everything fits 320 px at 1.3× text` (light and dark).
- [ ] **Step 2: Run; expect failures.** `flutter test test/ui/components/home_pieces_test.dart`
- [ ] **Step 3: Implement the components.**
- [ ] **Step 4: Run; expect PASS.** Also `flutter test test/ui`.
- [ ] **Step 5: Commit** — `git commit -m "Home pieces: stat card, countdown, checkpoints, progress line, leaderboard, mini event card"`

---

### Task 4: The hero cards

**Files:**
- Create in `lib/features/home/widgets/`: `navy_game_card.dart` (the frame: radius 22, `navy` or `liveCard`, clipped), `game_badge.dart` (pill: padding 2/9, 11 w500), `game_card_button.dart` ("Continuă jocul" style: `tickOnNavy` fill, radius 12, padding 10, w500 `onTick`), `next_game_card.dart`, `live_game_card.dart`, `starting_soon_card.dart`, `recommended_card.dart`
- Modify: `lib/features/home/widgets/home_hero_section.dart` (maps `HomeHero` to these cards instead of `EventHeroCard`), `lib/features/home/widgets/home_hero_actions.dart` (`onDetails` stays; add nothing)
- Test: `test/features/home/home_hero_section_test.dart` (rewrite)

**Interfaces:**
- Consumes: Task 2's `heroDateLine`, `liveClock`, `missionLine`, `preparationTrail`, `preparationLabels`; Task 3's `CountdownBoxes`, `CheckpointLine`, `MissionProgressLine`.
- `NextGameCard({required Event event, required Duration left, Team? team, required DateTime now, required VoidCallback onTap})` — top part padding 12/14/10: badge "Următorul tău joc" (`tickOnNavy` fill, `onTick` text), title 16 w500 (8 above), `heroDateLine` 11 at 80 %, `CountdownBoxes` 10 above. With a team, a band (`onNavy` 6 %, padding 10/14): "Pregătirea echipei {team.name}" 11 at 80 %, 6 px, `CheckpointLine`. The whole card taps.
- `LiveGameCard({required Event event, required Team team, required DateTime now, required VoidCallback onContinue, required VoidCallback onChat})` — `liveCard` fill, padding 12/14: row of the "LIVE" badge (`live` fill, `onNavy` text), then at the right the `liveClock` (Monospace 15 w500) and "rămase" (11 at 70 %), 6 apart; title 16 w500, 8 above; `missionLine` 11 at 80 %; `MissionProgressLine(total: nrMissions, done: missionProgress)`; 12 px, then a row (gap 8): the expanded "Continuă jocul" button and a 42-wide chat button (`onNavy` 12 %, radius 12, `message_circle` 18). Time left = `dateEvent + Event.maxDuration − now`.
- `StartingSoonCard` — badge "A început" (`soon` fill, `onTick` text), title, "Mai ai {n} min să intri", button "Introdu codul de start".
- `RecommendedCard` — badge "Recomandat pentru tine", title, `heroDateLine` plus `cardRouteFacts` (`events_tab/logic/event_card_texts.dart`), button "Înscrie-ți echipa".

- [ ] **Step 1: Write the failing tests:** each card's texts from the mockup data (`sampleEvent()`: "Moștenirea Cartografului", "Sâm 14 nov · 10:00 · Piața Mare", countdown 3/14/22; live: "1:17:42", "Echipa Vulpile · misiunea 4 din 6", the text `'4'` in the progress line); the next-game card without a team has no "Pregătirea" band; tapping "Continuă jocul" and the chat button call back; `nrMissions: 0` live shows "Echipa Vulpile" and only the flag; the live card's fill is `liveCard`.
- [ ] **Step 2: Run; expect failures.** `flutter test test/features/home/home_hero_section_test.dart`
- [ ] **Step 3: Implement.** `HomeHeroTicker` keeps ticking only the hero (unchanged).
- [ ] **Step 4: Run; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "Home hero: next game, live, code window and recommended cards"`

---

### Task 5: Live data — teams stream, leaderboard and "Echipa ta"

**Files:**
- Create: `lib/features/home/controller/home_live_controller.dart`, `lib/features/home/widgets/live_leaderboard_section.dart`, `lib/features/home/widgets/leaderboard_sheet.dart`, `lib/features/home/widgets/team_now_card.dart`
- Test: `test/features/home/home_live_controller_test.dart`, `test/features/home/live_sections_test.dart`

**Interfaces:**
- Consumes: `rankTeams`, `leaderboardPreview`, `activeMembers`, `activeLine`, `lastMissionLine` (Task 2); `LeaderboardCard`, `LeaderboardRow`, `SectionHeader` (Task 3); `AvatarStack`.
- `HomeLiveController extends ChangeNotifier` — `HomeLiveController({required Stream<List<Team>> Function(String eventId) teams})`; `void watch(Event? event)` (subscribes when the event id changes, cancels on null; ignores a repeat of the same id); `List<RankedTeam> get ranked` (empty until data, and after a stream error); `Team? own(String teamName)`; `dispose` cancels.
- `LiveLeaderboardSection({required List<RankedTeam> ranked, required String ownName, required int missionCount, required VoidCallback onAll})` — `SectionHeader(top: 16, title: 'Clasament live', link: 'Tot')` then the card (margin 0/14) from `leaderboardPreview`; score `"{mission}/{missionCount}"`, or "–" when `missionCount <= 0`; own name `"{name} · voi"`. Draws nothing when `ranked` lacks the own team.
- `LeaderboardSheet` — every ranked team in one `LeaderboardCard`, shown with `showModalBottomSheet`.
- `TeamNowCard({required Team team, required DateTime now})` — `SectionHeader(top: 16, title: 'Echipa ta')`, then a `.card` (margin 0/14/12): `AvatarStack` (28, initials of the active members, none when nobody is active), 8 px, `activeLine` w500 over `lastMissionLine` 11 muted.

- [ ] **Step 1: Write the failing tests:** the controller with a `StreamController<List<Team>>`: ranks what arrives; `watch` of a new id cancels the old subscription (old stream's listener count back to 0); `watch(null)` clears `ranked`; a stream error leaves `ranked` empty without throwing. Sections: preview rows "1 Bufnițele 5/6", "2 Vulpile · voi 4/6", "3 Lupii de Cetate 4/6" (mockup data); own team missing → no "Clasament live"; "Tot" opens the sheet with every team; `TeamNowCard` with two members seen 1 min ago and one 5 min ago → "2 jucători activi" and two avatars; mission solved 6 min ago → "Ultima misiune rezolvată acum 6 min".
- [ ] **Step 2: Run; expect failures.**
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "Home live: teams stream, live leaderboard and who is playing"`

---

### Task 6: Presence while playing

**Files:**
- Create: `lib/features/event_game/widgets/keeps_presence.dart`
- Modify: `lib/features/event_game/screen/event_game_screen.dart` (wrap inside the existing `RefreshesActiveGame`)
- Test: `test/features/event_game/keeps_presence_test.dart`

**Interfaces:**
- Consumes: `TeamService.markPresent` (Task 1).
- `KeepsPresence({required Future<void> Function() markPresent, required Widget child, Duration every = const Duration(seconds: 60)})` — calls `markPresent` after the first frame and then every `every` while mounted; stops on dispose; a failing call is swallowed (no crash, the next tick tries again). The screen passes `() => teamService.markPresent(event.eventId, team.name, uid)` only when it has a team and a signed-in uid; otherwise it does not wrap.

- [ ] **Step 1: Write the failing tests** (with `tester.pump(Duration)`): one call after the first frame; three after 2 × 60 s; none after the widget is removed and another 60 s pass; a `markPresent` that throws still gets the next tick.
- [ ] **Step 2: Run; expect failures.**
- [ ] **Step 3: Implement and wire into the game screen.**
- [ ] **Step 4: Run; expect PASS.** `flutter test test/features/event_game`
- [ ] **Step 5: Commit** — `git commit -m "Game screen keeps the player's presence fresh"`

---

### Task 7: The Home screen

**Files:**
- Create: `lib/features/home/widgets/home_header.dart`, `lib/features/home/widgets/greeting_stats.dart`, `lib/features/home/widgets/new_events_row.dart`, `lib/features/home/logic/news_seen.dart`
- Modify: `lib/features/home/screen/home.dart`, `lib/features/home/controller/home_controller.dart`, `lib/features/news_dashboard/…` (the Știri screen records the visit; find its screen with `grep -rn "Routes.newsDashboard" lib/main.dart`)
- Delete: `lib/features/home/widgets/events_panel.dart`, `how_it_works_panel.dart`, `news_panel.dart`, `registrations_panel.dart` and their tests in `test/features/home/home_panels_test.dart` and `test/ui/home_text_scale_test.dart` (keep any test there that still applies)
- Test: `test/features/home/home_screen_parts_test.dart`, `test/features/home/news_seen_test.dart`

**Interfaces:**
- `HomeHeader({required bool unread, required VoidCallback onBell})` — `panel` with a 1 px bottom `border`, padding 12/14 (+1): `route` 20 accent, 8, "TeamXperience" 15 w500, at the right a 32 px `iconButtonBg` circle with `bell` 17 and, when `unread`, a 7 px `live` dot 6 from the top and 7 from the right.
- `GreetingStats({required String firstName, required int games, required double distanceMeters, required int xp})` — padding 12/14/0: "Salut, {firstName}" 16 w500; 8 px; a row (gap 6) of `MiniStatCard`s flexed 1 : 1 : 1.3 — games/"jocuri", `kmStat`/"pe jos", `levelFor(xp)` name in accent with its progress bar.
- `NewEventsRow({required List<Event> events, required void Function(Event) onTap, required VoidCallback onAll})` — `SectionHeader(top: 16, title: 'Evenimente noi', link: 'Vezi toate')`, then a horizontal list (padding 0/14, gap 8) of `EventMiniCard` (date `dayAndMonth`, facts `cardRouteFacts`). Nothing when `events` is empty.
- `bool hasUnreadNews(List<Stire> news, DateTime? lastSeen)` (pure) and `class NewsSeenStore { Future<DateTime?> lastSeen(); Future<void> markSeen(DateTime at); }` over `SharedPreferences` key `newsLastSeen`.
- `HomeController` gains `openNews()` (marks seen, then pushes Știri) and keeps the existing navigation helpers.
- `Home` layout: no `MyAppBar`; a `Column` of `HomeHeader` then the scrolling body: `GreetingStats`; 12 px; the hero card (margin 0/14); then **live**: `LiveLeaderboardSection` + `TeamNowCard` (team from `HomeLiveController.own`, falling back to the hero's team); **otherwise**: `NewEventsRow` with `sectionEvents(eventList.events, registeredIds, now).open`. 12 px at the end. `HomeLiveController` lives in `_HomeState`, `watch`es the live hero's event, and is disposed with it. `FadeInSection` keeps fading sections in.

- [ ] **Step 1: Write the failing tests:** `hasUnreadNews` (newer item → true; none newer, or no news → false; never seen with news → true); `NewsSeenStore` round trip with `SharedPreferences.setMockInitialValues({})`; `HomeHeader` dot shows only when unread and tapping the bell calls back; `GreetingStats` shows "Salut, Victor", "3", "jocuri", "12,4 km", "pe jos", "Explorator" for games 3, 12400 m, 800 XP; `NewEventsRow` shows two cards with "21 nov" and "Protocolul Cerber" from `sampleOpenEvents()`, and nothing for an empty list; the Review Focus 5 test: header + greeting + `NextGameCard` + `NewEventsRow`, then header + greeting + `LiveGameCard` + `LiveLeaderboardSection` + `TeamNowCard`, at 320 px and 1.3×, light and dark, no exception.
- [ ] **Step 2: Run; expect failures.**
- [ ] **Step 3: Implement**, delete the old panels, run `flutter analyze` (no new issues).
- [ ] **Step 4: Run `flutter test`; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "Home rebuilt to mockup 02: header, greeting, hero, new events and live sections"`

---

### Task 8: Gallery preview and docs

**Files:**
- Create: `lib/dev/home_preview.dart` (Home before and during an event from mockup data, switch between them, inside the five-tab bar), add it to `shell_previews_launcher.dart` as "Acasă"
- Modify: `lib/dev/sample_event.dart` (mockup teams for the live state: Bufnițele 5/6, Vulpile 4/6 with three present members and a mission 6 min ago, Lupii de Cetate 4/6), `docs/screens.md` (Home), `docs/features.md` (`home` row and folder), `docs/ui-and-theme.md` (the six components and `liveCard`), `CLAUDE.md` if any line changes
- Test: `test/dev/shell_previews_test.dart` (open "Acasă" in both states, light and dark, no exception; the texts "Următorul tău joc" and "Clasament live")

- [ ] **Step 1: Write the failing test.**
- [ ] **Step 2: Run; expect failure.**
- [ ] **Step 3: Implement the preview and update the docs.**
- [ ] **Step 4: Run `flutter test` and `flutter analyze`; expect PASS and no new issues.**
- [ ] **Step 5: Commit** — `git commit -m "Gallery: Home before and during an event; docs"`
