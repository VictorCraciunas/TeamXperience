# Redesign step 6a: start code and intro letter — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** The start-code screen and the intro letter look and work exactly like mockup 05. The start screen has the time left to enter, code boxes, a wrong-code message, who of the team is here and a chat link. The intro letter is in the event's look, shown once per device before the game.

**Architecture:** The event gains its intro fields, its enter window and a look (`app` or `parchment`); the team gains `startedAt`, set once by a transaction. A `StartCodeController` (ChangeNotifier, fakes in tests) loads and streams the player's team, keeps the code and the result, and starts the team. A `GameDoor` sends every player entry into the game through the intro letter the first time on a device. View widgets take plain values.

**Tech Stack:** Flutter (Dart 3.7), provider, cloud_firestore, shared_preferences, flutter_tabler_icons.

**Spec:** `docs/roadmap/mockups-roadmap.md` (step 6a = L5 + U3.6; L1.1 for `introLetter`, `introSignature`, `hintsPerMission`, `enterWindowMinutes`, `theme`) and the binding mockup `docs/roadmap/mockups/05-start-code-and-intro.html`.

## Global Constraints

- Branch `redesign/step-6a-start-code` from `redesign/mockups`; merge back with `--no-ff`; never push.
- The mockup binds: 1 CSS px = 1 logical px, line height 1.45 unless the mockup sets one. **The mockup has no box-sizing reset:** a CSS `width`/`height` is the content box, and borders and padding add to it (unless the element says `box-sizing:border-box`).
- Colours from `context.colors` / `context.eventPalette` only; opacities from the mockup applied to tokens (`colors.onNavy.withValues(alpha: .75)`). `test/ui/no_hardcoded_colors_test.dart` keeps passing with no allow-list additions.
- No `x!` in new code; one widget per file; one controller per screen; `lib/ui` never imports `lib/features`.
- New Firestore fields are optional with defaults; update `docs/data-model.md`, `docs/features.md` (routes) and `docs/screens.md` in the tasks that change them.
- Copy exactly as the mockup: "A început · {n} min să intri", "Introdu codul de start", "Îl primești de la organizator la {punctDeStart}.", "Codul nu e corect. Verifică literele.", "Nu contează literele mari sau mici.", "Echipa {team}", "{n} din {size} sunt aici", "Pornește jocul", "Nu ai codul? Scrie-i organizatorului", "{city}, {day} {month}", "— {signature}", "{n} misiuni", "{n} ore", "{n} indiciu / misiune", "Spre prima misiune", "Cronometrul pornește acum pentru toată echipa."
- Photo puzzles keep today's rule (Victor, 2026-11-05); 6a does not touch them.

## Rulings made while planning (report them to Victor)

1. **The event's look is a preset, not a full colour set:** `EventLook { app, parchment }` stored as `look`. `parchment` uses `EventPalette.parchment`; `app` (the default, so every existing event) uses the app colours. The roadmap's full `EventTheme` (custom colours, fonts, background image) waits for the authoring step (9). Cost if wrong: organisers can only pick between two looks for now.
2. **Organisers cannot set the new fields yet** (intro letter, signature, hints per mission, enter window, look). The authoring UI is step 9 (L9). Until then real events show the intro without a letter card, in the app's colours, with a 60-minute window and "1 indiciu / misiune".
3. **The intro shows once per device per team and event** (key `eventId|teamName`), not per `startedAt`: an event is played once, and `startedAt` is still pending on the device that just started the game. Cost if wrong: a team that plays the same event twice sees the letter only the first time.
4. **Every player way into the game goes through `GameDoor`.** That covers the start code, Home's and Joacă's "Continuă", and the event page. The first time on a device it opens the intro, and "Spre prima misiune" replaces the intro with the game; afterwards it opens the game directly. The organiser's "Vezi Eveniment" preview (`menu.dart`) is unchanged.
5. **Teammates who come later skip the code.** On the start screen, once the streamed team has started, the boxes go and the button says "Intră în joc" (no code needed). The mockup does not draw this state.
6. **Every refusal shows under the boxes, in the mockup's error style:**
   - Only a wrong code turns the boxes red ("Codul nu e corect. Verifică literele.").
   - Too early, window closed, no team and failed use today's messages (`EnterCodeController.messageFor`'s second line) in the same place. The snackbar goes.
