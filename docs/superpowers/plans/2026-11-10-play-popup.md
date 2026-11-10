# Joacă Pop-up Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Tapping the raised Joacă key opens a card above the bar (no new screen), exactly as mockup 10 shows, and the old Joacă tab page goes away.

**Architecture:** `AppShell` learns two generic things: a tab can be an *action* (tapping runs a callback instead of switching page) and the shell can show an *overlay* over the pages but under the bar. `UserShell` owns a `PlayPopupController` (the state, the team, the live ranking, the suggestions, a 1 s clock) and passes a `PlayPopup` widget as the overlay while it is open. `PlayPopup` runs the entry/exit animations and picks one of four cards.

**Tech Stack:** Flutter (Dart ^3.7.2), provider, flutter_tabler_icons, existing `TeamService` / `EventList` / `UserEventsProvider`.

**Spec:** `docs/roadmap/mockups/10-play-popup.html` (approved by Victor 2026-11-10: "do it exactly like that"), plus his two answers below.

## Global Constraints

- Match mockup 10 one-to-one: texts, order of rows, icons, sizes (px in the mockup = logical px).
- Victor's answers: entry animation is **From the key** for Registered / Start window / Playing, and **Draw a card** for Not registered. The live key **stays as today** (red circle, play icon, "În joc"); the mockup's red ring is not built.
- The key turns 90° (220 ms, `Curves.easeOutBack`-like) then shows an X while the pop-up is open; the circle fill is `colors.liveCard` while open (red stays red while live). Tapping the X closes.
- Close: X, tap on the dimmed area, drag the card down more than 90 px, or system back. Closing shrinks the card back into the key (220 ms, ease-in).
- `MediaQuery.disableAnimationsOf(context)` true → plain 200 ms fade, no key turn, no stagger, no deck.
- `HapticFeedback.lightImpact()` on open and on "Alt joc".
- Colours only from `context.colors` (the colour test forbids literals in `lib/features`). New token `scrim`: light `0x8C0C092A`, dark `0xA6000000`. Blur sigma 4 behind it.
- Text 12 px or more, tap targets 44 px or more (memory: readable sizes). No decorative dots before titles.
- Code rules from CLAUDE.md: controller per screen, one widget per file, no `x!`, `lib/ui/` never imports `lib/features/`.
- Romanian copy, verbatim from the mockup:
  - Registered: `Următorul tău joc`, day line from `eventDayLine`, boxes `zile` `ore` `min` `sec`, `N din M membri`, `Start la <b>punctDeStart</b>, meetingPointNote`, `Vezi evenimentul`, `Echipa mea`.
  - Start window: pill `A început`, `Mai ai timp să intri în joc`, boxes `min` `sec`, `N din M sunt aici`, `Codul îl primești de la organizator la <b>punctDeStart</b>`, `Introdu codul de start`.
  - Playing: pill `În joc`, `Misiunea X din Y · <mission title>`, `<h> h <m> min` / `rămase`, `Locul P` / `din T echipe`, `Ultima rezolvată: <b>title</b>, acum N min`, `Continuă jocul`, `Scrie organizatorului`.
  - Not registered: `Nu ești înscris la niciun joc`, `Ce zici de acesta?`, badge `Recomandat pentru tine` (first) / `La întâmplare` (after a reroll), `Vezi evenimentul`, `Alt joc`, `Toate evenimentele`.

## Review Focus

- Registered or start window with the team not loaded yet, or no team found → the card shows without the team row, no crash, no empty gap.
- Event with no `punctDeStart` → the start/code row is left out; no `meetingPointNote` → the sentence ends after the place.
- Not registered and no open public event → the card says `Nu ești înscris la niciun joc` / `Nu e niciun joc deschis acum.` with only `Toate evenimentele`; one suggestion only → no `Alt joc`.
- The state changes while the pop-up is open (the start window opens, the game ends) → the card switches to the new state on the next tick without closing.
- Small phone (320 × 640) with text scale 1.3 → no overflow; the card scrolls inside the space above the bar if it is taller.

---

### Task 1: Texts and suggestions (pure logic)

**Files:**
- Create: `lib/features/play_tab/logic/play_popup_texts.dart`
- Create: `lib/features/play_tab/logic/play_suggestions.dart`
- Test: `test/features/play_tab/play_popup_texts_test.dart`, `test/features/play_tab/play_suggestions_test.dart`

