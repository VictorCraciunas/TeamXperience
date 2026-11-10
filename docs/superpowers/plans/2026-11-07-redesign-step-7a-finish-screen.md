# Redesign step 7a: the finish screen — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Mockup 08's finish recap, in the event's own colours. It shows:
- the place out of N teams, the total time and the km walked;
- the mission line with the fastest mission and the hints used;
- the team's approved photos;
- "Cum ți s-a părut?" (stars, saved as feedback);
- "Distribuie" and "Vezi clasamentul".

The screen opens when the team solves its last mission, or when the event ends early (with the partial result).

**Architecture:**
- **The app records the facts:** when the team finished (`finishedAt`), how far each phone walked (`walked.{uid}`, with the team's distance being the longest walk), and the rating (`events/{id}/feedback/{uid}`).
- **The recap is worked out from the team doc and the teams list,** by pure functions in `features/finish/logic`, and drawn by plain-value widgets.
- **Points, XP, badges and memories are 7c** (the results Function), which is parked with 3b. Nothing here depends on it.

**Tech Stack:** Flutter (Dart 3.7), provider, cloud_firestore, geolocator, share_plus (already used).

**Spec:**
- `docs/roadmap/mockups-roadmap.md`: L6.5 (finishing), L6.6 (distance walked), L7.2 (finish screen data), U3.9; also the 2026-11-07 note "Step 7 is split in three".
- The mockup `docs/roadmap/mockups/08-finish-and-profile.html` (left phone), for layout and sizes.
- **Victor's decisions:**
  - the look comes from the event's puzzles;
  - server work waits (7c with 3b).

## Global Constraints

- **Branch:** `redesign/step-7a-finish` from `redesign/mockups`; merge back with `--no-ff`; never push.
- **Layout and colours:**
  - Layout and sizes come from mockup 08 (left). 1 CSS px = 1 logical px; line height 1.45; no box-sizing reset.
  - Colours come from `context.eventPalette` (the mockup's `#8A3B12` → `accent`, `#B8862B` → `secondaryAccent`, `#FBF4E4` → `surface`, `#D9C49C` → `border`, `#3B2A1A` → `ink`).
  - No literal colours in `lib/features`.
- **Code rules:** no `x!` in new code; one widget per file; one controller per screen; `lib/ui` never imports `lib/features`.
- **Data:** new Firestore fields are optional; none is written by `toJson`.
- **Docs:** `docs/data-model.md`, `docs/features.md`, `docs/screens.md` follow in the task that changes them. The roadmap's step 3b list gets the rules this step needs.
- **Copy:**
  - "din {n} echipe" ("din 1 echipă");
  - "timp total";
  - "km pe jos";
  - "Cea mai rapidă: misiunea {n} ({m} min)";
  - "{n} indicii" / "1 indiciu" / "fără indicii";
  - "Pozele voastre";
  - "Cum ți s-a părut?";
  - "Mulțumim!" (after rating);
  - "Distribuie";
  - "Vezi clasamentul".
  - The default end texts, when the organiser wrote none:
    - completed: "Ați terminat traseul!" / "{team} a rezolvat toate cele {m} misiuni.";
    - partial (the event ended first): "Jocul s-a încheiat" / "{team} a rezolvat {k} din {m} misiuni.".
  - The share text: "{team} a terminat „{event}” pe locul {p} din {n}, în {H:MM} și {km} km. #TeamXperience" (without the place part until the ranking arrives).

## Rulings made while planning (report them to Victor)

1. **Points, XP, badges, season, memories and `place` are 7c, parked with 3b.** The place on the finish screen is worked out live from the teams list with 6b's `rankTeams`. It is not stored.
2. **"Harta e completă / Vulpile au moștenit secretul cartografului."** is the organiser's own copy. Events get the optional `finishTitle` and `finishMessage` (editor: "Sfârșitul jocului" in the event form, next to the intro letter; JSON), with the default texts above.
3. **The distance walked:**
   - Every phone of a team runs `LocationService`, so adding all their walks would count the same walk 3–4 times. Each phone adds only its own walk to `walked.{uid}` (Firestore increments, sent in steps of at least 20 m). The team's distance is the longest walk.
   - A fix less accurate than 30 m is ignored.
   - A jump of over 50 m within 5 s is ignored and does not move the last point. The next good fix counts from the point before it.
4. **Finishing:**
   - **Last mission solved:** the puzzle that solves the team's last mission writes `hasFinished` and `finishedAt` (server time, set only if absent; one transaction, like 6a's `startedAt`).
   - **Event ended early:** `EventGameController` still marks every team `hasFinished`, but with no `finishedAt`. The old "Ne pare rău / S-a terminat evenimentul." dialog becomes the finish screen with the partial result.
5. **The leaderboard's "finished":** it stops meaning `hasFinished`, because an event that ends early marks every team finished. A team counts as finished when `missionProgress >= missionCount`. Ties go to the earlier `finishedAt`, else the earlier last mission (as today).
6. **The total time:**
   - from `startedAt` (else the event start) to `finishedAt`;
   - for a partial result, to the event's end (`isStopped` time unknown, so the earlier of now and start + 3 h);
   - shown as "1:48" (H:MM).
7. **The fastest mission:** each mission's time is from the previous mission's `missionCompletedAt` (the first from `startedAt`). It needs at least one solved mission with both times known; otherwise there is no line.
8. **Photos:** the approved try of each photo puzzle that has a `url`, in mission order. Three tiles, the last showing "+N" when there are more. With no photos the section is hidden.
9. **The rating:** 1–5 stars. It is saved to `events/{eventId}/feedback/{uid}` as `{rating, teamName, at}`; tapping again changes it. It shows "Mulțumim!" under the stars once saved.
10. **"Vezi clasamentul"** opens 5's `LeaderboardSheet` (`features/home/widgets`). "Distribuie" shares the text through `ShareService.shareText`.
11. **Leaving the finish screen:** it replaces the route screen; back goes to the shell. Opening the game again for a finished team (Home or Joacă "Continuă", the event page) shows the finish screen through `GameDoor`.

## Review Focus

1. **The event is stopped while a team is mid-puzzle:** the puzzle closes and the finish screen shows the partial result ("3 din 6 misiuni"), not the old dialog, and nothing crashes. (Task 6 test on `finishTarget`.)
2. **Three phones of one team walking together:** the team's km is one walk, not three. GPS noise (a 200 m jump, a 60 m-accuracy fix) adds nothing. (Task 3 tests.)
3. **Missing data:** no `startedAt` (an old team), no `missionCompletedAt`, no photos, one team only. There are no "null" texts, no negative times, and empty sections are hidden. (Task 4 tests.)
4. **A team that finished after the event was stopped elsewhere:** `finishedAt` is set once, and a second phone's finish write does not move it. (Task 1 repo transaction; Task 6.)
5. **The leaderboard right after an early stop:** the teams are ordered by missions solved, not all tied as "finished". (Task 2 test.)

---

### Task 1: Finish, walk and feedback data; the end texts in the editor and JSON

**Files:**
- Modify:
  - Models: `lib/model/team.dart` (`finishedAt`, `walked`, `distanceMeters`) and `lib/model/event.dart` (`finishTitle`, `finishMessage`).
  - Data: `lib/backend/repo/teamRepo.dart` + `lib/service/team_service/team_service.dart`.
  - Import: `lib/service/event_service/event_json_import.dart`.
  - Editor: `create_event_controller.dart` and `widgets/game_start_section.dart` ("Sfârșitul jocului": "Titlul de final", "Mesajul de final").
  - Docs: `docs/data-model.md`, `docs/skills/event-json/SKILL.md`, and the roadmap's 3b list (rules for `walked.{uid}` (own uid, increments only), `finishedAt` (once), `events/{id}/feedback/{uid}` (own uid)).
- Test: `test/model/team_finish_fields_test.dart`, plus additions to `test/model/event_intro_fields_test.dart`, `test/service/event_service/event_json_import_test.dart` and `test/features/admin/create_event/game_start_section_test.dart`.

**Interfaces:**
- `Team.finishedAt` (`DateTime?`, read like `startedAt`).
- `Team.walked` (`Map<String, double>`: whole or decimal numbers; anything else skipped).
- `double get distanceMeters`: the largest value of `walked`, or 0.
- `Event.finishTitle`, `Event.finishMessage` (`String?`).
- `TeamService`:
  - `finishTeam(eventId, teamName, {required bool completed})`: always `hasFinished: true`; with `completed`, `finishedAt` (server time) only if absent, in a transaction;
  - `addWalked(eventId, teamName, uid, double meters)`: an increment;
  - `saveRating(eventId, uid, {required String teamName, required int rating})`: a set on `events/{eventId}/feedback/{uid}` with `at` (server time).

- [ ] **Step 1: Write the failing tests:**
  - `finishedAt` reads a Timestamp, and null while pending.
  - `walked` `{'a': 1200, 'b': 1250.5, 'c': 'x'}` gives `distanceMeters` 1250.5. No walk gives 0. Neither field is in `toJson`.
  - The event round-trips `finishTitle`/`finishMessage`.
  - The import reads both; the editor section shows and writes them (empty saves null).
- [ ] **Step 2: Run; expect failures.** `flutter test test/model test/service/event_service/event_json_import_test.dart test/features/admin/create_event`
- [ ] **Step 3: Implement.** Callers of the old `finishTeam(eventId, teamName)` pass `completed: false` until Task 6.
- [ ] **Step 4: Run; expect PASS; then `flutter test`; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "Finish time, each phone's walk, ratings; the organiser's end texts"`

---

### Task 2: The leaderboard counts a finished route, not a stopped game

**Files:**
- Modify: `lib/service/leaderboard.dart`
- Test: `test/service/leaderboard_test.dart` (add)

**Interfaces:**
- `rankTeams(teams, missionCount:)` keeps its signature.
- Completed: `missionCount > 0 && missionProgress >= missionCount`.
- Order:
  1. completed first;
  2. then more missions;
  3. then the earlier `finishedAt` among completed teams;
  4. then the earlier last mission;
  5. then the name.
- `RankedTeam.mission` is `missionCount` for completed teams.

- [ ] **Step 1: Write the failing tests:**
  - Three teams all `hasFinished` after an early stop, with 4, 2 and 5 missions, rank 5, 4, 2.
  - Two completed teams rank by `finishedAt`.
  - A completed team without `finishedAt` comes after one with it.
  - The existing tests still pass.
- [ ] **Step 2: Run; expect failures.**
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run `flutter test`; expect PASS** (the Home and organiser tests use it).
- [ ] **Step 5: Commit** — `git commit -m "Leaderboard: a finished route, not a stopped game"`

---

### Task 3: The distance walked

**Files:**
- Create: `lib/service/walk_tracker.dart`
- Modify:
  - `lib/service/LocationService.dart`: `startLocationTracking(eventId, teamName, {String? uid})` feeds every fix to a `WalkTracker` and calls `addWalked` whenever the pending distance reaches 20 m; it sends what is left when tracking stops.
  - `lib/features/event_game/controller/event_game_controller.dart`: passes the signed-in uid.
- Test: `test/service/walk_tracker_test.dart`

**Interfaces:**
- `class WalkFix { final double lat, lng, accuracy; final DateTime at; }`
- `class WalkTracker { double add(WalkFix fix); double takePending({double atLeast = 20}); }`
  - `add` returns the metres it counted;
  - `takePending` returns and clears the pending metres when they reach `atLeast`, else returns 0. `takePending(atLeast: 0)` flushes everything.
- Rules (ruling 3): accuracy > 30 is ignored; more than 50 m since the last kept fix within 5 s is ignored (the last kept fix stays); the first kept fix counts 0.

- [ ] **Step 1: Write the failing tests:**
  - Four good fixes 10 m apart give 30.
  - A 60 m-accuracy fix adds 0 and does not become the last point.
  - A 200 m jump 2 s later adds 0, and the next fix counts from the point before the jump.
  - 60 m in 30 s is counted.
  - `takePending`: 15 m pending → 0 (kept); then 25 m → 25 (cleared); `takePending(atLeast: 0)` flushes 7.
- [ ] **Step 2: Run; expect failures.**
- [ ] **Step 3: Implement**; distances with `Geolocator.distanceBetween`.
- [ ] **Step 4: Run; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "Each phone counts its own walk, without GPS jumps"`

---

### Task 4: The recap's logic

**Files:**
- Create: `lib/features/finish/logic/finish_recap.dart`
- Test: `test/features/finish/finish_recap_test.dart`

**Interfaces:**
- `bool routeCompleted(Event event, Team team)`: `missionProgress >= missions.length > 0`.
- `({String title, String message}) finishTexts(Event event, Team team)`: the organiser's (trimmed, non-empty) or the defaults; completed vs partial.
- `String placeLabel(int teams)`: "din 12 echipe" / "din 1 echipă".
- `Duration playedTime(Event event, Team team, DateTime now)` (ruling 6) and `String hoursMinutes(Duration d)`: "1:48"; zero for a negative duration.
- `String kmLabel(double meters)`: "4,7" (one decimal, comma).
- `({int mission, int minutes})? fastestMission(Team team)` (ruling 7) and `String fastestLine(({int mission, int minutes}) f)`: "Cea mai rapidă: misiunea 2 (6 min)"; minutes rounded, at least 1.
- `String hintsLabel(Team team)`: counts `hintsUsed` true values ("2 indicii" / "1 indiciu" / "fără indicii").
- `List<String> approvedPhotos(Team team)` (ruling 8: URLs in mission, puzzle, try order).
- `String shareLine(Event event, Team team, ({int place, int teams})? place, Duration time)`.

- [ ] **Step 1: Write the failing tests:**
  - `finishTexts`:
    - completed with no organiser text: "Ați terminat traseul!" / "Vulpile a rezolvat toate cele 6 misiuni.";
    - partial: "Jocul s-a încheiat" / "Vulpile a rezolvat 3 din 6 misiuni.";
    - the organiser's text wins;
    - blank organiser text falls back.
  - `placeLabel(1)` → "din 1 echipă".
  - `playedTime`:
    - 1 h 48 m between `startedAt` and `finishedAt` → "1:48";
    - partial, before 3 h → up to now;
    - after 3 h → capped;
    - no start at all → zero.
  - `kmLabel(4712)` → "4,7"; `kmLabel(0)` → "0,0".
  - `fastestMission`: completions at +20, +26 and +40 min from a start → mission 2, 6 min; none → null.
  - `hintsLabel`: 2, 1 and 0.
  - `approvedPhotos`: skips pending, rejected and URL-less tries; keeps the order.
  - `shareLine` with and without a place.
- [ ] **Step 2: Run; expect failures.**
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "Finish recap logic: texts, time, km, fastest mission, hints, photos, share"`

---

### Task 5: The finish view

**Files:**
- Create in `lib/features/finish/widgets/`:
  - `finish_seal.dart`: 74 content + 3 px `secondaryAccent` border (80 across), a `surface` fill, and a 34 px `map_2` icon in `accent`.
  - `finish_stat_tile.dart`: a `surface` fill with a 1 px `border` and radius 12; padding 8/0 plus the border; the value at 20 w500 (`accent` for the place; Monospace for the time); the label at 11, ink 80 %.
  - `mission_dots_card.dart`: the mockup's line inside a `surface` card (padding 8/10, radius 12):
    - 12 px dots joined by 2 px lines, then a 15 px flag;
    - solved missions in `accent`, the rest as an `accent` ring;
    - under it, the fastest line left and the hints label right, at 11, ink 80 %.
  - `photo_strip.dart`: up to three 64 px tiles (radius 10, gap 6). The third shows "+N" (w500, `onAccent` on `secondaryAccent`) when there are more.
  - `rating_stars.dart`: five 22 px stars in `secondaryAccent` with gap 10. `star_filled` up to the rating, `star` after. "Mulțumim!" at 11 under them once rated.
  - `finish_view.dart`: assembles everything from plain values. Its bar (padding 14, gap 8) is `GameOutlineButton` "Distribuie" with a share icon (flex 1) and `GameFilledButton` "Vezi clasamentul" (flex 1.3). Sections without data are hidden, and the page scrolls.
- Test: `test/features/finish/finish_view_test.dart`

**Interfaces:**
- `FinishView({required String title, required String message, required String? place, required String placeLabel, required String time, required String km, required int missions, required int solved, String? fastest, required String hints, required List<String> photos, int? rating, required ValueChanged<int> onRate, required VoidCallback onShare, required VoidCallback onLeaderboard})`
  - `place` is null until the ranking arrives; the tile then shows "–".
- Sizes:
  - top padding 26/16; title at 21 in `voiceFont`, 10 below the seal; message at 12, ink 80 %;
  - tiles row with margin 16/14/0 and gap 6;
  - mission card with margin 12/14/0;
  - section labels at 11 (80 %) with margin 12/14/6.

- [ ] **Step 1: Write the failing tests:**
  - The mockup's values all show: "Harta e completă", "2", "din 12 echipe", "1:48", "timp total", "4,7", "km pe jos", "Cea mai rapidă: misiunea 2 (6 min)", "2 indicii", "Pozele voastre" with "+4" (6 photos), and five stars.
  - The seal is 80 across.
  - Tapping the fourth star calls `onRate(4)`, and with `rating: 4` four stars are filled with "Mulțumim!" shown.
  - With no photos, no "Pozele voastre"; with no fastest line, only the hints label.
  - Place null → "–".
  - Both buttons call back.
  - Neon palette; 320 px at 1.3×, no overflow.
- [ ] **Step 2: Run; expect failures.**
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "Finish view as mockup 08"`

---

### Task 6: The finish screen and the way there

**Files:**
- Create:
  - `lib/features/finish/controller/finish_controller.dart`;
  - `lib/features/finish/screen/finish_screen.dart`;
  - `lib/features/finish/logic/finish_target.dart`.
- Modify:
  - Routing: `lib/constants/routes.dart` (`Routes.finish = '/finish'`) and `lib/main.dart`.
  - The game: `puzzle_game_controller.dart` (the last mission → `finishTeam(completed: true)`), `event_game_controller.dart` (`finishTeam(completed: false)` on an early end; exposes `finished`) and `event_game_screen.dart` (replaces the dialog: on `finished` or `eventEnded` it `pushReplacementNamed(Routes.finish, {'event', 'team'})` once).
  - The door: `lib/features/game_intro/logic/game_door.dart` sends a finished team (`hasFinished`) to `Routes.finish`.
  - Docs: `docs/features.md`, `docs/screens.md`.
- Test: `test/features/finish/finish_target_test.dart`, `test/features/game_intro/game_door_test.dart` (add if it exists, else create).

**Interfaces:**
- `bool showFinish(Event event, Team team, {required bool eventEnded})`: true when `routeCompleted` or `eventEnded` or `team.hasFinished`.
- `FinishController(ChangeNotifier)`:
  - takes the event and team plus the injectable `Stream<List<Team>> teams`, `Stream<Team> team`, `Future<void> Function(int) saveRating` and `DateTime Function() clock`;
  - exposes `team`, `place` (`({int place, int teams})?`), `rating` (`int?`), `rate(int)` (saves, keeps the local value even if the write fails), `ranked` (`List<RankedTeam>`) and `shareText`.
- The screen:
  - wraps `FinishView` in `EventThemeScope(eventPaletteOf(...))` + `GameBackdrop`;
  - `onLeaderboard` opens `showLeaderboardSheet(context, ranked:, ownName:, missionCount:)`;
  - `onShare` calls `ShareService().shareText(context, subject: event name, text: controller.shareText)`.

- [ ] **Step 1: Write the failing tests:**
  - `showFinish`: true after the last mission, true when the event ended, true for a `hasFinished` team, false mid-game.
  - `FinishController`, with fake streams:
    - the place appears when the teams arrive;
    - `rate(4)` saves 4 and keeps it when the save throws;
    - the share text has the place once known.
  - The door sends a finished team to the finish route.
- [ ] **Step 2: Run; expect failures.**
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run `flutter test`; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "Finish screen: opened by the last mission or the end of the event"`

---

### Task 7: Gallery preview and docs

**Files:**
- Create: `lib/dev/finish_preview.dart` (completed with the mockup's values / partial; parchment / neon).
- Modify:
  - `lib/dev/sample_event.dart`: `sampleFinishedTeam()`, with `startedAt`, `finishedAt` 1:48 later, `walked`, `missionCompletedAt`, two hints and six approved photo URLs. The sample event gets `finishTitle: 'Harta e completă'` and `finishMessage: 'Vulpile au moștenit secretul cartografului.'`.
  - `lib/dev/shell_previews_launcher.dart` ("Final").
  - Docs: `docs/screens.md`, `docs/features.md` (`features/finish`), `docs/roadmap/mockups-roadmap.md` (7a done).
- Test: `test/dev/shell_previews_test.dart` (both states, both looks, light and dark; the launcher opens it).

- [ ] **Step 1: Write the failing test.**
- [ ] **Step 2: Run; expect failure.**
- [ ] **Step 3: Implement and update the docs.**
- [ ] **Step 4: Run `flutter test` and `flutter analyze`; expect PASS and no new issues.**
- [ ] **Step 5: Commit** — `git commit -m "Gallery: the finish recap in two looks; docs"`