7. **The pill after the window:** "Începe la 10:00" before the start, and "Intrarea s-a închis" after the window. The mockup only draws the open window.
8. **There is one box per character of the event's start code** (spaces ignored). An event without a start code shows 5 boxes, and any code is refused.
9. **New tokens:**
   - `dangerOnNavy` (#EF6A6E), the wrong-code box border on navy.
   - `dangerTextOnNavy` (#F7C1C1), the error line on navy.
   - Both have the same values in dark mode.
10. **Code boxes on navy have more states than the mockup draws:**
    - The mockup's measurements: 38 × 48 content box + 2 px border (42 × 52), radius 10, `onNavy` 8 % fill, Monospace 20 w500.
    - Only the error border is drawn; the rest is my call: `onNavy` 30 % when empty, `tickOnNavy` when filled or active.
11. **`startTeam` runs in a transaction:** it sets `hasStarted: true`, and `startedAt` = server time only when absent. It still runs without waiting, as today, so a weak signal does not hold the team at the door. Offline, the transaction fails and is logged, as today's write would be.

## Review Focus

1. **Fast taps on "Pornește jocul":** two quick taps start the team once and open one intro. (Task 4 test.)
2. **The team stream sends `hasStarted` while the player is typing:** the screen switches to "Intră în joc" and drops the typed code without throwing. (Task 4 test.)
3. **No signed-in user, or no team found when the screen opens:**
   - The team card and chat link hide.
   - Submitting a right code shows "Nu găsim echipa ta…" under the boxes.
   - (Task 4 test.)
4. **The window closes while the screen is open:** the pill turns to "Intrarea s-a închis" within 30 s, and a submit is refused as closed. (Task 2 and Task 4 tests.)
5. **An intro with no letter, no city or no duration:** no empty card, no empty date line, no "0 ore" chip; and at 320 px with 1.3× text nothing overflows, in both looks and both themes. (Task 6 test.)

---

### Task 1: Event and team fields, the enter window per event, the start transaction

**Files:**
- Create: `lib/enums/event_look.dart`
- Modify: `lib/model/event.dart`, `lib/model/team.dart`, `lib/backend/repo/teamRepo.dart` (`startTeam`), `lib/features/enter_code/logic/start_code_check.dart`, `lib/features/event_details/logic/enrolment_window.dart`, `lib/features/home/logic/home_hero.dart`, `lib/ui/theme/event_palette.dart` (or a new `lib/ui/theme/event_look_palette.dart`), `docs/data-model.md`
- Test: `test/model/event_intro_fields_test.dart`, `test/model/team_live_fields_test.dart` (add), `test/features/event_details/enrolment_window_test.dart` (new: `inEnterWindow` / `enterMinutesLeft` for a 30-minute event), and the existing `test/features/enter_code/start_code_check_test.dart` and `test/features/home/home_hero_test.dart` updated for the per-event window

**Interfaces:**
- Produces:
  - Event fields: `introLetter`, `introSignature` (String?); `hintsPerMission` (int, default 1); `enterWindowMinutes` (int, default 60); `look` (`EventLook`, default `EventLook.app`, stored by `.name`, an unknown name reads as `app`). All are in `toJson` and `fromMap`.
  - `Duration get enterWindow` replaces the static `Event.enterWindow`; every caller uses the event's own.
  - `Team.startedAt: DateTime?`, read like the step 5 times (pending or not a Timestamp → null) and never written by `toJson`.
  - `EventPalette paletteFor(EventLook look, AppColors colors)`, in `lib/ui/theme`: `parchment` → `EventPalette.parchment`, `app` → `EventPalette.fromApp`.
  - `TeamRepo.startTeam` runs as a transaction (Global ruling 11).

- [ ] **Step 1: Write the failing tests**:
  - The fields round-trip through `toJson`/`fromMap`.
  - Defaults when absent: 1, 60 and `app`.
  - `look: 'unknown'` reads as `app`.
  - `Event(enterWindowMinutes: 30).enterWindow == Duration(minutes: 30)`.
  - `checkStartCode` at start + 31 min returns `closed` for a 30-minute event and `ok` for a 60-minute one.
  - `resolveHomeHero` uses the event's window: `StartingSoonHero` minutes left = 30 − 10 at start + 10 for a 30-minute event.
  - `Team.startedAt` from a Timestamp, null when pending, absent from `toJson`.
  - `paletteFor` returns `parchment` and `fromApp` for the two looks.
- [ ] **Step 2: Run them; expect failures.** `flutter test test/model test/features/enter_code test/features/home test/features/event_details`
- [ ] **Step 3: Implement.**
  - Remove the static `Event.enterWindow` and `enterCodeWindow`; fix their callers (grep `Event.enterWindow`, `enterCodeWindow`).
  - `startTeam` uses `runTransaction`: read the doc, update `hasStarted: true` plus `startedAt: FieldValue.serverTimestamp()` when the doc has no `startedAt`.
  - Document the fields, `look`, `startedAt` and the transaction in `docs/data-model.md`.
- [ ] **Step 4: Run the same command; expect PASS. Then `flutter test`; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "Event intro fields, look and enter window; team startedAt set once"`

---

### Task 2: Start and intro texts

**Files:**
- Create: `lib/features/enter_code/logic/start_texts.dart`, `lib/features/game_intro/logic/intro_texts.dart`
- Modify: `lib/utils/event_formats.dart` (long month names), `lib/features/enter_code/controller/enter_code_controller.dart` (`messageFor` moves out, see below)
- Test: `test/features/enter_code/start_texts_test.dart`, `test/features/game_intro/intro_texts_test.dart`

**Interfaces:**
- Produces:
  - `String enterPill(Event event, DateTime now)`, built on the existing `inEnterWindow` / `enterMinutesLeft` (`features/event_details/logic/enrolment_window.dart`):
    - `"A început · 42 min să intri"` while the window is open;
    - `"Începe la 10:00"` before the start;
    - `"Intrarea s-a închis"` after the window or when stopped.
  - `String codeHint(Event event)` → `"Îl primești de la organizator la Piața Mare."`, or `"Îl primești de la organizator."` without `punctDeStart`.
  - `String? startError(StartCodeResult? result)`:
    - null for null and `ok`;
    - `wrong` → "Codul nu e corect. Verifică literele.";
    - `tooEarly` → "Jocul nu a început încă.";
    - `closed` → "Timpul pentru intrare s-a terminat.";
    - `noTeam` → "Nu găsim echipa ta la acest eveniment. Scrie-i organizatorului.";
    - `failed` → "Verifică internetul și încearcă din nou.";
    - the old `messageFor` and its test are removed.
  - `String hereLine(int here, int size)` → `"3 din 4 sunt aici"`; a size of 0 counts the members instead (passed in by the caller).
  - `int codeLength(Event event)` → the length of `normaliseCode(startCode)`, or 5 without a code.
  - `String introDateLine(Event event)`:
    - `"Sibiu, 14 noiembrie"` from `location` and `dateEvent`;
    - only `"14 noiembrie"` without a city;
    - `""` without a date.
  - `List<(IconData, String)> introFacts(Event event)`:
    - `(map_pin, "6 misiuni")`, or "1 misiune";
    - `(hourglass, "2 ore")` from `effectiveDurationMinutes` (60 → "1 oră", 90 → "1 h 30", 45 → "45 min"), left out when unknown;
    - `(bulb, "1 indiciu / misiune")`, "2 indicii / misiune", "Fără indicii" for 0;
    - the missions chip is left out when `nrMissions` is 0.
  - `String longMonth(int month)` in `event_formats.dart` ("noiembrie").

- [ ] **Step 1: Write the failing tests**, one per bullet, with the exact strings above. For `enterPill`, use a 60-minute event starting at 10:00, at 10:18 → "A început · 42 min să intri", at 9:30, and at 11:01.
- [ ] **Step 2: Run them; expect failures.** `flutter test test/features/enter_code test/features/game_intro`
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run them; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "Start screen and intro texts"`

---

### Task 3: Shared pieces on navy

**Files:**
- Modify: `lib/ui/theme/app_colors.dart` (`dangerOnNavy`, `dangerTextOnNavy`, both themes, in `copyWith` and `lerp`), `lib/ui/components/inputs/code_box.dart`, `lib/ui/components/inputs/code_boxes_input.dart`, `lib/ui/components/misc/avatar_stack.dart`
- Test: `test/ui/components/start_pieces_test.dart`

**Interfaces:**
- `CodeBoxesInput(..., onDark: true)` and `CodeBox(..., onDark: true)`:
  - Geometry: 38 × 48 content + 2 px border = 42 × 52, radius 10, gap 6.
  - Fill `onNavy` 8 %; text Monospace 20 w500 `onNavy`.
  - Border (2 px): `dangerOnNavy` on error, `tickOnNavy` when filled or active, else `onNavy` 30 %.
  - The light version (step 3) is unchanged.
- `AvatarStack(..., gap: 6)`: circles side by side with a 6 px gap instead of overlapping (step = size + gap). Mockup 05: `size: 30`, `onDark: true`, `total: team size`, so the empty places are dashed rings. The dashed ring is `box-sizing:border-box` in the mockup, so it stays 30.

- [ ] **Step 1: Write the failing tests:**
  - A dark box is 42 × 52 with a 2 px border; on error the border is `dangerOnNavy`.
  - Five dark boxes are 5 × 42 + 4 × 6 = 234 wide.
  - `AvatarStack(gap: 6, size: 30, initials: ['VC','AM','IR'], total: 4, onDark: true)` is 4 × 30 + 3 × 6 = 138 wide, the third circle's left is 72, and the fourth is the dashed one.
  - The token values.
  - The light `CodeBox` stays 34 × 47.
  - 320 px at 1.3×: no overflow.
- [ ] **Step 2: Run; expect failures.** `flutter test test/ui/components/start_pieces_test.dart`
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run; expect PASS. Then `flutter test test/ui`; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "Code boxes and avatars on navy, error tokens"`

---

### Task 4: The start-code screen

**Files:**
- Create: `lib/features/enter_code/controller/start_code_controller.dart`, `lib/features/enter_code/widgets/start_code_view.dart`, `lib/features/enter_code/widgets/team_here_card.dart`
- Modify: `lib/features/enter_code/screen/enter_code.dart` (rebuilt), and delete `lib/features/enter_code/controller/enter_code_controller.dart` (its flow moves into the new controller)
- Test: `test/features/enter_code/start_code_controller_test.dart`, `test/features/enter_code/start_code_view_test.dart`

**Interfaces:**
- Consumes: `StartCodeFlow`, `checkStartCode` (existing); Task 2's texts; Task 3's `CodeBoxesInput(onDark)` and `AvatarStack(gap)`; `activeMembers` (`features/home/logic/live_texts.dart`); `KeepsPresence` (`features/event_game/widgets/keeps_presence.dart`); `GameDoor` (Task 5; until Task 5, the screen calls the `onEnter` callback it is given).
- `StartCodeController extends ChangeNotifier`:
  - Constructor:
    ```dart
    StartCodeController({
      required Event event,
      required Future<Team?> Function() findTeam,
      required Stream<Team> Function(String teamName) watchTeam,
      required Future<void> Function(Team team) startTeam,
      required Future<void> Function(Event event, Team team) onEnter,
      DateTime Function() clock = DateTime.now,
    })
    ```
  - `Future<void> load()` finds the team, then follows `watchTeam`.
  - Getters: `team` (Team?), `code` (String), `result` (StartCodeResult?), `busy`.
  - `void setCode(String)` clears `result`.
  - `Future<void> submit()`:
    - A started team skips the code and calls `onEnter`.
    - Otherwise the flow runs; on `ok` it calls `onEnter(event, team)`.
    - It is ignored while `busy`.
  - `bool get started` is the streamed team's `hasStarted`. When it turns true, `code` and `result` clear.
  - `dispose` cancels the stream.
- `StartCodeView({required Event event, required DateTime now, required Team? team, required int codeLength, required String code, required StartCodeResult? result, required bool started, required bool busy, required ValueChanged<String> onCode, required VoidCallback onSubmit, required VoidCallback onClose, VoidCallback? onChat})`:
  - Mockup 05's left phone, top to bottom:
    - **Navy page and top row** (padding 12/14): `x` 18 on the left; the `soon` pill on the right ("A început · …", padding 2/9, 11 w500, `onTick` text).
    - **Header** (padding 20/16/0, centred): event name 11 at 75 %; "Introdu codul de start" 18 w500, 2 px above; `codeHint` 12 at 75 %, 4 above.
    - **Boxes**, 22 below (hidden when `started`).
    - **Error line**, 10 below: `dangerTextOnNavy` w500 12, with an `alert_circle` 14.
    - **"Nu contează literele mari sau mici."** 11 at 70 %, 4 below.
    - **`TeamHereCard`**, margin 22/14/0: `onNavy` 8 %, radius 14, padding 10/12. "Echipa {team}" 11 at 80 %, 6 px gap. A row: `AvatarStack` (active members, 30, gap 6, total = team size), then `hereLine` 11 at 80 %, 4 to its left.
    - **Bottom** (padding 14): button `tickOnNavy` fill, radius 12, padding 11, w500 `onTick`. Its label is "Pornește jocul", or "Intră în joc" when `started`; it shows a spinner when `busy`. Under it, 8 px: the chat link (`message_circle` 13 + "Nu ai codul? Scrie-i organizatorului", 11 at 70 %), shown only with `onChat`.
  - The body scrolls when the keyboard is up.
- `EnterCode` screen:
  - Builds the controller from providers and services.
  - Wraps the view in `ClockBuilder(interval: 30 s)`.
  - Wraps it in `KeepsPresence` once the team is known.
  - `onChat` opens `Routes.chatScreen` with `{'eventId', 'team'}`; `onClose` pops.
  - The route still takes a bare `Event`.

- [ ] **Step 1: Write the failing tests:**
  - **Controller, with fakes:**
    - `load` finds and then streams the team.
    - A wrong code sets `result = wrong` and keeps `code`.
    - A right code calls `startTeam` once and `onEnter` once, even with two quick `submit`s (Review Focus 1).
    - A stream event with `hasStarted` clears the code (Review Focus 2).
    - `started` + `submit` calls `onEnter` without `startTeam`.
    - No team: a right code gives `noTeam` (Review Focus 3).
    - `dispose` cancels the stream.
  - **View, with mockup data** (`sampleEvent()`, team Vulpile, 3 of 4 here, at 10:18):
    - The pill, the header texts, five boxes and their keys, and the wrong-code line with the boxes' `dangerOnNavy` border.
    - "3 din 4 sunt aici".
    - "Pornește jocul" calls `onSubmit`; the chat link calls `onChat`; `x` calls `onClose`.
    - With `started`: no boxes, "Intră în joc".
    - With no team: no team card and no chat link.
    - At 10:18 + 43 min: "Intrarea s-a închis" (Review Focus 4).
    - 320 px at 1.3× with the keyboard inset of 300: no overflow.
- [ ] **Step 2: Run; expect failures.** `flutter test test/features/enter_code`
- [ ] **Step 3: Implement**; rebuild the screen; delete the old controller and its test.
- [ ] **Step 4: Run; expect PASS. Then `flutter test`; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "Start-code screen as mockup 05: time left, code boxes, who is here, chat"`

---

### Task 5: GameDoor — the intro once, then the game

**Files:**
- Create: `lib/features/game_intro/logic/intro_seen_store.dart`, `lib/features/game_intro/logic/game_door.dart`
- Modify: `lib/constants/routes.dart` (`gameIntro`), `lib/main.dart` (the route; the screen comes in Task 6, so register a placeholder that Task 6 replaces), the player pushes of `Routes.eventGame` in `enter_code` (via `onEnter`), `home_controller.dart` (`openGame`), `play_tab_controller.dart`, `event_details_controller.dart:85`
- Test: `test/features/game_intro/game_door_test.dart`

**Interfaces:**
- `class IntroSeenStore { Future<bool> seen(String eventId, String teamName); Future<void> markSeen(String eventId, String teamName); }`: shared_preferences, a string list under `introSeen`, entries `"$eventId|$teamName"`.
- `class GameDoor`:
  - Constructor: `GameDoor({IntroSeenStore? store})`.
  - `Future<void> open(NavigatorState navigator, Event event, Team team)`: pushes `Routes.gameIntro` the first time on this device, else `Routes.eventGame`, both with `{'event': event, 'team': team}`.
  - `Future<void> leaveIntro(NavigatorState navigator, Event event, Team team)`: marks the intro seen, then `pushReplacementNamed(Routes.eventGame, ...)`.

- [ ] **Step 1: Write the failing tests** (a `MaterialApp` with both routes as stub pages that show their name, and `SharedPreferences.setMockInitialValues({})`):
  - First `open` shows the intro page.
  - `leaveIntro` replaces it with the game page: back pops to home, not to the intro.
  - The next `open` for the same event and team goes straight to the game.
  - Another team, or another event, gets the intro again.
- [ ] **Step 2: Run; expect failures.** `flutter test test/features/game_intro`
- [ ] **Step 3: Implement, then switch the four player entry points to `GameDoor().open`.** Leave `menu.dart`'s organiser preview alone.
- [ ] **Step 4: Run; expect PASS. Then `flutter test`; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "GameDoor: the intro letter once per device, then the game"`

---

### Task 6: The intro letter screen

**Files:**
- Create: `lib/features/game_intro/controller/game_intro_controller.dart`, `lib/features/game_intro/screen/game_intro_screen.dart`, `lib/features/game_intro/widgets/game_intro_view.dart`, `lib/features/game_intro/widgets/intro_letter_card.dart`, `lib/features/game_intro/widgets/intro_fact_chip.dart`
- Modify: `lib/main.dart` (`Routes.gameIntro` → `GameIntroScreen`), `docs/features.md` (route row and folder), `docs/screens.md`
- Test: `test/features/game_intro/game_intro_view_test.dart`

**Interfaces:**
- Consumes: `introDateLine`, `introFacts` (Task 2); `paletteFor` (Task 1); `GameDoor.leaveIntro` (Task 5).
- `GameIntroController({required Event event, required Team team, required GameDoor door})` with `Future<void> start(NavigatorState navigator)`. It ignores a second call while the first is running.
- `GameIntroView({required Event event, required VoidCallback onStart})`. It reads `context.eventPalette`; the screen wraps it in `EventThemeScope(palette: paletteFor(event.look, context.colors))`.
  - **Page:** `background` fill, `ink` text.
  - **Top** (padding 30/18/0, centred):
    - A seal: a 70 px `accent` circle with a 3 px `secondaryAccent` border, so 76 across; a `compass` 34 icon in `background`.
    - `introDateLine`: 11, letter spacing 1, 75 %, 12 below the seal.
    - The name: `voiceFont` 22, line height 1.25, 4 below.
  - **`IntroLetterCard`**, only with `introLetter`:
    - Margin 16/16/0; `surface` fill, 1 px `border`, radius 14, padding 12/14.
    - Text in `voiceFont` 14, line height 1.55.
    - With a signature, "— {introSignature}" at the right in italic, 6 px below.
  - **`IntroFactChip`s**, 14 below, centred, gap 6: 11 px text; `surface` fill, 1 px `border`, radius 99, padding 3/10; a 12 px icon.
  - **Bottom** (padding 14):
    - Button "Spre prima misiune": `accent` fill, `surface` text, radius 12, padding 11, w500.
    - "Cronometrul pornește acum pentru toată echipa." 11 at 75 %, 8 below.
  - The middle scrolls when the letter is long.

- [ ] **Step 1: Write the failing tests:**
  - With the sample event in `parchment` (introLetter, signature "Cartograful", 6 missions, 120 min, 1 hint), at 14 nov:
    - "Sibiu, 14 noiembrie", the name, the letter, "— Cartograful", "6 misiuni", "2 ore", "1 indiciu / misiune".
    - The button calls `onStart`.
    - The page colour is `EventPalette.parchment.background`, and the seal is 76 across.
  - With no letter: no letter card (Review Focus 5).
  - With no city: "14 noiembrie".
  - With unknown duration: no hourglass chip.
  - A 2 000-character letter scrolls without overflow.
  - 320 px at 1.3×, parchment and app looks, light and dark: no overflow.
  - The controller ignores a double tap (one `leaveIntro`).
- [ ] **Step 2: Run; expect failures.**
- [ ] **Step 3: Implement**; wire the route; update the docs.
- [ ] **Step 4: Run `flutter test`; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "Intro letter screen in the event's look"`

---

### Task 7: Gallery previews and docs

**Files:**
- Create: `lib/dev/start_code_preview.dart` (the start view in its states: typing, wrong code, started, no team), `lib/dev/game_intro_preview.dart` (parchment and app looks)
- Modify: `lib/dev/sample_event.dart` (the sample event gains `introLetter` (mockup 05's text), `introSignature: 'Cartograful'`, `hintsPerMission: 1`, `look: EventLook.parchment`, `startCode: 'HARTA'`), `lib/dev/shell_previews_launcher.dart` (buttons "Cod de start" and "Scrisoarea"), `docs/ui-and-theme.md` (tokens, `CodeBox` on navy, `AvatarStack(gap)`), `CLAUDE.md` if a line changes
- Test: `test/dev/shell_previews_test.dart` (both previews in light and dark, every state, no exception; the launcher opens them)

- [ ] **Step 1: Write the failing test.**
- [ ] **Step 2: Run; expect failure.**
- [ ] **Step 3: Implement the previews and update the docs.**
- [ ] **Step 4: Run `flutter test` and `flutter analyze`; expect PASS and no new issues.**
- [ ] **Step 5: Commit** — `git commit -m "Gallery: start code and intro letter; docs"`
