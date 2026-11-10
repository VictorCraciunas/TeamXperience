# Redesign step 2: the event page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** The player's event page looks and behaves like mockup 01, and organisers can enter every value it shows.

**Architecture:**
- **Data:** the `Event` and `Mission` models get the new fields (all optional, so old documents still load), with fallback getters for the old free-text fields.
- **Logic:** pure functions in `lib/features/event_details/logic/` decide every text, number and bar state, and are unit tested.
- **Screen:** split in two.
  - `EventPageView` is a stateless widget that takes an `EventPageData` and callbacks. It is tested and shown in the gallery with the mockup's sample event.
  - `EventDetailsScreen` only wires `EventDetailsController` (Firestore, providers, navigation) to it.
- **Organisers:** the event form, mission editor, completeness checks and JSON import learn the new fields.

**Tech Stack:** Flutter, provider, url_launcher (open the start pin in maps), share_plus through `ShareService`, flutter_tabler_icons.

**Spec:**
- `docs/roadmap/mockups-roadmap.md`: L1.1, L1.2, L3.1, L3.2, L9 and U3.1, step 2 of "Order and size".
- Visual reference: `docs/roadmap/mockups/01-event-details.html`.

**Not in this step**, and the step that does each:
- "De la ediția trecută" (past photos and winner): needs finish times and approved photos, so step 7.
- Puzzle fields (attempts, wrong-answer message, radius, badge) and `EventTheme`: step 6.
- Intro letter and finish text: step 6.
- `seriesId`: step 7.
- `enterWindowMinutes`: step 6. Until then `Event.enterWindow` stays 60 min.
- Map picking of mission pins and mission minutes: step 6.

## Global Constraints

- Branch `redesign/step-2-event-page` from `redesign/mockups`. Merge back into `redesign/mockups` only. Never `main`, never push.
- 1 mockup CSS px = 1 logical px. CSS borders sit outside the padding, Flutter draws them inside, so add 1 to the padding next to a 1 px border. Mockup text has line height 1.45.
- Colours from `context.colors`, with no literals in `lib/features` (`no_hardcoded_colors_test` stays green with no new allow-list entries). Text on the amber badge uses `onTick`.
- Components in `lib/ui/components/` take their copy as parameters. One widget per file. No `x!`. Screens stay thin, and the logic lives in controllers and `logic/` files.
- Every new field is optional in Firestore and in JSON import. Old documents read as the defaults below, and `toJson` writes every new field.
- All copy is Romanian, as in the mockup. Short months follow the mockup: `ian feb mar apr mai iun iul aug sep oct nov dec`. Note "nov", not `CalendarHelper`'s "noi".
- After every task, `flutter analyze` shows no new issues and `flutter test` passes. Commit messages end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Update `docs/data-model.md`, `docs/screens.md` and `docs/skills/event-json/SKILL.md` in the task that changes what they describe.

## Review Focus

1. **An event saved before this step**, with `dificultate: "Medie"`, `lungimeTraseu: "4.5 km"`, `durata: "2 ore"` and no new fields, must open with dots ●●○, "4,5 km" and "2 h", not blanks or a crash. Covered in Task 1 and Task 6.
2. **An event with no public teasers, or no missions at all.** The trail must show only the secret row, or skip "Ce vă așteaptă" entirely, never an empty card. Covered in Tasks 3 and 6.
3. **The registration deadline is today, already passed, or not yet open.** The badge and the bar must say "ultima zi", "Înscrieri închise" or "Înscrieri de pe 1 nov", with no negative day counts. Covered in Task 4.
4. **A long event name or area at 320 px and 1.3× text.** The hero must wrap the name to at most 2 lines with an ellipsis, with no overflow. Covered in Task 6.
5. **A registered user whose team was deleted.** The bar must fall back to the open or closed state, not show "Echipa ta" for a team that doesn't exist. Covered in Task 4.

---

### Task 1: Event fields

**Files:**
- Create: `lib/enums/difficulty.dart`
- Modify: `lib/model/event.dart` (constructor, fields, `fromMap`, `toJson`, new getters), `docs/data-model.md`
- Test: `test/model/event_fields_test.dart`

**Interfaces:**
- Produces:
  - `enum Difficulty { easy, medium, hard }` with `static Difficulty? fromName(String?)`
  - New `Event` fields:

    | field | type | default |
    |---|---|---|
    | `area` | `String?` | |
    | `finishPoint` | `String?` | |
    | `routeLengthKm` | `double?` | |
    | `durationMinutes` | `int?` | |
    | `difficulty` | `Difficulty?` | |
    | `teamSizeMin` | `int` | 2 |
    | `teamSizeMax` | `int` | 6 |
    | `maxTeams` | `int?` | |
    | `startLatitude`, `startLongitude` | `double?` | |
    | `meetingPointNote` | `String?` | |
    | `arriveMinutesBefore` | `int` | 15 |
    | `whatToBring` | `List<String>` | `[]` |
    | `story` | `String?` | |
    | `organiserName` | `String?` | |

  - Getters:
    - `double? get effectiveRouteKm`
    - `int? get effectiveDurationMinutes`
    - `Difficulty? get effectiveDifficulty`
    - `String get storyText`
    - `bool get hasStartPin`

