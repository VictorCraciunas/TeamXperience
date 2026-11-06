# Redesign step 6b: the event's look from its puzzles, the route trail and the puzzle frame — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Mockup 06 for every event in that event's own look. The mission route becomes a winding trail (done stops, the current mission's card with its distance, the locked rest, the flag), with the team's place and two clocks. Each puzzle gets a frame: a header with the mission and timer, progress bars, attempts left, the organiser's wrong-answer line, and the hint and chat buttons. The organiser's puzzle content stays exactly as built.

**Architecture:** The organiser sets nothing new for the look. Each event's `EventPalette` is computed from what its puzzles already use, in this order:
1. The most common values across the event's components (button, text and code-field colours, glow, fonts).
2. Otherwise, the event's existing component defaults (`Event.defaults`: background, text, accent, font), which new components start from.
3. Otherwise, the app's colours.

A contrast guard keeps text readable. Every game screen reads `context.eventPalette`: the intro (replacing 6a's `EventLook`), the route trail and the puzzle frame. The route screen shows the same background image as the puzzles. New rule fields (mission position, attempt limit, wrong-answer text, all optional with defaults) and team counters (attempts, hints used) drive the frame's logic. View widgets take plain values.

**Tech Stack:** Flutter (Dart 3.7), provider, cloud_firestore, geolocator (already used), flutter_tabler_icons.

**Spec:** `docs/roadmap/mockups-roadmap.md` (step 6b = L6.1, L6.2, U3.7; L1.2/L1.3 for the mission and puzzle fields; L1.4 for `attempts`, `hintsUsed`) and the mockup `docs/roadmap/mockups/06-game-route-and-code-puzzle.html` for layout and sizes. **Victor's decisions (2026-11-06):** each event looks the way its organiser built its puzzles (editor and JSON); the game frame takes its colours and fonts from the event's own puzzles; **the organiser does nothing extra for the look** (no style section, no overrides, no presets); the organiser's own code field and button stay and still check the answer.

## Global Constraints

- Branch `redesign/step-6b-route-and-frame` from `redesign/mockups`; merge back with `--no-ff`; never push.
- **Layout and sizes come from mockup 06; colours and fonts come from the event's palette, never fixed.**
  - 1 CSS px = 1 logical px; line height 1.45 unless the mockup sets one.
  - No box-sizing reset: a CSS width/height is the content box, so borders and padding add to it (unless `box-sizing:border-box`).
  - Mockup colour → palette field: `#EADBC0` → `background`, `#FBF4E4` → `surface`, `#3B2A1A` → `ink`, `#8A3B12` → `accent`, `#B8862B` → `secondaryAccent`, `#A3262A`/`#D13438` → `danger`, text on accent → `onAccent`. Opacities apply to the palette colour (`palette.ink.withValues(alpha: .1)`).
- The organiser's puzzle content (components, background image, entrance animations, their code field and button) is not restyled.
- Colours only from `context.colors` / `context.eventPalette`; `test/ui/no_hardcoded_colors_test.dart` keeps passing with no allow-list additions. No `x!` in new code; one widget per file; one controller per screen; `lib/ui` never imports `lib/features`.
- New Firestore fields are optional with defaults, so an organiser who leaves them alone gets a working game; the JSON import reads every new event, mission and puzzle field; `docs/data-model.md`, `docs/features.md`, `docs/screens.md`, `docs/ui-and-theme.md` follow in the task that changes them.
- Copy:
  - Route screen: "{team} · locul {p} din {n}", "{H:MM:SS} jucat", "{H:MM:SS} rămas", "{n} · {title}", "Misiunea {n} · acum", "la {d} de tine" (d = "180 m" or "1,2 km"), "Continuă".
  - Puzzle frame: "Misiunea {n} din {m}", "{n} încercări rămase" ("1 încercare rămasă"), "Indiciu".
  - Default wrong-answer line: "Nu e corect. Mai încearcă."

## Rulings made while planning (report them to Victor)

1. **6a's `EventLook` (app/parchment) is removed.** Nothing but the sample event ever set `look`; the stored `look` field is no longer read. The sample event gets its parchment look from its own puzzle components, like any real event.
2. **What is taken from the puzzles,** each the most common value across the event's components (ties: first seen; blank or unreadable hexes ignored), falling back to `Event.defaults`, then the app:
   - accent ← button background (`buttonColor`), else the code field's border (`colorBorderInput`), else `defaults.accentColor`;
   - ink ← the text pieces' `textColor`, else `defaults.textColor`;
   - title font (`voiceFont`) ← the text pieces' `fontFamily`, else `defaults.fontFamily`; the body font stays the app's;
   - surface ← the code field's `inputBackgroundColor`, else `frameBackgroundColor`, else the app panel colour;
   - background ← `defaults.backgroundColor`, else the most common `frameBackgroundColor`, else the app page colour;
   - second accent ← the most common `glowColor`, else the accent at 55 %;
   - danger ← the app's danger colour;
   - `muted`, `faint` and `border` are made from `ink` at 75 %, 55 % and 25 %.
3. **Background image.** The route screen draws the same image the puzzles use (`taskBackgroundImageUrl`, else today's `default_background.png`) under a veil of the `background` colour at 85 %, so text always sits on a known colour.
4. **Contrast guard.** If `ink` on `background` (or on `surface`) is below 4.5:1, ink becomes near-black (`#1A1410`) or near-white (`#F7F2E8`), whichever reads better. `onAccent` (text on accent fills) is chosen the same way. If `accent` on `surface` is below 3:1, accent falls back to the app accent.
5. **The start-code screen stays in the app's navy.** It comes before the event's takeover, as in mockup 05. The intro letter, route trail and puzzle frame use the event's palette.
6. **The puzzle frame has no "Verifică" bar.** The organiser's own button checks, as Victor chose. The bottom bar is "Indiciu" plus a chat button, replacing the old "Ai nevoie de ajutor ?" pill (roadmap U3.7).
7. **Attempts and hints are team-wide.**
   - Both are counted on the team doc with Firestore increments, keyed by `"{mission}_{puzzle}"`, so teammates' phones share them.
   - A puzzle without `maxAttempts` has unlimited attempts and shows no dots (the default, so organisers need not touch it).
   - When a puzzle with `maxAttempts` runs out: the hint opens by itself (if it has one) and checks pause for 60 s, after which the count starts over (roadmap L6.2 "my call").
   - Hints follow the event's `hintsPerMission` (default 1) per mission.
   - The organiser's live-room alert is step 8.
8. **"la 180 m de tine"** measures from the team's last position on its team doc (written by `LocationService` on every fix), so the route screen needs no extra GPS work. A mission's point is:
   - its new optional `latitude`/`longitude`;
   - else its first geolocation puzzle's point;
   - else no distance line.
9. **The live place streams every team only while the route screen is on top.** It pauses while a puzzle is open (the same rule as Home in step 5). There is no place line until the first data arrives.
10. **Trail layout:**
    - Stops bottom to top: the done missions, the current mission's card, one locked group ("5 · 6"; "5–8" for more than three), then the flag.
    - Stops alternate left and right on a smooth curve, 100 px apart, and the trail scrolls when it is taller than the screen.
    - The line is solid up to the current stop and dashed after it.
    - When every mission is done: all ticked stops, the flag, and no card.
11. **Editor and JSON get only content and rules, all optional.** No look settings. The event form gets a small "Începutul jocului" section with the 6a fields (intro letter, signature, hints per mission, minutes to enter the code), which today exist only in the model. Mission pages get two optional coordinates. The puzzle "Reguli" tab gets "Număr maxim de încercări" (empty = nelimitat) and "Mesaj la răspuns greșit" (empty = the default line).

## Review Focus

1. **An event whose puzzles set no colours at all, and an event with clashing colours** (black text on a black background): readable app-coloured screens in the first case, readable guarded text in the second. (Task 2 tests.)
2. **Two phones of the same team answering wrong at the same time:** both wrong answers count once each (increments, not overwrites), and the lock applies on both. (Task 5 tests on the logic; the Firestore increment is in the repo.)
3. **A mission with no position, a team with no position yet (0, 0), and a player who denied location:** no distance line, no "la 0 m". (Task 4 test.)
4. **One mission, all missions done, and twelve missions:** the trail draws without overlap, scrolls for twelve, and shows no card when all are done. (Task 6 tests.)
5. **The 60 s lock across closing and reopening the puzzle:** the lock survives because it is computed from the team's stored lock time, not a local timer. (Task 5 test.)

---

### Task 1: Rule and counter fields; editor and JSON

**Files:**
- Modify:
  - Models: `lib/model/event.dart` (remove `look`), `lib/model/mission.dart` (`latitude`, `longitude`), `lib/model/puzzle.dart` (`maxAttempts`, `wrongAnswerMessage`), `lib/model/team.dart` (`attempts: Map<String,int>`, `hintsUsed: Map<String,bool>`, `lockedUntil: Map<String,DateTime>`).
  - Import: `lib/service/event_service/event_json_import.dart`: the 6a fields, the new mission and puzzle fields.
  - Editor: the event form `create_event_screen.dart` + `create_event_controller.dart` (new section "Începutul jocului", from a new widget `lib/features/admin/create_event/create_event_landing/widgets/game_start_section.dart`), `mission_text_fields.dart` (coordinates), `puzzle_rules_form.dart` + `puzzle_rules_controller.dart` (two rule fields).
  - Remove: `lib/enums/event_look.dart` and its uses; 6a's `paletteFor` goes in Task 2 (until then the intro uses `EventPalette.fromApp`).
  - Docs: `docs/data-model.md`.
- Test: `test/model/mission_puzzle_rules_test.dart`, `test/model/team_counters_test.dart`, `test/service/event_json_import_test.dart` (add cases), `test/features/admin/game_start_section_test.dart`

**Interfaces:**
- Produces:
  - `Mission.latitude`, `Mission.longitude` (double?).
  - `Puzzle.maxAttempts` (int?, null = unlimited, at least 1 when set); `Puzzle.wrongAnswerMessage` (String?).
  - Team counters, read like step 5's times (anything unreadable is skipped) and never written by `toJson`:
    - `Team.attempts` (`Map<String,int>`)
    - `Team.hintsUsed` (`Map<String,bool>`)
    - `Team.lockedUntil` (`Map<String,DateTime>`)
    - `static String puzzleKey(int mission, int puzzle)` → `"$mission_$puzzle"`
  - `TeamService`:
    - `addWrongAttempt(eventId, teamName, key)`: `FieldValue.increment(1)`;
    - `lockPuzzle(eventId, teamName, key, DateTime until)`: also resets `attempts.{key}` to 0;
    - `markHintUsed(eventId, teamName, key)`.
  - JSON: every new field, with ranges `maxAttempts` 1–20, `hintsPerMission` 0–5, `enterWindowMinutes` 10–180.
  - `GameStartSection({introLetter, introSignature, hintsPerMission, enterWindowMinutes, callbacks})`.

- [ ] **Step 1: Write the failing tests:**
  - Missions and puzzles round-trip their new fields; `maxAttempts: 0` reads as null.
  - An event map with an old `look: 'parchment'` still reads, and `toJson` has no `look`.
  - Team counters read from a map with a pending (null) value and a bad value, and are left out of `toJson`.
  - The JSON import:
    - reads `introLetter`, `introSignature`, `hintsPerMission`, `enterWindowMinutes`, a mission's coordinates, and a puzzle's `maxAttempts` and `wrongAnswerMessage`;
    - reports `maxAttempts: 50` and `hintsPerMission: 9` as errors with their paths, in the existing error style.
  - `GameStartSection`: the four fields call back; empty stays empty (defaults apply).
- [ ] **Step 2: Run; expect failures.** `flutter test test/model test/service/event_json_import_test.dart test/features/admin`
- [ ] **Step 3: Implement**; wire the editor fields to the controllers and saved events; remove `EventLook`.
- [ ] **Step 4: Run the same; expect PASS; then `flutter test`; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "Mission position, attempt rules, intro fields and team counters; editor and JSON"`

---

### Task 2: The event's palette from its puzzles

**Files:**
- Create: `lib/ui/theme/event_palette_resolver.dart` (pure, no features import; it takes the plain values it needs)
- Modify: `lib/ui/theme/event_palette.dart`:
  - new fields `onAccent` and `backgroundImage` (`ImageProvider?`), both in `==` / `hashCode`;
  - the `parchment` constant and `paletteFor` are removed.
- Modify: `lib/features/game_intro/screen/game_intro_screen.dart` and `lib/dev/game_intro_preview.dart` use `eventPaletteOf`.
- Modify: `docs/ui-and-theme.md`.
- Test: `test/ui/theme/event_palette_resolver_test.dart`, `test/features/event_game/style_hints_test.dart`

**Interfaces:**
- `class StyleHints { final String? accent, ink, font, surface, background, glow; }` lives in `event_palette_resolver.dart`: the event's look already chosen from components then defaults (ruling 2).
- `StyleHints styleHintsFrom(Iterable<Component> components, EventDefaults? defaults)` lives in `lib/features/event_game/logic/style_hints.dart`, because `lib/ui` cannot see `Component`. Ties take the first seen; blank and unparseable hexes are ignored.
- `EventPalette resolveEventPalette({required StyleHints hints, required AppColors app, ImageProvider? backgroundImage})` implements hint → app and the contrast guard (ruling 4).
- `double contrastRatio(Color a, Color b)` is new, beside the resolver: the WCAG ratio from `computeLuminance`. The project has none yet.
- `EventPalette eventPaletteOf(Event event, AppColors app)`, also in `features/event_game/logic/style_hints.dart`: the one call screens use; it walks every mission's puzzles' components and sets the background image (ruling 3).

- [ ] **Step 1: Write the failing tests:**
  - No components and no defaults → `EventPalette.fromApp` values.
  - The most common button colour becomes `accent`; with no button, the code-field border; with neither, `defaults.accentColor`.
  - Text colour and font become `ink` and `voiceFont`; blank hexes are ignored.
  - `#000000` text on a `#000000` frame background → ink becomes the near-white guard.
  - `onAccent` is dark on a light accent and light on a dark one.
  - An accent too close to the surface falls back to the app accent.
  - The sample event's parchment components give exactly the mockup colours.
- [ ] **Step 2: Run; expect failures.** `flutter test test/ui/theme test/features/event_game`
- [ ] **Step 3: Implement**; switch the intro screen and its preview to `eventPaletteOf`.
- [ ] **Step 4: Run; expect PASS; then `flutter test`; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "Each event's palette from its puzzles, its defaults, or the app"`

---

### Task 3: Shared frame pieces in the event's palette

**Files:**
- Create in `lib/ui/components/game/`:
  - `round_icon_button.dart`: the mockup's `.rb`, a 32 px circle in ink 10 % with a 16 px icon.
  - `mission_segments.dart`: `.seg`, gap 3, 5 px bars, radius 99; done = `accent`, current = `secondaryAccent`, rest = ink 18 %.
  - `attempt_dots.dart`: 8 px dots, the used ones filled `accent`, the left ones a 1.5 px `accent` ring (border-box, so 8 across), gap 5, then the label 4 px after, 11 px at 80 %.
  - `game_outline_button.dart`: the outlined "Indiciu", a 1.5 px `accent` border, radius 12, padding 10, w500 `accent`, with a 15 px icon.
  - `game_icon_button.dart`: the 42 px chat button.
- Test: `test/ui/components/game_pieces_test.dart`

**Interfaces** (all read `context.eventPalette`):
- `RoundIconButton({required IconData icon, required VoidCallback onTap, String? label})`
- `MissionSegments({required int total, required int done})`, where `done` < total means the next segment is current.
- `AttemptDots({required int max, required int left})`, with label "{left} încercări rămase" / "1 încercare rămasă".
- `GameOutlineButton({required String label, IconData? icon, VoidCallback? onTap})`, greyed (50 %) when `onTap` is null.
- `GameIconButton({required IconData icon, required VoidCallback onTap})`

- [ ] **Step 1: Write the failing tests:**
  - The sizes above.
  - `MissionSegments(total: 6, done: 3)`: three `accent`, one `secondaryAccent`, two faint.
  - `AttemptDots(max: 3, left: 2)` shows one filled dot, two rings and "2 încercări rămase"; `left: 1` shows "1 încercare rămasă".
  - Colours follow a non-parchment palette (for example a black and green one).
  - 320 px at 1.3×, no overflow.
- [ ] **Step 2: Run; expect failures.**
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "Game frame pieces in the event's palette"`

---

### Task 4: Route logic

**Files:**
- Create: `lib/features/event_game/logic/route_texts.dart`, `lib/features/event_game/logic/trail_layout.dart`
- Test: `test/features/event_game/route_texts_test.dart`, `test/features/event_game/trail_layout_test.dart`

**Interfaces:**
- `String placeLine(String team, int place, int teams)` → "Vulpile · locul 2 din 12".
- `String playedClock(DateTime? startedAt, DateTime? eventStart, DateTime now)`: from `startedAt`, else the event start; "0:42:18"; never negative. Uses `liveClock` from `features/home/logic/live_texts.dart`.
- `String leftClock(Event event, DateTime now)`: start + `Event.maxDuration` − now.
- `({double lat, double lng})? missionPoint(Mission mission)`: ruling 7.
- `String? distanceLine(({double lat, double lng})? from, ({double lat, double lng})? to)`:
  - "la 180 m de tine"; from 1 000 m, "la 1,2 km de tine" (one decimal, comma);
  - null when either point is missing or `from` is (0, 0);
  - uses `Geolocator.distanceBetween`.
- `String lockedLabel(List<int> numbers)` → "5 · 6", "5 · 6 · 7", "5–8".
- `sealed class TrailStop`, with `DoneStop(int number, String title)`, `CurrentStop(int number, String title, String? distance)`, `LockedStop(String label)` and `FinishStop()`.
- `List<TrailStop> trailStops(Event event, int missionProgress, String? distance)`.
- `List<Offset> trailPoints(int count, {required double width, double spacing = 100})`: bottom to top, x alternating 0.2/0.68 × width (the first at 0.2), y = (count − 1 − i) × spacing + 40.
- `Path trailPath(List<Offset> points)`: a smooth cubic through the points.

- [ ] **Step 1: Write the failing tests:**
  - `placeLine`.
  - `playedClock`: from `startedAt`; from the event start when `startedAt` is null; zero before the start.
  - `distanceLine`: 180 m, 1 234 m → "1,2 km", null at (0, 0) and with no point.
  - `missionPoint`: falls back to the first geolocation puzzle.
  - `lockedLabel` for 2, 3 and 4 numbers.
  - `trailStops`:
    - 6 missions with progress 3 → Done 1–3, Current 4, Locked "5 · 6", Finish;
    - progress 6 → six Done and Finish;
    - one mission at progress 0 → Current 1 and Finish.
  - `trailPoints(5, width: 304)`: the first point at the bottom-left, and alternating x.
- [ ] **Step 2: Run; expect failures.**
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "Route logic: place, clocks, distance, trail stops and layout"`

---

### Task 5: Attempts and hints logic

**Files:**
- Create: `lib/features/event_game/logic/puzzle_rules.dart`
- Modify: `lib/features/event_game/controller/puzzle_game_controller.dart` (count wrong answers, lock, hints), `lib/backend/repo/teamRepo.dart` + `team_service.dart` (Task 1's three writes)
- Test: `test/features/event_game/puzzle_rules_test.dart`

**Interfaces:**
- `int? attemptsLeft(Puzzle puzzle, Team team, String key)`: null when unlimited.
- `Duration? lockLeft(Team team, String key, DateTime now)`: null when not locked.
- `bool hintAvailable(Event event, Puzzle puzzle, Team team, int mission)`: the puzzle has an `indiciu`, and the hints used in this mission (keys starting `"$mission_"`) are below `event.hintsPerMission`, or this puzzle's hint was already used (re-opening is free).
- `String wrongLine(Puzzle puzzle)`: `wrongAnswerMessage`, or "Nu e corect. Mai încearcă.".
- `const Duration puzzleLock = Duration(seconds: 60)`.
- `PuzzleGameController` gains:
  - `ValueNotifier<String?> wrongMessage` (set on a wrong answer, cleared on the next input);
  - `void Function()? onOutOfAttempts`, which the screen uses to open the hint;
  - `Future<void> useHint()`.
  - A wrong answer calls `addWrongAttempt`. When the count reaches `maxAttempts`, it calls `lockPuzzle(now + puzzleLock)` and `onOutOfAttempts`.
  - While `lockLeft` is not null, a check is refused without counting.

- [ ] **Step 1: Write the failing tests:**
  - `attemptsLeft` with max 3 and 1 used → 2; unlimited → null.
  - `lockLeft` 45 s before the lock ends; null after it.
  - `hintAvailable`:
    - false without an `indiciu`;
    - false when the mission's single hint is used on another puzzle;
    - true for re-opening this puzzle's own hint;
    - `hintsPerMission: 0` → false.
  - `wrongLine` default and custom.
- [ ] **Step 2: Run; expect failures.**
- [ ] **Step 3: Implement**; wire the controller: the team is followed through `TeamService.getStreamTeam` while the puzzle is open, so counts and locks from teammates' phones show.
- [ ] **Step 4: Run; expect PASS; then `flutter test`; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "Puzzle attempts, the 60 s lock and hints per mission"`

---

### Task 6: The trail view

**Files:**
- Create in `lib/features/event_game/widgets/`:
  - `route_trail_view.dart`: a `CustomPaint` path plus positioned stops, scrollable, starting at the bottom.
  - `trail_done_stop.dart`: 32 px `accent` circle with a 16 px check in `background`, the label 11 px, 8 apart; on the right-hand side the label goes to the left.
  - `trail_current_card.dart`: 140 content + 2 × 10 padding + 2 × 2 border = 164 wide; `surface` fill, 2 px `secondaryAccent` border, radius 14. Inside: "Misiunea 4 · acum" 11 w500 `accent`; the title in `voiceFont` 14; the distance 11 at 75 %; then, 6 px below, "Continuă" (`accent` fill, `onAccent` w500, radius 10, padding 6).
  - `trail_locked_stop.dart`: at 60 %, a 28 px dashed `ink` ring (border-box) with a 13 px lock, the label 11, a 16 px flag, gaps 6.
- Test: `test/features/event_game/route_trail_view_test.dart`

**Interfaces:**
- `RouteTrailView({required List<TrailStop> stops, required VoidCallback onContinue})`, reading `context.eventPalette`.
- The line is 3 px `accent`: solid up to the current stop, then dashed 7/6 at 75 %.

- [ ] **Step 1: Write the failing tests:**
  - The mockup's stops render with their labels.
  - "Continuă" calls back.
  - The card is 164 wide with a 2 px `secondaryAccent` border.
  - All done: no card, the flag shown.
  - Twelve missions scroll (the first stop is visible at the bottom on open).
  - One mission: no overflow.
  - The palette's colours are used (a black and green palette shows green stops).
- [ ] **Step 2: Run; expect failures.**
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "Route trail in the event's palette"`

---

### Task 7: The route screen

**Files:**
- Modify: `lib/features/event_game/screen/event_game_screen.dart` (rebuilt), `lib/features/event_game/controller/event_game_controller.dart` (the team stream for position and progress; the teams stream for the place, paused when not on top; ruling 8)
- Create: `lib/features/event_game/widgets/route_header.dart`
- Test: `test/features/event_game/route_header_test.dart`

**Interfaces:**
- `RouteHeader({required String eventName, required String? placeLine, required String played, required String left, required VoidCallback onClose, required VoidCallback onChat})`:
  - **Top row** (padding 12/14/8, gap 8): the close `RoundIconButton`, a centred column (the name in `voiceFont` 15, the place line 11 at 75 %), and the chat `RoundIconButton`.
  - **Clocks row** (centred, gap 16, 11 px, 6 px below): `clock` and `hourglass` icons 13 px, values in Monospace w500, then "jucat" and "rămas".
- The screen:
  - wraps everything in `EventThemeScope(eventPaletteOf(...))`, with the `background` colour and the optional background image behind;
  - shows the header, then `RouteTrailView` filling the rest;
  - "Continuă" opens the current mission's puzzle with today's arguments;
  - keeps today's event-ended dialog;
  - drops the "Ai nevoie de ajutor ?" pill (the chat lives in the header).

- [ ] **Step 1: Write the failing tests** for `RouteHeader`:
  - The mockup's texts and the two clocks.
  - No place line before data.
  - Close and chat call back.
  - It follows a non-parchment palette.
  - 320 px at 1.3×, no overflow.
- [ ] **Step 2: Run; expect failures.**
- [ ] **Step 3: Implement**; rebuild the screen.
- [ ] **Step 4: Run `flutter test`; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "Route screen as mockup 06: header, clocks, place, trail"`

---

### Task 8: The puzzle frame

**Files:**
- Create in `lib/features/event_game/widgets/`:
  - `puzzle_header.dart`: `RoundIconButton` back; a column with "Misiunea {n} din {m}" (11 at 75 %) and the title (`voiceFont` 15); then the played clock in Monospace w500.
  - `puzzle_feedback.dart`: the wrong line, centred, `danger` w500 12 with an `alert_circle` 14, 8 below the content; then `AttemptDots`, 8 below.
  - `puzzle_bottom_bar.dart`: padding 12/14/14, gap 8; `GameOutlineButton` "Indiciu" (flex) and a chat `GameIconButton`.
  - `hint_sheet.dart`: the hint text in a sheet in the event's palette.
- Modify: `lib/features/event_game/screen/puzzle_game_screen.dart`:
  - The frame goes around the existing content for every puzzle type: header, `MissionSegments` (12 px below the header), the content (still scrolling, still animated), the feedback, and the bottom bar.
  - The organiser's background image stays behind the content.
- Test: `test/features/event_game/puzzle_frame_test.dart`

**Interfaces:**
- Consumes Tasks 3–5.
- `PuzzleHeader({required int mission, required int missions, required String title, required String clock, required VoidCallback onBack})`
- `PuzzleFeedback({String? wrong, int? maxAttempts, int? attemptsLeft, Duration? lockLeft})`: during a lock the line reads "Mai încercați în 0:45" in `muted`.
- `PuzzleBottomBar({VoidCallback? onHint, required VoidCallback onChat})`: "Indiciu" is greyed when `onHint` is null.

- [ ] **Step 1: Write the failing tests:**
  - Header texts "Misiunea 4 din 6", "Casa cu ochi" and the clock.
  - Feedback:
    - the custom wrong line;
    - "2 încercări rămase";
    - no dots when `maxAttempts` is null;
    - the lock line "Mai încercați în 0:45".
  - Bottom bar: "Indiciu" calls back; greyed when null; chat calls back.
  - It follows a non-parchment palette.
  - 320 px at 1.3×, no overflow.
- [ ] **Step 2: Run; expect failures.**
- [ ] **Step 3: Implement**; wire the screen to the controller (`wrongMessage`, the team's counts and lock, `useHint`, `onOutOfAttempts` → `HintSheet`).
- [ ] **Step 4: Run `flutter test`; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "Puzzle frame: header, progress, wrong line, attempts, hint and chat"`

---

### Task 9: Gallery previews and docs

**Files:**
- Create: `lib/dev/route_preview.dart` (the route trail with the mockup's stops) and `lib/dev/puzzle_frame_preview.dart` (the frame around a sample code puzzle). Each switches between the parchment sample event and a black and green "neon" sample event (only their components differ), so the gallery shows the frame dressing itself from the puzzles.
- Modify:
  - `lib/dev/sample_event.dart`: components in the mockup's parchment colours (button `#8A3B12`, text `#3B2A1A` in Gelasio, code field `#FBF4E4`, glow `#B8862B`, defaults background `#EADBC0`) and a `neonSampleEvent()` with black and green components; mission titles "Scara Pasajului", "Podul Minciunilor", "Turnul Sfatului", "Casa cu ochi", …; a code puzzle with `maxAttempts: 3`, `wrongAnswerMessage: 'Nu e anul ăsta. Uită-te mai sus pe ușă.'` and a hint.
  - `lib/dev/shell_previews_launcher.dart` ("Traseu", "Puzzle").
  - Docs: `docs/screens.md`, `docs/features.md`, `docs/ui-and-theme.md`, `docs/data-model.md`, and a note in `docs/features.md` (import section) that the game takes its look from the components.
- Test: `test/dev/shell_previews_test.dart` (both previews, both sample events, light and dark, no exception).

- [ ] **Step 1: Write the failing test.**
- [ ] **Step 2: Run; expect failure.**
- [ ] **Step 3: Implement and update the docs.**
- [ ] **Step 4: Run `flutter test` and `flutter analyze`; expect PASS and no new issues.**
- [ ] **Step 5: Commit** — `git commit -m "Gallery: route trail and puzzle frame in two event styles; docs"`