**Interfaces:**
- Produces:
  - `typedef ClockParts = ({int days, int hours, int minutes, int seconds});`
  - `ClockParts clockParts(Duration left)` (negative → all 0)
  - `String membersLine(Team team, Event event)` → `'3 din 4 membri'` (count `team.memberList.length`, of `event.teamSizeMax`)
  - `String hereLine(Team team, Event event, DateTime now)` → `'3 din 4 sunt aici'` (uses `activeMembers` from `home/logic/live_texts.dart`)
  - `String? startPlace(Event event)` → `punctDeStart` trimmed, null when empty
  - `String missionTitleLine(Event event, Team team)` → `'Misiunea 4 din 6 · Fântâna cu lei'` (no ` · title` when the mission has no title)
  - `String hoursMinutes(Duration left)` → `'1 h 12 min'`, `'12 min'` under an hour, never negative
  - `({String? title, String ago})? lastSolved(Event event, Team team, DateTime now)` → null when nothing solved; `ago` is `'acum 6 min'` / `'acum câteva secunde'` / `'acum 2 h'`
  - `String suggestionWhen(DateTime d)` → `'Sâm 14 nov · 11:00'`
  - `List<Event> openSuggestions(List<Event> all, Set<String> registeredIds, DateTime now)`: same filter as `_recommended` in `home/logic/home_hero.dart` (public, future, not registered, enrolment open), sorted by `dateEvent` ascending. Move that filter into a shared `bool isOpenSuggestion(Event, Set<String>, DateTime)` in this file and make `_recommended` call it.
  - `int nextSuggestion(int current, int count, Random random)` → a different index in `0..count-1` (returns `current` when `count < 2`)

- [ ] **Step 1: Write the failing tests**

```dart
test('clockParts splits and clamps', () {
  expect(clockParts(const Duration(days: 20, hours: 2, minutes: 12, seconds: 33)), (days: 20, hours: 2, minutes: 12, seconds: 33));
  expect(clockParts(const Duration(seconds: -5)), (days: 0, hours: 0, minutes: 0, seconds: 0));
});
test('membersLine counts members of the max size', () => expect(membersLine(teamWith3, eventMax4), '3 din 4 membri'));
test('missionTitleLine names the current mission', () => expect(missionTitleLine(sixMissions, progress3), 'Misiunea 4 din 6 · Fântâna cu lei'));
test('hoursMinutes', () {
  expect(hoursMinutes(const Duration(hours: 1, minutes: 12)), '1 h 12 min');
  expect(hoursMinutes(const Duration(minutes: 12)), '12 min');
  expect(hoursMinutes(const Duration(minutes: -3)), '0 min');
});
test('lastSolved gives the title and how long ago', () {
  expect(lastSolved(event, solvedMission2SixMinAgo, now), (title: 'Turnul Sfatului', ago: 'acum 6 min'));
  expect(lastSolved(event, nothingSolved, now), isNull);
});
test('startPlace is null when empty', () => expect(startPlace(Event(punctDeStart: '  ')), isNull));
test('suggestionWhen', () => expect(suggestionWhen(DateTime(2026, 11, 14, 11)), 'Sâm 14 nov · 11:00'));
test('openSuggestions keeps open public future events, earliest first', ...); // registered, private, past, enrolment closed are left out
test('nextSuggestion never repeats the current one', () {
  for (var seed = 0; seed < 50; seed++) {
    expect(nextSuggestion(1, 4, Random(seed)), isNot(1));
  }
  expect(nextSuggestion(0, 1, Random(1)), 0);
});
```

- [ ] **Step 2: Run, expect FAIL** (`flutter test test/features/play_tab/`; functions not defined)
- [ ] **Step 3: Implement the two files**; `home_hero.dart` uses `isOpenSuggestion`.
- [ ] **Step 4: Run** `flutter test test/features/play_tab/ test/features/home/` → PASS
- [ ] **Step 5: Commit** `Joacă pop-up: texts and suggestions`

### Task 2: Shell support (action tab, overlay, key states, scrim token)

**Files:**
- Modify: `lib/ui/components/navigation/app_shell.dart`, `app_nav_item.dart`, `raised_nav_button.dart`
- Modify: `lib/ui/theme/app_colors.dart` (add `scrim` to fields, `light`, `dark`, `copyWith`, `lerp`)
- Modify: `lib/features/shell/logic/player_tabs.dart`: `playerNavItems({required bool live, bool open = false})`
- Test: `test/ui/components/navigation/app_shell_test.dart` (create or extend), `test/features/shell/player_tabs_test.dart`