Fallback rules for the getters:

| getter | new field set | otherwise |
|---|---|---|
| `effectiveRouteKm` | `routeLengthKm` | the first number in `lungimeTraseu`, with a comma or a dot (`"4,5 km"` → 4.5, `"3.2"` → 3.2, `"ușor"` → null) |
| `effectiveDurationMinutes` | `durationMinutes` | parse `durata`: `"2 h"`, `"2 ore"`, `"2h"` → 120; `"1 h 30"`, `"1h30"`, `"1 oră 30 min"` → 90; `"90 min"` → 90; anything else → null |
| `effectiveDifficulty` | `difficulty` | `dificultate` lower-cased, diacritics ignored: contains `usor` → easy, `medi` → medium, `grea` or `dific` → hard, else null |
| `storyText` | `story` when not blank | `description ?? ''` |
| `hasStartPin` | both coordinates set | false |

- [ ] **Step 1: Write the failing tests.**
  - A map with none of the new keys gives the defaults: `teamSizeMin == 2`, `teamSizeMax == 6`, `arriveMinutesBefore == 15`, `whatToBring` empty, the rest null.
  - `toJson` then `fromMap` keeps every new field. Feed the Timestamps through `fromMap` the way the existing model tests do.
  - Each fallback row above, with one case per input listed.
  - `storyText` falls back to `description` when `story` is `'  '`.
  - `Difficulty.fromName('nope')` is null.

- [ ] **Step 2: Run** `flutter test test/model/event_fields_test.dart`. Expected: FAIL to compile.

- [ ] **Step 3: Implement.** Write the enum by `.name`, as the other enums are. `whatToBring` reads `List<dynamic>` mapped to `String`. Add the fields to `docs/data-model.md`, under Event.

- [ ] **Step 4: Run the tests and the whole suite.** Expected: PASS. Existing event tests are unchanged.

- [ ] **Step 5: Commit** with the message "Event: fields for the new event page, with fallbacks for old text fields".

### Task 2: Mission fields and copies that keep them

**Files:**
- Modify: `lib/model/mission.dart`, `lib/features/admin/create_event/create_missions_and_puzzles/controller/add_missions_controller.dart:71,86`, `docs/data-model.md`
- Test: `test/model/mission_fields_test.dart`, `test/features/admin/create_event/add_missions_controller_test.dart`

**Interfaces:**
- Produces:
  - `Mission.title` (`String?`), `Mission.teaser` (`String?`), `Mission.isTeaserPublic` (`bool`, default false)
  - `Mission withId(String newId)`, which keeps puzzles, title, teaser and isTeaserPublic

- [ ] **Step 1: Write the failing tests.**
  - The new fields round-trip through `toJson` / `fromMap`.
  - An old map gives null, null and false.
  - `withId('3')` keeps every field.
  - In the controller test: after `removeMission(0)` and after `moveMission(0, 1)`, the remaining missions keep their titles and teasers.

- [ ] **Step 2: Run** them. Expected: FAIL.

- [ ] **Step 3: Implement.** The two list rebuilds in `AddMissionsController` use `withId(i.toString())` instead of `Mission(id:, puzzles:)`.

- [ ] **Step 4: Run** `flutter test test/model test/features/admin`. Expected: PASS.

- [ ] **Step 5: Commit** with the message "Mission: title, teaser and public flag, kept when missions move".

### Task 3: Event page formats and content (logic)

**Files:**
- Create: `lib/utils/event_formats.dart` (the admin form uses it too, in Task 8), `lib/features/event_details/logic/event_page_content.dart`
- Test: `test/utils/event_formats_test.dart`, `test/features/event_details/event_page_content_test.dart`

**Interfaces:**
- Produces, in `lib/utils/event_formats.dart`:

  | function | result |
  |---|---|
  | `String formatKm(double km)` | 4.5 → `'4,5 km'`, 4.0 → `'4 km'`, 12.25 → `'12,3 km'` (one decimal at most) |
  | `String formatDuration(int minutes)` | 120 → `'2 h'`, 90 → `'1 h 30'`, 45 → `'45 min'`, 125 → `'2 h 05'` |
  | `String difficultyLabel(Difficulty d)` | `'Ușoară' / 'Medie' / 'Grea'` |
  | `int difficultyLevel(Difficulty d)` | 1 / 2 / 3 |
  | `String shortMonth(int month)` | `'nov'` for 11 |
  | `String dayAndMonth(DateTime d)` | `'14 nov'` |
  | `String monthAndTime(DateTime d)` | `'nov · 10:00'` |
  | `String eventDayLine(DateTime start, int arriveMinutesBefore)` | `'Sâmbătă 14 nov · 10:00 · fii acolo la 9:45'` (day names from `CalendarHelper`'s full Romanian days; the arrive time has no leading zero) |
  | `String initialsOf(String name)` | `'TeamXperience'` → `'TX'` (one word: its first two capitals, else its first letter), `'Ana Pop'` → `'AP'`, `'x'` → `'X'`, `''` → `''` |
  | `String routeSummary(double? km, int missions)` | `'4,5 km · 6 misiuni'`; `'1 misiune'`; with no km, just `'6 misiuni'` |
  | `String teamSizeLine(int min, int max)` | `'Echipe de 2–6'` (en dash); equal → `'Echipe de 4'` |

- Produces, in `event_page_content.dart`:
  - `class MissionTeaser { final int number; final String title; final String teaser; }`
  - `({List<MissionTeaser> shown, int secret}) missionTeasers(Event e)`
    - `shown` is the missions with `isTeaserPublic` and a non-blank `title`, numbered by position (1-based), and `teaser` may be `''`.
    - `secret` is the rest of the missions.
  - `String secretMissionsLine(int n)`: `'Încă 4 misiuni secrete'`, `'Încă o misiune secretă'` for 1.
  - `enum PuzzleKind { codes, photos, places }`
  - `List<PuzzleKind> puzzleKinds(Event e)`: in that order, only kinds present among all puzzles. `code` → codes, `imageToUpload` → photos, `geolocation` → places. Other types add nothing.
  - `String puzzleKindLabel(PuzzleKind k)`: `'Coduri' / 'Fotografii' / 'Locuri pe hartă'`

- [ ] **Step 1: Write the failing tests.** One assertion per row and case above. For `missionTeasers`: 6 missions with missions 1–2 public and titled, and mission 3 public but with a blank title, give 2 shown and 4 secret. An event with no missions gives `([], 0)`.
- [ ] **Step 2: Run** the tests. Expected: FAIL to compile.
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run** the tests. Expected: PASS.
- [ ] **Step 5: Commit** with the message "Event page: formats and the mission and puzzle-kind content".

### Task 4: Hero badge and sign-up bar states (logic)

**Files:**
- Create in `lib/features/event_details/logic/`: `hero_badge.dart`, `signup_bar_state.dart`
- Test: `test/features/event_details/hero_badge_test.dart`, `test/features/event_details/signup_bar_state_test.dart`

**Interfaces:**
- Consumes: `Event.enterWindow`, `Event.isOver` (it reads the clock; pass `now` and test with `isStopped` and dates in the future), and `dayAndMonth` from Task 3.
- Produces:
  - `enum HeroBadgeKind { open, soon, live, closed }`
  - `class HeroBadge { final HeroBadgeKind kind; final String label; }`
  - `HeroBadge? heroBadge(Event e, DateTime now)`
  - `enum SignupAction { register, teamDetails, enterCode, continueGame, none }`
  - `enum SignupTone { neutral, success, accent }`, mapped by the screen to `BarTone`
  - `class SignupBar { final String title; final String? detail; final bool inlineDetail; final SignupTone tone; final bool highlighted; final bool prominent; final String? actionLabel; final SignupAction action; }`
  - `SignupBar signupBar({required Event event, required DateTime now, Team? team, required int teamsCount})`

`daysLeft` is calendar days from `now` to the deadline (dates only, not hours). 0 means the deadline is today.

`heroBadge` returns:

| condition | kind and label |
|---|---|
| event over | null |
| `now` within `[start, start + Event.enterWindow]` | live, `'LIVE'` |
| enrolment not open yet | soon, `'Înscrieri de pe {dayAndMonth(start enrolment)}'` |
| enrolment open | open: `'Înscrieri deschise · încă 5 zile'`, `'încă o zi'` for 1, `'ultima zi'` for 0 |
| otherwise | closed, `'Înscrieri închise'` |

`signupBar`, first matching row wins:

| condition | title | detail | tone / flags | action |
|---|---|---|---|---|
| event over | `'Evenimentul s-a încheiat'` | — | neutral | none |
| team and `team.hasStarted && !team.hasFinished` | `'Echipa {name} e în joc'` | — | accent, highlighted, quiet | `'Continuă'` → continueGame |
| team and inside the enter window | `'A început'` | `'{m} min să intri'` (minutes left, rounded up), inline | accent, highlighted, quiet | `'Introdu codul'` → enterCode |
| team | team name | `'{numberOfMembers} membri'` (`'1 membru'`), inline | success, quiet | `'Echipa ta'` → teamDetails |
| enrolment not open | `'Înscrierile se deschid pe {dayAndMonth}'` | — | neutral | none |
| enrolment closed | `'Înscrierile s-au închis'` | `'{teamsCount} echipe înscrise'` | neutral | none |
| `maxTeams != null && teamsCount >= maxTeams` | `'Nu mai sunt locuri'` | `'{teamsCount} echipe înscrise'` | neutral | none |
| otherwise | `'Mai sunt 5 zile'` (`'Mai e o zi'` for 1, `'Ultima zi'` for 0) | `'{teamsCount} echipe înscrise'` (`'o echipă înscrisă'` for 1, `'Fii prima echipă'` for 0) | prominent | `'Înscrie echipa'` → register |

Enrolment is open when `dateStartEnrollment` is null or ≤ now, and `dateDeadlineEnrollment` is null or ≥ now by date.

- [ ] **Step 1: Write the failing tests.**
  - One test per row of each table. Use a fixed event dated 2026-11-14 10:00, with enrolment 2026-11-01 to 2026-11-12.
  - Review Focus 3: the deadline is today, so it gives `'ultima zi'` and `'Ultima zi'`; the deadline has passed; enrolment is not yet open.
  - Review Focus 5: a null team on a registered user's event gives the open or closed rows. The caller passes `team: null` when the lookup finds nothing.
- [ ] **Step 2: Run** the tests. Expected: FAIL.
- [ ] **Step 3: Implement** both as pure functions with no Flutter imports.
- [ ] **Step 4: Run** the tests. Expected: PASS.
- [ ] **Step 5: Commit** with the message "Event page: hero badge and sign-up bar states".

### Task 5: Sticky action bar without an action

**Files:**
- Modify: `lib/ui/components/buttons/sticky_action_bar.dart`
- Test: `test/ui/components/sticky_action_bar_test.dart`

**Interfaces:**
- Produces: `StickyActionBar.actionLabel` becomes `String?`. When it is null there is no button or link, and the texts take the full width.

- [ ] **Step 1: Write a failing test.** A bar with no `actionLabel` shows only its title, finds no `InkWell`, and doesn't overflow at 320 / 1.3×.
- [ ] **Step 2: Run** it. Expected: FAIL (it doesn't compile, because `actionLabel` is required).
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run** `flutter test test/ui/components/sticky_action_bar_test.dart`. Expected: PASS.
- [ ] **Step 5: Commit** with the message "Sticky bar can show a status with no action".

### Task 6: Event page view (UI)

**Files:**
- Create in `lib/features/event_details/`:
  - `logic/event_page_data.dart`
  - in `widgets/`:
    - `event_page_view.dart`
    - `event_hero.dart`, `event_hero_pattern.dart` (the `CustomPainter` of rings), `hero_round_button.dart`, `hero_badge_pill.dart`
    - `event_facts.dart`
    - `story_section.dart`
    - `mission_teaser_card.dart`, `mission_teaser_row.dart`, `secret_missions_row.dart`
    - `how_you_play_section.dart`, `play_fact_card.dart`
    - `logistics_section.dart`, `logistics_row.dart`, `mini_route_sketch.dart`
    - `organiser_card.dart`
- Test: `test/features/event_details/event_page_view_test.dart`

**Interfaces:**
- Consumes: Tasks 1, 3, 4 and 5, and the step 1 components (`RouteStrip`, `FactRow`, `FactTile`, `DateFactTile`, `DifficultyDots`, `RouteTrail`, `RouteTrailSection`, `AppChip`, `StickyActionBar`).
- Produces:
  - `class EventPageData { final Team? team; final int teamsCount; final int organiserEventsCount; final bool isAdmin; }`
  - `EventPageView({required Event event, required EventPageData data, required DateTime now, required VoidCallback onBack, required VoidCallback onShare, VoidCallback? onOpenMap, VoidCallback? onMessageOrganiser, required void Function(SignupAction) onSignupAction, List<Widget> adminActions = const [], bool showHeroButtons = true})`

Layout, from top to bottom, matching mockup 01. Sizes are in CSS px, and the page background is `page`.

1. **`EventHero`**, 200 tall.
   - Background: `landingImageUrl` as a cover image (`CachedNetworkImage` for http, `Image.file` for a local path), with a gradient from transparent to `navy` at 0.85 alpha over the bottom half. With no image: `navy` with `EventHeroPattern`, which draws rings 19 px apart, each 1 px of `tickOnNavy` at 18 % alpha, centred at (70 %, 40 %).
   - Top row, 12 from the edges: two 32×32 `HeroRoundButton`s in `heroButton`, with `TablerIcons.arrow_left` / `TablerIcons.share` at 16 in `text`.
   - Bottom block, 14 from the edges:
     - `HeroBadgePill`: `soon` fill with `onTick` text for open and soon, `live` with `onNavy` for live, and `onNavyFaint` with `onNavy` for closed. 11 / w500, padding 2 / 9, pill radius.
     - Then 8 below, the name in `heroTitle` / `onNavy`, at most 2 lines with an ellipsis.
     - Then `location · area` at 11 px in `onNavy` at 0.85 opacity.
2. **`RouteStrip`**:
   - `centerLabel: routeSummary(event.effectiveRouteKm, event.missions.length)`
   - `startLabel: punctDeStart`, `endLabel: finishPoint ?? ''`
   - `mapLabel: 'Hartă'`, and `onMapTap: onOpenMap`, given only when `hasStartPin`
3. **`EventFacts`**: a `FactRow`.
   - `DateFactTile(day: '14', detail: monthAndTime)`
   - `FactTile(TablerIcons.clock, formatDuration, 'durată')`
   - `FactTile(leading: DifficultyDots(level), difficultyLabel, 'dificultate')`
   - `FactTile(TablerIcons.users, '$teamsCount', 'echipe')`
   - A fact with no value (no duration or no difficulty) is left out, and the others share the width.
4. **`RouteTrail`** with these sections, in order. A section with nothing to show is skipped.
   - **"Povestea"** (`trailHeading`, 6 below it): `storyText` in `pageBody`, collapsed to 3 lines. "Citește tot" (11 / w500, `accent`) expands it, and "Mai puțin" collapses it. The link is shown only when the text is longer than 3 lines. Skipped when `storyText` is blank.
   - **"Ce vă așteaptă"**:
     - A card (`panel`, 1 px `border`, radius 14, no padding) of `MissionTeaserRow`s, each with padding 9 / 12, a gap of 10 and a 1 px `insetBorder` divider:
       - a 22 px `tick` circle with the number (w500, `onTick`)
       - the title in `cardTitle`, with the teaser below it in `smallMuted`
     - Then the `SecretMissionsRow`, with an `inset` fill and bottom radius 14:
       - a 22 px dashed `muted` circle with `TablerIcons.lock` at 12
       - `secretMissionsLine`, with "Se deblochează în ziua jocului" below it
     - Then 8 below, the `AppChip`s of `puzzleKinds`, with icons `TablerIcons.key`, `camera` and `current_location`.
     - Skipped when there are no missions.
   - **"Cum jucați"**: two `PlayFactCard`s in a row with a gap of 6.
     - `TablerIcons.users_group` at 18 in `accent`, `teamSizeLine(...)`, then "Fiecare pe telefonul lui, aceleași indicii."
     - `TablerIcons.trophy`, "Clasament live", then "Toate echipele, același traseu."
   - **"Logistică"**: a card with no padding.
     - On top, a 58 px `MiniRouteSketch` on `inset` with a bottom `insetBorder`. It is a `CustomPainter` drawing the mockup curve `M20 44 C 80 10, 140 50, 200 20 S 270 30, 282 14`, scaled to the width, as a 2 px `tick` line dashed 5 / 4, with end dots of radius 5 in `accent` and `navy`.
     - Then `LogisticsRow`s (icon 15 in `accent`, gap 8) with padding 8 / 12 and a gap of 6:
       - map_pin: **"Start:"** in w500, then `meetingPointNote ?? punctDeStart`
       - calendar: `eventDayLine`
       - hourglass: `'Înscrieri până pe {dayAndMonth(deadline)}'`, only when there is a deadline
       - backpack: `whatToBring.join(', ')`, only when the list isn't empty
   - **"Organizator"**, the `finish` waypoint: a card with padding 10 / 12.
     - A 34 px `navy` circle with `initialsOf(name)` in `onNavy`.
     - The name in `cardTitle`, with `'{n} evenimente organizate'` below it in `smallMuted` (`'un eveniment organizat'` for 1).
     - `TablerIcons.message_circle` at 18 in `accent`, only when `onMessageOrganiser` isn't null.
     - The name is `organiserName`, or `'TeamXperience'` when that is blank.
5. **Admin actions:** `adminActions`, when not empty, as a column after the trail, with 16 page padding and a gap of 12.
6. **The bar:** the `Scaffold.bottomNavigationBar` is a `StickyActionBar` built from `signupBar(...)`, or nothing when `data.isAdmin`. `SignupTone` maps to `BarTone`, and the icon follows the tone: success → `circle_check`, accent → `player_play`, neutral → none. The prominent button uses `users_plus`. Tapping it calls `onSignupAction(bar.action)`.

The body is a `CustomScrollView`, with the hero outside any `SafeArea` and the top padding taken by the hero.

- [ ] **Step 1: Write the failing tests** with a sample event built in the test (the mockup's: "Moștenirea Cartografului", Sibiu, area "Orașul de Sus", 4.5 km, 6 missions with 2 public, 120 min, medium, …). Use `pumpUi`-style wrapping in a `MaterialApp` with a 390-wide view.
  - The mockup's copy is found: `'4,5 km · 6 misiuni'`, `'nov · 10:00'`, `'Medie'`, `'Scara Pasajului'`, `'Încă 4 misiuni secrete'`, `'Echipe de 2–6'`, `'Sâmbătă 14 nov · 10:00 · fii acolo la 9:45'`, `'TX'`, `'Mai sunt 5 zile'`, `'Înscrie echipa'`.
  - Tapping "Înscrie echipa" calls `onSignupAction(SignupAction.register)`.
  - With a team, the bar shows `'Echipa ta'`, and tapping it gives `teamDetails`.
  - A long story shows "Citește tot", and after a tap "Mai puțin".
  - With no missions, "Ce vă așteaptă" isn't found.
  - No start pin means no "Hartă" chip.
  - The old-event case (Review Focus 1): an event with only `dificultate: 'Medie'`, `lungimeTraseu: '4.5 km'`, `durata: '2 ore'` and 6 missions shows `'●●○'`, `'4,5 km · 6 misiuni'` and `'2 h'`.
  - At 320 / 1.3× with a 90-character name, `takeException()` is null.
  - In the dark theme, `takeException()` is null.
- [ ] **Step 2: Run** `flutter test test/features/event_details/event_page_view_test.dart`. Expected: FAIL.
- [ ] **Step 3: Implement the widgets.** Each one gets its own file, takes plain values, and contains no Firestore code.
- [ ] **Step 4: Run** the tests, then `flutter test test/ui/no_hardcoded_colors_test.dart`. Expected: PASS.
- [ ] **Step 5: Commit** with the message "Event page view built from the mockup".

### Task 7: Event details screen and controller

**Files:**
- Modify: `lib/features/event_details/controller/event_details_controller.dart`, `lib/features/event_details/screen/event_details_screen.dart`
- Delete: `lib/features/event_details/widgets/already_registered_card.dart`, and `detail_widget.dart` if nothing else imports it (check with grep)
- Modify: `docs/screens.md` (event details section), `test/ui/colour_allowlist.txt` (drop entries for deleted files)

**Interfaces:**
- Consumes: Task 6's `EventPageView` and `EventPageData`, and `SignupAction`.
- Produces: `EventDetailsController` (a `ChangeNotifier`) with:
  - `EventPageData data`
  - `Future<void> load()`, which runs `getTeams` for the count and `getUserTeamForEvent` for the user's team. A lookup that throws leaves `team` null.
  - `void onSignupAction(SignupAction a)`:

    | action | goes to |
    |---|---|
    | register | `Routes.registerTeam` with the event |
    | teamDetails | `Routes.registerTeamDetails` with `{'event', 'user'}` |
    | enterCode | `Routes.enterCodeScreen` with the event |
    | continueGame | `Routes.eventGame` with `{'event', 'team'}` |
    | none | nothing |

  - `void share()`, through `ShareService.shareText` with subject = name, and text = name, date line and `punctDeStart`
  - `void openMap()`: `url_launcher` on `https://www.google.com/maps/search/?api=1&query={lat},{lng}`
  - `void messageOrganiser()`: `Routes.chatScreen` with `{'eventId', 'team'}`, offered only when there is a team
  - `navigateToMap()`: the existing admin team map, kept
  - the organiser count: the published events in `EventList` with the same organiser name, where a blank name counts as 'TeamXperience'

The screen reads its arguments as today (`{'event', 'isAdmin'}`), builds `EventPageView` and passes `DateTime.now()`.

For admins, who are not in the mockup:
- The screen keeps today's `MyAppBar` with the dropdown menu (`showDropdown: true`). The menu is an overlay owned by `MyAppBar`, so it stays there.
- `EventPageView` gets `showHeroButtons: false`, so the hero has no round buttons under the app bar.
- `adminActions` are the existing "Vezi echipele înscrise" and "Gestionează evenimentul" `AppButton`s.

Add `bool showHeroButtons = true` to Task 6's `EventPageView` signature.

- [ ] **Step 1: Write a failing test** for the pure part. `organiserEventsCount(List<Event> published, String? name)` sits in `event_page_content.dart`. It counts events whose effective organiser matches, with blank counted as 'TeamXperience'.
- [ ] **Step 2: Run** it, watch it fail, implement it, and run it to pass.
- [ ] **Step 3: Rewrite the controller and screen** as above. Remove `AlreadyRegisteredCard`, and the screen's own `Consumer` / `isRegistered` logic, which `signupBar` replaces.
- [ ] **Step 4: Verify.** Run `flutter analyze` (no new issues) and `flutter test` (all pass). Then run the app on a device and open an event as a player and as an admin; tell Victor if no device is attached.
- [ ] **Step 5: Commit** with the message "Event details screen uses the new event page".

### Task 8: Event form fields (organisers)

**Files:**
- Create: `lib/features/admin/create_event/logic/coordinates.dart`
- Modify: `lib/features/admin/create_event/create_event_landing/controller/create_event_controller.dart`, `.../screen/create_event_screen.dart`
- Test: `test/features/admin/create_event/coordinates_test.dart`, `test/features/admin/create_event/create_event_controller_test.dart`

**Interfaces:**
- Produces:
  - `({double lat, double lng})? parseCoordinates(String text)`. It accepts what Google Maps copies: `'45.7971, 24.1520'`, `'45.7971,24.1520'` and `'45.7971 24.1520'`. It returns null for an empty string, one number, or a value out of range (|lat| > 90, |lng| > 180).
  - `String formatCoordinates(double lat, double lng)` gives `'45.7971, 24.1520'`, with 4 decimals.
  - New controller text fields, loaded from an event and written by `_fill`:
    - `areaController`, `finishPointController`
    - `routeKmController` (accepts a comma)
    - `durationController` (minutes)
    - `teamSizeMinController`, `teamSizeMaxController`, `maxTeamsController`
    - `startPinController`, `meetingNoteController`, `arriveBeforeController`
    - `whatToBringController` (one item per line)
    - `storyController`, `organiserController`
  - `Difficulty? difficulty`
  - Empty number fields give null, or the default for team sizes and arrive-before.

Form changes in `create_event_screen.dart`, keeping the existing `AppTextField` / `AppDropdown` style:
- After "Locație": "Zonă" (`area`).
- After "Punct de start": "Punct de final", then "Coordonate start". The helper text for the coordinates says "Copiază din Google Maps, ex. 45.7971, 24.1520"; when the field is filled but doesn't parse, its validator says "Coordonate greșite".
- After that: "Unde vă strângeți" (meeting note) and "Veniți cu câte minute înainte".
- After "Descriere": "Povestea" (multiline).
- The "Lungime traseu" / "Durata" / "Dificultate" text fields become:
  - "Lungime traseu (km)", decimal
  - "Durata (minute)", number
  - "Dificultate", an `AppDropdown<Difficulty>` with the `difficultyLabel`s
  - Loading an old event fills them from the `effective*` getters.
- New: "Membri pe echipă", with two number fields (min and max) side by side, then "Număr maxim de echipe" (empty = no limit), "Ce să aducă" (multiline, one per line) and "Organizator" (default empty = TeamXperience).
- The old string fields are still written, so cards and screens that read them keep working:
  - `lungimeTraseu = formatKm(...)`
  - `durata = formatDuration(...)`
  - `dificultate = difficultyLabel(...)`

  The formatters come from `lib/utils/event_formats.dart` (Task 3).

- [ ] **Step 1: Write the failing tests.**
  - `parseCoordinates`: every input listed above.
  - Controller: an event with every new field loads into the controllers, `buildNewEvent()` gives the same values back, an old event (text-only fields) loads `routeKmController.text == '4,5'` and `difficulty == Difficulty.medium`, and `'4,5'` in the km field saves 4.5.
- [ ] **Step 2: Run** the tests. Expected: FAIL.
- [ ] **Step 3: Implement.** Add the fields, the dropdown and the validator.
- [ ] **Step 4: Run** `flutter test test/features/admin test/features/event_details`. Expected: PASS.
- [ ] **Step 5: Commit** with the message "Event form: fields for the new event page".

### Task 9: Mission editor fields (organisers)

**Files:**
- Create: `lib/features/admin/create_event/create_missions_and_puzzles/widgets/mission_list/mission_text_fields.dart`
- Modify: `.../controller/add_missions_controller.dart`, `.../screen/mission_page.dart`, `.../widgets/mission_list/mission_card.dart`
- Test: `test/features/admin/create_event/add_missions_controller_test.dart`, `test/features/admin/create_event/mission_text_fields_test.dart`

**Interfaces:**
- Produces:
  - `void AddMissionsController.setMissionText(int index, {String? title, String? teaser, bool? isTeaserPublic})`, which trims, stores blank as null and saves like the other edits.
  - `MissionTextFields({required Mission mission, required void Function({String? title, String? teaser, bool? isTeaserPublic}) onChanged})`. It holds a title field ("Titlul misiunii"), a teaser field ("O frază pentru pagina evenimentului") and a switch ("Arată pe pagina evenimentului").
  - `MissionCard` shows `'{n} · {title}'` when there is a title, and the current label otherwise.

- [ ] **Step 1: Write the failing tests.**
  - `setMissionText(0, title: '  Scara Pasajului ')` stores `'Scara Pasajului'`, and `title: ''` stores null.
  - Typing in `MissionTextFields` calls `onChanged` with the text.
  - Toggling the switch calls it with `isTeaserPublic: true`.
- [ ] **Step 2: Run** the tests. Expected: FAIL.
- [ ] **Step 3: Implement.** Put `MissionTextFields` at the top of `MissionPage`, above the puzzle rows.
- [ ] **Step 4: Run** `flutter test test/features/admin`. Expected: PASS.
- [ ] **Step 5: Commit** with the message "Mission editor: title, teaser and show-on-page switch".

### Task 10: Completeness, JSON import and docs

**Files:**
- Modify: `lib/service/event_service/event_completeness.dart`, `lib/service/event_service/event_json_import.dart`, `docs/skills/event-json/SKILL.md`, `docs/event-import-sample.json`, `docs/event-examples/*.json` (add the new fields to the old-school example "Moștenirea Cartografului" so it matches the mockup), `docs/data-model.md`
- Test: `test/service/event_service/event_completeness_test.dart`, `test/service/event_service/event_json_import_test.dart` (or the existing file names in that folder)

**Interfaces:**
- Produces:
  - `EventIssue.noRoute`, `noDuration` and `noDifficulty` check the `effective*` getters.
  - New `EventIssue.noStartPin('Lipsește locul de start pe hartă')` and `EventIssue.noFinishPoint('Lipsește punctul de final')`.
  - `missionProblems` starts with `MissionProblem('Nu are titlu')` (no `puzzleIndex`) when the title is blank, before the puzzle problems. A mission with no puzzles lists both problems.
  - The importer reads every new event field:
    - `difficulty` as an option of `Difficulty`
    - numbers as `decimal` / `whole`, with team size 1–20, max teams 1–500 and arrive-before 0–120
    - `whatToBring` as a list of texts
  - The importer reads `title`, `teaser` and `isTeaserPublic` on missions.

- [ ] **Step 1: Write the failing tests.**
  - An event with no start pin lists `noStartPin`.
  - An old event with `lungimeTraseu: '4 km'` doesn't list `noRoute`.
  - A mission without a title lists `noTitle`.
  - Importing JSON with every new field gives an event with those values, and `"difficulty": "medie"` gives an error naming the field.
  - `docs/event-examples/*.json` all import without errors (an existing test may already do this; extend it).
- [ ] **Step 2: Run** the tests. Expected: FAIL.
- [ ] **Step 3: Implement.** Update the skill doc's field table and example, and the sample JSON.
- [ ] **Step 4: Run** `flutter test`. Expected: all pass. Fix any test that counted `EventIssue.values`.
- [ ] **Step 5: Commit** with the message "Completeness and JSON import know the new event and mission fields".

### Task 11: Gallery page, review and merge

**Files:**
- Create: `lib/dev/sample_event.dart` (`Event sampleEvent()`, the mockup's event as data), `lib/dev/event_page_preview.dart`
- Modify: `lib/dev/component_gallery.dart` (a button "Pagina evenimentului" at the top opens the preview), `test/dev/component_gallery_test.dart`

**Interfaces:**
- Consumes: Task 6's `EventPageView`.
- Produces: `EventPagePreview`, which shows `EventPageView(event: sampleEvent(), data: EventPageData(teamsCount: 12, organiserEventsCount: 14, isAdmin: false), now: DateTime(2026, 11, 9, 12))`, with a segmented switch for the bar states (open / registered / enter window). Callbacks show a `SnackBar` with the action name.

- [ ] **Step 1: Write a failing test.** The preview renders in light and dark with no exception, and finds `'Moștenirea Cartografului'` and `'Mai sunt 3 zile'` (the 9th to the 12th).
- [ ] **Step 2: Run** it. Expected: FAIL.
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run** `flutter analyze` and `flutter test`. Expected: no new issues, all pass.
- [ ] **Step 5: Commit** with the message "Gallery: the event page with the mockup's sample event".
- [ ] **Step 6: Review the whole branch** with a fresh reviewer on the most capable model (executing-plans' Final Review). Fix Critical and Important findings test-first.
- [ ] **Step 7: Merge** with `git checkout redesign/mockups && git merge --no-ff redesign/step-2-event-page`. Run `flutter test`. Do not push.