**Interfaces:**
- Produces:
  - `AppShellTab({required AppNavItem item, WidgetBuilder? builder, VoidCallback? onTap})`, asserting exactly one of `builder` / `onTap`. An action tab never becomes the current page.
  - `AppShell({..., Widget? overlay, VoidCallback? onOverlayBack})`: `overlay` sits in a `Stack` over the `IndexedStack`, inside the body padding (so it ends at the bar's top, above the raised circle's rise). While `overlay != null`, back calls `onOverlayBack` and does not change tab.
  - `AppNavItem.open` (bool, default false). `RaisedNavButton` animates: on `open` the icon rotates a quarter turn, then crossfades to `TablerIcons.x`; fill `colors.liveCard` unless `live`. Back to the item icon on close.
  - `playerNavItems(open: true)` sets `open` on the Joacă item.

- [ ] **Step 1: Failing tests**: tapping an action tab calls `onTap` and `ShellController.index` stays 0; with an overlay, a back press calls `onOverlayBack` and the index stays where it was; the overlay is painted (finds its key) and the bar is still hit-testable (tap Evenimente switches tab); `playerNavItems(live: false, open: true)[PlayerTab.play].open` is true; the raised circle shows `TablerIcons.x` after settling with `open: true`.
- [ ] **Step 2: Run, expect FAIL**
- [ ] **Step 3: Implement**
- [ ] **Step 4: Run** `flutter test test/ui test/features/shell` → PASS (including `no_hardcoded_colors_test`)
- [ ] **Step 5: Commit** `Shell: action tabs, an overlay above the pages, the key's open state`

### Task 3: PlayPopupController

**Files:**
- Create: `lib/features/play_tab/controller/play_popup_controller.dart`
- Delete: `lib/features/play_tab/controller/play_tab_controller.dart`
- Test: `test/features/play_tab/play_popup_controller_test.dart`

**Interfaces:**
- Consumes: Task 1 functions; `heroFromProviders(includeFinished: false, ...)`, `playTabState`; `TeamService.getUserTeamForEvent(eventId, uid)`, `TeamService.getStreamTeams(eventId)`, `TeamService.countTeams(eventId)`; `rankTeams`.
- Produces `class PlayPopupController extends ChangeNotifier`:
  - constructor `({required UserEventsProvider userEvents, required EventList eventList, required Future<Team?> Function(Event) teamFor, required Stream<List<Team>> Function(String eventId) teams, required Future<int> Function(String eventId) countTeams, DateTime Function()? clock, Random? random})`
  - `bool get isOpen`, `bool get isClosing`; `void toggle()`, `void open()`, `void requestClose()` (sets `isClosing`), `void closed()` (called by the widget when the exit animation ends; clears everything)
  - `DateTime get now`; a 1 s `Timer` runs only while open and notifies each second
  - `PlayTabState get state` (re-read every notify)
  - `Team? get team`: the live state's team, else the fetched team for the shown event (fetched once per event id on open)
  - `List<RankedTeam> get ranked` (streamed only while open in the live state)
  - `List<Event> get suggestions`, `int get suggestionIndex`, `bool get rerolled`, `void reroll()` (uses `nextSuggestion`; sets `rerolled`), `int? teamCount(Event)` (fetched for the shown suggestion)
- Navigation stays out of the controller's state: actions are plain callbacks wired in `UserShell` (Task 6).

- [ ] **Step 1: Failing tests** (fake providers as in `play_tab_state_test.dart`, fake clock): open → 1 s ticks notify, closed → timer stops; `requestClose` then `closed` → `isOpen` false; in PlayNext the team comes from `teamFor` and is null until it resolves; reroll changes index and sets `rerolled`; live state subscribes to `teams` and cancels on close; changing providers while open changes `state`.
- [ ] **Step 2: Run, expect FAIL**
- [ ] **Step 3: Implement**
- [ ] **Step 4: Run** → PASS
- [ ] **Step 5: Commit** `Joacă pop-up: controller`

### Task 4: Card building blocks

**Files (all in `lib/features/play_tab/widgets/`, one widget each):**
- `ticket_clipper.dart`: `TicketClipper(double cut)`, a `CustomClipper<Path>`: rounded rect radius 22 minus two 13 px circles centred on the left and right edges at `cut`.
- `ticket_card.dart`: `TicketCard({required Color topFill, required Widget top, required Widget bottom})`: measures the top part (a `SizeChangedLayoutNotifier` or `LayoutBuilder` + `GlobalKey`) to set the cut; the bottom has a 2 px dashed top border in `colors.border`; white `colors.panel` bottom; shadow `0 18 40` of `colors.text` at .4 (light only, as the mockup).
- `card_handle.dart`: 40 × 5, radius 3, `onNavy` at .4 on navy, `border` on white.
- `rolling_number.dart`: `RollingNumber(String value, TextStyle style)`: when the value changes the new text slides up from 70 % with fade, 300 ms, overshoot curve (`Cubic(.3, 1.4, .6, 1)`).
- `clock_boxes.dart`: `ClockBoxes(List<(String value, String label)> parts)`: equal boxes, gap 8, `onNavyFaint` fill, radius 12, value SpaceMono 24 bold, label 12 at .75.
- `team_row.dart`: `TeamRow(Team team, String line)`: overlapped 32 px initial circles (`initialsOf`, fills tickOnNavy / amber / navActivePill in turn, 2 px panel ring, −8 overlap), one dashed empty circle per free place up to `teamSizeMax`, then bold `Echipa <name>` over the 13 px muted line.
- `icon_row.dart`: `IconRow(IconData icon, InlineSpan text)`: 20 px accent icon, gap 10, 14 px text.
- `game_pill.dart`: `GamePill(IconData, String, Color fill, Color text)`: 12 px w600, radius 99, padding 3 × 11.
- `mission_bar.dart`: `MissionBar(int total, int current)`: 8 px segments, gap 5, done tickOnNavy, current amber blinking (opacity 1 → .45, 1.2 s, repeat), rest onNavyFaint.
- `stagger_in.dart`: `StaggerIn({required int index, required bool play, required Widget child})`: fade + 10 px rise, 380 ms ease-out, delay `index * 55 ms`; shows the child as is when `play` is false.

- [ ] **Step 1: Failing test** (logic-only per memory): `TicketClipper(100).getClip(Size(300, 400))` does not contain `Offset(5, 100)` or `Offset(295, 100)` but contains `Offset(150, 100)` and `Offset(5, 50)`.
- [ ] **Step 2: Run, expect FAIL** → **Step 3: Implement all files** → **Step 4: Run, PASS**
- [ ] **Step 5: Commit** `Joacă pop-up: ticket and card parts`

### Task 5: The four cards and the pop-up

**Files (in `lib/features/play_tab/widgets/`):**
- Create: `next_game_ticket.dart`, `start_code_ticket.dart`, `live_game_ticket.dart`, `suggestion_card.dart`, `empty_suggestion_card.dart`, `card_deck_intro.dart`, `play_popup.dart`
- Delete: `play_card.dart`, `play_tab_view.dart`, `lib/features/play_tab/screen/play_tab_screen.dart`, `test/features/play_tab/play_tab_view_test.dart`
- Test: `test/features/play_tab/play_popup_test.dart`

**Interfaces:**
- Consumes: Task 3 controller, Task 4 parts, Task 1 texts, `EventPicture`, `eventDayLine`, `cardRouteFacts`.
- Produces `PlayPopup({required PlayPopupController controller, required PlayPopupActions actions})` and `class PlayPopupActions { openEvent(Event), openTeam(Event), enterCode(Event), continueGame(Event, Team), openChat(Event, Team), browseAll() }` (plain `final` callbacks, in `play_popup_actions.dart`).

Layout and behaviour (from the mockup):
- Full overlay: `colors.scrim` with `BackdropFilter` blur 4, fades in 250 ms; tap → `requestClose`.
- Card: 14 px from the sides, 20 px above the overlay bottom; `ConstrainedBox(maxHeight: overlay height − 40)` + `SingleChildScrollView` so a tall card scrolls.
- Entry **From the key**: transform origin at the key (bottom centre + 60 px); 560 ms: scale .1 → 1.03 (75 %) → 1, translateY 50 → −6 → 0, opacity 0 → 1 by 40 %. Then stagger the rows (`StaggerIn`) in order.
- Entry **Draw a card** (Not registered): `CardDeckIntro` draws three card backs the size of the real card (navy, 45° stripes of tickOnNavy at .13, 3 px panel border, radius 22, key icon 56 + `TeamXperience` 14 w600): fly up from the key into a fan (−54, 14, −9°) (0, 0, 0) (54, 14, 9°), 340 ms overshoot; after 420 ms swap the outer two and lift the middle (0, −16, ×1.03); after 320 ms gather to the middle; after 300 ms the outer two fade and the middle turns 90° on Y (180 ms); then the real card turns in from −90° (300 ms), then stagger.
- Exit: scale back to .1 into the key with fade, 220 ms ease-in, then `controller.closed()`.
- Drag down on the card: follows the finger; release past 90 px → close, else spring back 200 ms.
- "Alt joc": the dice icon spins 360° (500 ms overshoot), the card turns 90° on Y (180 ms ease-in), content swaps to `controller.reroll()`'s event, turns in from −90° (300 ms), rows show at once; light haptic.
- The card shown follows `controller.state`: `PlayNext` → `NextGameTicket`, `PlayEnterCode` → `StartCodeTicket` (countdown to `dateEvent + enterWindow`), `PlayLive` → `LiveGameTicket` (top fill `colors.liveCard`; time left to `dateEvent + Event.maxDuration`, as `LiveGameCard`; place from `controller.ranked`, the stat box hidden until ranked), `PlayNone` → `SuggestionCard` or `EmptySuggestionCard` when there are no suggestions.
- Buttons call `actions`, and the pop-up closes at once (no exit animation) before navigating.

- [ ] **Step 1: Failing widget tests**: each of the four states shows its mockup texts (e.g. `Următorul tău joc`, `Introdu codul de start`, `Continuă jocul`, `Recomandat pentru tine`); after `Alt joc` the badge reads `La întâmplare`; with no suggestions only `Toate evenimentele` is offered; no team → no `din 4 membri` row; one overflow check: each state at 320 × 640, text scale 1.3, no exceptions; with `disableAnimations` the card is fully shown after one 200 ms pump.
- [ ] **Step 2: Run, expect FAIL** → **Step 3: Implement** → **Step 4: Run, PASS**
- [ ] **Step 5: Commit** `Joacă pop-up: the four cards and their animations`

### Task 6: Wire it into the player shell, preview, docs

**Files:**
- Modify: `lib/features/shell/screen/user_shell.dart`: own a `PlayPopupController` (built in `didChangeDependencies` with `TeamService()` calls and the current user's uid); the Joacă tab becomes `AppShellTab(item: ..., onTap: controller.toggle)`; `overlay: controller.isOpen ? PlayPopup(...) : null`; `onOverlayBack: controller.requestClose`; `playerNavItems(live: live, open: controller.isOpen && !controller.isClosing)`; actions navigate like `HomeController` does (`Routes.eventDetails` with `{'event', 'isAdmin': false}`, `Routes.registerTeamDetails` with `{'event', 'user'}`, `Routes.enterCodeScreen`, `GameDoor().open`, `Routes.chatScreen` with `{'eventId', 'team'}`, `ShellController.select(PlayerTab.events)`).
- Replace: `lib/dev/play_tab_preview.dart` → `play_popup_preview.dart` (four states from `sample_event.dart`, the bar, tap the key to open); update `shell_previews_launcher.dart`.
- Modify docs: `docs/features.md`, `docs/screens.md`, `docs/ui-and-theme.md` (scrim token, action tab, overlay), `docs/roadmap/mockups-roadmap.md` L4 item 4 (Joacă is a pop-up, mockup 10), `CLAUDE.md` startup line (Joacă opens a pop-up).
- Test: `test/features/shell/user_shell_test.dart` if one exists, else add one test to `play_popup_test.dart`: tapping the key in the shell opens the pop-up and the page underneath is still Acasă; tapping the X closes it.

- [ ] **Step 1: Failing test** as above → **Step 2: FAIL** → **Step 3: Implement** → **Step 4: PASS**
- [ ] **Step 5: Full check**: `flutter analyze` (no new issues) and `flutter test` (all pass)
- [ ] **Step 6: Commit** `Joacă opens the pop-up; the Joacă page is gone`
- [ ] **Step 7: Run on the phone** (Victor) and check against the mockup side by side.
- [ ] **Step 8: Merge** into `redesign/mockups`: first merge the latest `redesign/mockups` into this branch (the other agents may have merged; `user_shell.dart`, `player_tabs.dart`, docs are the likely conflicts), re-run `flutter test`, then merge with `--no-ff`. No push.
