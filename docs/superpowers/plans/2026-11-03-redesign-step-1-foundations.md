# Redesign step 1: foundations Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Lay the ground the mockup screens stand on: fix the start code and team registration (L0), add the colour and text tokens, the event palette and the icons (U0), and build the first shared components (route strip and trail, fact tiles, chips, sticky action bar) (U1).

**Architecture:**
- Pure logic goes in small files with unit tests.
- New widgets go in `lib/ui/components/`, one per file, reading `context.colors` / `context.eventPalette`. All copy comes in through parameters.
- A Firebase-free gallery entry point (`lib/dev/gallery_main.dart`) shows every new component with the mockup copy, so it can be compared side by side with `docs/roadmap/mockups/01-event-details.html`.

**Tech Stack:** Flutter (Dart ^3.7.2), provider, flutter_test, and `flutter_tabler_icons` (new; the mockups use Tabler icons).

**Spec:** `docs/roadmap/mockups-roadmap.md` (L0, U0, U1, step 1 of "Order and size"), with `docs/roadmap/mockups/01-event-details.html` as the visual reference.

## Global Constraints

- Branch: work on `redesign/step-1-foundations`, merge into `redesign/mockups` when done. Never merge into `main`, never push.
- Sizes: 1 mockup CSS px = 1 logical pixel. The mockup phone is 304 px wide inside its frame; real screens stretch horizontally, while text sizes, paddings and radii stay the same.
- Colours: from `context.colors` (app) or `context.eventPalette` (inside an event). No `Color(0x…)` / `Colors.*` in `lib/features`; `test/ui/no_hardcoded_colors_test.dart` must stay green with no new allow-list entries.
- Components in `lib/ui/components/` take every user-visible string as a parameter, and `lib/ui/` never imports `lib/features/`.
- One widget per file. No `x!`; use local promotion. One controller per screen.
- `flutter analyze` is clean and `flutter test` passes at the end of every task.
- Commit messages end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

## Review Focus

1. **Start code with spaces inside or mixed case.** "har ti", " HARTI " and "Harti" must all open a game whose code is "HARTI". Covered in Task 1.
2. **An event with no start date.** The code must be refused as closed, not crash or let anyone in. Covered in Task 1.
3. **The exact last minute of the window** (start + 60 min) must still let the team in. Covered in Task 1.
4. **Large text (1.3×) on a narrow phone (320 px).** `FactRow`, `RouteStrip` and `StickyActionBar` must not overflow. Covered in Tasks 7, 8 and 9.
5. **Dark mode.** White-on-navy text must keep contrast of at least 4.5:1 in both themes. Covered in Task 3.

---

### Task 1: Start-code check (L0)

**Files:**
- Create: `lib/features/enter_code/logic/start_code_check.dart`
- Modify: `lib/features/enter_code/controller/enter_code_controller.dart`, `lib/features/enter_code/screen/enter_code.dart` (the button's `onPressed` only), `lib/model/event.dart`, `lib/features/home/logic/home_hero.dart:6`
- Test: `test/features/enter_code/start_code_check_test.dart`

**Interfaces:**
- Produces:
  - `enum StartCodeResult { ok, wrong, tooEarly, closed }`
  - `StartCodeResult checkStartCode({required String input, required Event event, required DateTime now})`
  - `String normaliseCode(String code)`
  - `static const Duration Event.enterWindow = Duration(minutes: 60)`
  - `Future<StartCodeResult> EnterCodeController.submit()`

- [ ] **Step 1: Write the failing tests.** Use an event with `startCode: 'HARTI'`, `dateEvent: DateTime(2026, 11, 14, 10)` and `isStopped: false`. Expected results:

  | `now` | input | other | expected |
  |---|---|---|---|
  | 10:20 | `'harti'`, `' HARTI '`, `'har ti'`, `'Harti'` | | `ok` |
  | 10:20 | `'HARTA'` | | `wrong` |
  | 10:20 | `''` | | `wrong` |
  | 09:59 | `'HARTI'` | | `tooEarly` |
  | 11:00 | `'HARTI'` | | `ok` (inclusive edge) |
  | 11:00:01 | `'HARTI'` | | `closed` |
  | 10:20 | `'HARTI'` | `isStopped = true` | `closed` |
  | 10:20 | `'HARTI'` | `dateEvent = null` | `closed` |
  | 10:20 | `''` | `startCode = null` | `wrong` |

  Also test that `normaliseCode(' Ha r\tTI ') == 'harti'`.

- [ ] **Step 2: Run the tests and check they fail.**
  Run: `flutter test test/features/enter_code/start_code_check_test.dart`
  Expected: compile error, because `checkStartCode` is not defined.

- [ ] **Step 3: Implement.**
  - `normaliseCode` removes every whitespace character (`\s`) and lower-cases. Diacritics stay as they are.
  - The order of checks in `checkStartCode`:
    1. no date or `event.isOver` → `closed`
    2. `now` before start → `tooEarly`
    3. `now` after start + `Event.enterWindow` → `closed`
    4. normalised codes differ, or the event code is blank → `wrong`
    5. otherwise `ok`
  - Add `Event.enterWindow`. Make `enterCodeWindow` in `home_hero.dart` read `Event.enterWindow`, so the home card and the check share one value.

- [ ] **Step 4: Rewrite the controller as `submit()`.**
  - It returns the result. On `ok` it loads the team; when there is none it returns `wrong` and logs nothing. Use local promotion instead of `team!`.
  - It calls `startTeam` and navigates as today.
  - Remove the `print`. The screen shows the error through `MySnackBars.errorSnackBar`:

    | result | title | message |
    |---|---|---|
    | `wrong` | "Cod greșit" | "Codul nu e corect. Verifică literele." |
    | `tooEarly` | "Prea devreme" | "Jocul nu a început încă." |
    | `closed` | "Prea târziu" | "Timpul pentru intrare s-a terminat." |

    The full restyle of this screen is step 6.

- [ ] **Step 5: Run the tests and analyze.**
  Run: `flutter test test/features/enter_code/ && flutter analyze`
  Expected: all pass, no issues.

- [ ] **Step 6: Commit** with the message "Start code ignores capitals and spaces and reports why it is refused".

### Task 2: Team registration without BuildContext (L0)

**Files:**
- Modify: `lib/service/team_service/team_service.dart:16-43`, `lib/features/register_team/controller/register_team_controller.dart:83-95`

**Interfaces:**
- Produces: `Future<Team> TeamService.addTeam(String name, String teamMembers, String captainName, String phoneNumber, String captainEmail, int numberOfMembers, AppUser user, Event event)`, with no `BuildContext`.

- [ ] **Step 1: Change the signature.**
  - Drop the `context` parameter, and the `provider` and `UserProvider` imports.
  - `RegisterTeamController.buttonOnTap` calls `context.read<UserProvider>().addRegisteredEvent(event.eventId)` after `addTeam` returns.
  - The success snackbar and navigation run only when `user != null`. Today they run even when there is no user.

- [ ] **Step 2: Verify.**
  Run: `flutter analyze && flutter test`
  Expected: no issues, all tests pass. The service talks straight to Firestore and has no test seam, so this task relies on analyze and the existing tests.

- [ ] **Step 3: Commit** with the message "Team service no longer needs a BuildContext to register a team".

### Task 3: Colour tokens for navy surfaces (U0)

**Files:**
- Modify: `lib/ui/theme/app_colors.dart` (constructor, fields, `light`, `dark`, `copyWith`, `lerp`)
- Test: `test/ui/theme/app_colors_test.dart`, `test/ui/theme/contrast_test.dart`

**Interfaces:**
- Produces: `AppColors.onNavy`, `onNavyMuted`, `onNavyFaint`, `tickOnNavy`, `heroButton`

Values, from the mockups (navy cards in 01–04, and the hero round buttons in 01):

| token | light | dark | use |
|---|---|---|---|
| `onNavy` | `0xFFFFFFFF` | `0xFFF2F4F8` | text and icons on navy |
| `onNavyMuted` | `0x66FFFFFF` | `0x66F2F4F8` | secondary text on navy (rgba .4) |
| `onNavyFaint` | `0x1AFFFFFF` | `0x1AF2F4F8` | tiles on navy (rgba .1) |
| `tickOnNavy` | `0xFF53C4C7` | `0xFF53C4C7` | teal accents on navy |
| `heroButton` | `0xE6FFFFFF` | `0xE6171B22` | round buttons over the hero image (rgba .9) |

- [ ] **Step 1: Write the failing tests.**
  - `app_colors_test`: `copyWith(onNavy: X).onNavy == X`, and `lerp` at `t = 0.5` mixes `tickOnNavy`.
  - `contrast_test`: `onNavy` on `navy` has contrast ≥ 4.5 in light and dark, and `tickOnNavy` on `navy` ≥ 3.0, using the helper already in that file.

- [ ] **Step 2: Run the tests and check they fail.**
  Run: `flutter test test/ui/theme/`
  Expected: compile error, because `onNavy` is not defined.

- [ ] **Step 3: Add the five fields** to the constructor, `light`, `dark`, `copyWith` and `lerp`, keeping the existing order style. Each one gets a one-line doc comment saying where it is used.

- [ ] **Step 4: Run the tests and check they pass.**
  Run: `flutter test test/ui/theme/`
  Expected: PASS.

- [ ] **Step 5: Commit** with the message "Add colour tokens for text and accents on navy surfaces".

### Task 4: Mockup text styles (U0)

**Files:**
- Modify: `lib/ui/theme/app_text_styles.dart`
- Test: `test/ui/theme/app_text_styles_test.dart`

**Interfaces:**
- Produces: these styles, all `(BuildContext c) → TextStyle`, coloured from `c.colors`:

| style | size / weight / height | colour | mockup use |
|---|---|---|---|
| `heroTitle` | 19 / w500 / 1.2 | `text` | event name on the hero (colour overridden to `onNavy` there) |
| `trailHeading` | 14 / w500 | `text` | section heading on a trail ("Povestea") |
| `cardTitle` | 12 / w500 | `text` | bold line in cards and rows |
| `pageBody` | 12 / w400 / 1.45 | `text` | default mockup text |
| `smallMuted` | 11 / w400 / 1.45 | `muted` | second lines, labels |
| `factValue` | 18 / w500 / 1.0 | `text` | big numbers ("14") |
| `display` | 34 / w500 / 1.0 | `text` | the finish place ("2") |

The existing styles stay unchanged, because current screens use them.

- [ ] **Step 1: Write a failing test** for each style's `fontSize`, `fontWeight` and `height`, and that `smallMuted` is `AppColors.light.muted` under `AppTheme.light`.
- [ ] **Step 2: Run** `flutter test test/ui/theme/app_text_styles_test.dart`. Expected: FAIL, because the styles are not defined.
- [ ] **Step 3: Add the styles** next to the others, as `_private(AppColors)` builders like the existing ones.
- [ ] **Step 4: Run the tests.** Expected: PASS.
- [ ] **Step 5: Commit** with the message "Add the text styles the mockups use".

### Task 5: Event palette, voice font and icons (U0)

**Files:**
- Create: `lib/ui/theme/event_palette.dart`, `lib/ui/theme/event_theme_scope.dart`
- Modify: `lib/ui/ui.dart` (export both), `pubspec.yaml` (dependency and font)
- Add: `assets/fonts/Gelasio-Variable.ttf`
- Test: `test/ui/theme/event_palette_test.dart`

**Interfaces:**
- Produces:
  - `class EventPalette` with fields `background`, `surface`, `border`, `ink`, `muted`, `faint`, `accent`, `secondaryAccent`, `danger`, `routeDash` (all `Color`), and `voiceFont` (`String`)
  - `static const EventPalette parchment`
  - `factory EventPalette.fromApp(AppColors c)`
  - `class EventThemeScope extends InheritedWidget({required EventPalette palette, required Widget child})`
  - `extension on BuildContext { EventPalette get eventPalette }`
  - The constant `AppFonts.voice = 'Gelasio'`, in `event_palette.dart`

`parchment` values (from mockups 05–08):

| field | value |
|---|---|
| background | `0xFFEADBC0` |
| surface | `0xFFFBF4E4` |
| border | `0xFFD9C49C` |
| ink | `0xFF3B2A1A` |
| muted | `0xFF5E4426` |
| faint | `0xFF8C6A44` |
| accent | `0xFF8A3B12` |
| secondaryAccent | `0xFFB8862B` |
| danger | `0xFFA3262A` |
| routeDash | `0xFFC9B48E` |
| voiceFont | `'Gelasio'` |

`fromApp` maps background ← `page`, surface ← `panel`, border ← `border`, ink ← `text`, muted and faint ← `muted`, accent ← `accent`, secondaryAccent ← `soon`, danger ← `danger`, routeDash ← `tick`, with voiceFont `'Gelasio'`.

- [ ] **Step 1: Add the packages.**
  - Run `flutter pub add flutter_tabler_icons`.
  - Download Gelasio (OFL, metric-compatible with Georgia, the mockups' voice font) from the google/fonts GitHub repo, `ofl/gelasio/Gelasio[wght].ttf`, saved as `assets/fonts/Gelasio-Variable.ttf`. **Ask Victor before downloading.**
  - Register the family with weights 400, 500 and 700, like the other variable fonts in `pubspec.yaml`.

- [ ] **Step 2: Write the failing tests.**
  - Inside an `EventThemeScope(palette: EventPalette.parchment)`, `context.eventPalette.accent == Color(0xFF8A3B12)`.
  - With no scope, under `AppTheme.light`, `eventPalette.background == AppColors.light.page` and `accent == AppColors.light.accent`. Under `AppTheme.dark` it gives the dark values.
  - `updateShouldNotify` is true only when the palette changes.

- [ ] **Step 3: Run** `flutter test test/ui/theme/event_palette_test.dart`. Expected: FAIL, because the classes are not defined.

- [ ] **Step 4: Implement.** `EventPalette` is `@immutable` with `==` and `hashCode` over its fields. The extension returns the nearest scope's palette, or `EventPalette.fromApp(colors)`.

- [ ] **Step 5: Run the tests, then** `flutter analyze`. Expected: PASS, no issues.

- [ ] **Step 6: Commit** with the message "Add the event palette, the Gelasio voice font and Tabler icons".

### Task 6: Chips (U1)

**Files:**
- Create: `lib/ui/components/misc/app_chip.dart`, `lib/ui/components/misc/app_chip_style.dart`
- Test: `test/ui/components/app_chip_test.dart`

**Interfaces:**
- Produces:
  - `enum AppChipStyle { plain, outlined, selected }`
  - `AppChip({required String label, IconData? icon, AppChipStyle style = AppChipStyle.plain, VoidCallback? onTap})`

Layout from mockups 01 and 03:

- Pill radius, padding 3 / 10, 11 px text, 4 px gap, and icon 13.
- `plain`: `panel` fill, `border` outline, `text` label, `accent` icon.
- `outlined`: `panel` fill, `tick` outline, `accent` label and icon.
- `selected`: `navy` fill and outline, `onNavy` label and icon.
- The whole chip is tappable when `onTap` is set. The tap target is at least 32 px tall, with the visual size unchanged, using `materialTapTargetSize` padding or a transparent hit area.

- [ ] **Step 1: Write the failing tests.**
  - Tapping calls `onTap`.
  - With `selected`, the `DecoratedBox` colour is `AppColors.light.navy`.
  - With `outlined`, the border colour is `tick`.
  - The label is shown.

- [ ] **Step 2: Run** `flutter test test/ui/components/app_chip_test.dart`. Expected: FAIL.
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run the tests.** Expected: PASS.
- [ ] **Step 5: Commit** with the message "Add the app chip in plain, outlined and selected styles".

### Task 7: Fact tiles and difficulty dots (U1)

**Files:**
- Create in `lib/ui/components/event/`: `fact_tile.dart`, `date_fact_tile.dart`, `difficulty_dots.dart`, `fact_row.dart`
- Test: `test/ui/components/fact_tiles_test.dart`

**Interfaces:**
- Produces:
  - `FactTile({IconData? icon, Widget? leading, required String value, required String label})`. `leading` wins over `icon`.
  - `DateFactTile({required String day, required String detail})`
  - `DifficultyDots({required int level, int max = 3})`
  - `FactRow({required Widget date, required List<Widget> facts})`

Layout from mockup 01:

- **`FactTile`:** `panel` fill, 1 px `border`, radius `AppRadius.card`, padding 6, centred. Icon 15 in `accent`, then `value` in `cardTitle`, then `label` in `smallMuted`.
- **`DateFactTile`:** `navy` fill, radius `AppRadius.button`, vertical padding 6. `day` in `factValue` coloured `onNavy`, then `detail` at 11 px in `onNavy`.
- **`DifficultyDots`:** the text `'●' * level + '○' * (max - level)`, with `level` clamped to 0..`max`. 13 px, `accent`, letter-spacing 2.
- **`FactRow`:** the date is 62 px wide, then the facts share the rest equally, with a 6 px gap and padding 12 / 14.

- [ ] **Step 1: Write the failing tests.**
  - `DifficultyDots(level: 2)` shows `'●●○'`, `level: 5` shows `'●●●'`, and `level: -1` shows `'○○○'`.
  - `FactRow` with a date and three facts: the date's rendered width is 62.
  - At width 320 and text scale 1.3, there is no overflow.
  - `FactTile` shows `value` and `label`.

- [ ] **Step 2: Run** `flutter test test/ui/components/fact_tiles_test.dart`. Expected: FAIL, because the widgets are not defined.
- [ ] **Step 3: Implement** the four widgets.
- [ ] **Step 4: Run the tests.** Expected: PASS.
- [ ] **Step 5: Commit** with the message "Add fact tiles, the date tile and difficulty dots".

### Task 8: Route strip and route trail (U1)

**Files:**
- Create in `lib/ui/components/route/`: `dashed_line.dart`, `waypoint_dot.dart`, `route_strip.dart`, `route_trail.dart`, `route_trail_section.dart`
- Test: `test/ui/components/route_test.dart`

**Interfaces:**
- Produces:
  - `DashedLine({Axis axis = Axis.horizontal, Color? color, double thickness = 2, double dash = 5, double gap = 4})`. It is a `CustomPaint` filling its parent along `axis`, and its colour defaults to `colors.tick`.
  - `enum WaypointKind { stop, finish }`
  - `WaypointDot({WaypointKind kind = WaypointKind.stop})`: 16×16. `stop` is a `panel` fill with a 3 px `navy` ring; `finish` is filled with `tick`, ring included.
  - `RouteStrip({required String centerLabel, required String startLabel, required String endLabel, String? mapLabel, VoidCallback? onMapTap})`
  - `RouteTrailSection({required Widget child, WaypointKind kind = WaypointKind.stop})`
  - `RouteTrail({required List<RouteTrailSection> sections})`

Layout from mockup 01:

- **`RouteStrip`:** `panel` background, bottom 1 px `border`, padding 12 / 14.
  - Row 1: `TablerIcons.mapPin` (16, `accent`), a horizontal `DashedLine` with `centerLabel` centred on it (11 px, `panel` background, 6 px side padding, ellipsis), `TablerIcons.flag` (16, `navy`), then an `AppChip` of the `outlined` style (from Task 6) showing `mapLabel` with `TablerIcons.map`. The chip appears only when both `mapLabel` and `onMapTap` are set.
  - Row 2, 4 px below: `startLabel` and `endLabel`, `smallMuted`, spread to the edges.
- **`RouteTrail`:** a column of sections. Content starts 40 px from the left and has 14 px right padding. A vertical `DashedLine` runs at x = 21 for the full height. Each section has its `WaypointDot` at x = 14, y = 0, and 18 px bottom padding.

- [ ] **Step 1: Write the failing tests.**
  - `RouteStrip` shows all three labels.
  - Tapping the chip calls `onMapTap`.
  - No chip appears when `onMapTap` is null.
  - At width 320 and text scale 1.3 with `centerLabel: '4,5 km · 6 misiuni'`, there is no overflow (`tester.takeException()` is null).
  - `RouteTrail` with three sections, the last of them `finish`, finds three `WaypointDot`s, and the last has `kind == WaypointKind.finish`.

- [ ] **Step 2: Run** `flutter test test/ui/components/route_test.dart`. Expected: FAIL, because the widgets are not defined.

- [ ] **Step 3: Implement** the five widgets, one per file, with the layout above.

- [ ] **Step 4: Run the tests.** Expected: PASS.

- [ ] **Step 5: Commit** with the message "Add the route strip and route trail".

### Task 9: Sticky action bar (U1)

**Files:**
- Create in `lib/ui/components/buttons/`: `sticky_action_bar.dart`, `bar_tone.dart`
- Test: `test/ui/components/sticky_action_bar_test.dart`

**Interfaces:**
- Produces:
  - `enum BarTone { neutral, success, accent }`
  - `StickyActionBar({required String title, String? detail, bool inlineDetail = false, IconData? leadingIcon, BarTone tone = BarTone.neutral, bool highlighted = false, required String actionLabel, IconData? actionIcon, bool prominent = true, VoidCallback? onAction})`

Layout from mockup 01 (the bar and "Aceeași bară, în alte stări"):

- `panel` fill with a 1 px top `border`. When `highlighted`, the top border is `tick`. Padding 10 / 14 and a 10 px gap. Wrap it in `SafeArea(top: false)`.
- **Leading icon**, when set: 16 px. `success` → `colors.success`, `accent` → `colors.accent`, `neutral` → `colors.muted`.
- **Text:**
  - With `inlineDetail` false: `title` in `cardTitle`, with `detail` below it in `smallMuted`.
  - With `inlineDetail` true: one line, `title` in `cardTitle` followed by `' · $detail'` in `muted`, with ellipsis.
- **Action:**
  - `prominent`: a `navy` button, radius `AppRadius.button`, padding 10 / 14, `actionIcon` 15 plus `actionLabel` w500 in `onNavy`.
  - Not `prominent`: `actionLabel` as w500 `accent` text, still tappable with a 48 px tall hit area.

- [ ] **Step 1: Write the failing tests.**
  - The prominent bar shows `'Mai sunt 5 zile'`, `'12 echipe înscrise'` and `'Înscrie echipa'`, and a tap on the label calls `onAction`.
  - The inline variant shows `'Vulpile'` and `' · 4 membri'` on one line.
  - When `highlighted`, the top border is `tick`.
  - At width 320 and text scale 1.3 with a long title, there is no overflow.

- [ ] **Step 2: Run** `flutter test test/ui/components/sticky_action_bar_test.dart`. Expected: FAIL.
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run the tests.** Expected: PASS.
- [ ] **Step 5: Commit** with the message "Add the sticky action bar".

### Task 10: Component gallery and merge

**Files:**
- Create: `lib/dev/gallery_main.dart`, `lib/dev/component_gallery.dart`
- Modify: `docs/ui-and-theme.md` (new tokens, styles, event palette and components), `CLAUDE.md` (the theme line mentions `EventPalette` / `context.eventPalette`, and the gallery command)
- Test: `test/dev/component_gallery_test.dart`

**Interfaces:**
- Consumes: everything from Tasks 3–9.
- Produces: `void main()` in `gallery_main.dart`, which runs a `MaterialApp` with `AppTheme.light` / `dark`, a theme toggle in the app bar and `ComponentGallery` as home. It needs no Firebase.

Gallery content, in this order, using the copy from mockup 01:

1. `RouteStrip('4,5 km · 6 misiuni', 'Piața Mare', 'Turnul Sfatului', mapLabel: 'Hartă')`
2. `FactRow`, with `DateFactTile('14', 'nov · 10:00')` and the facts "2 h durată", "●●○ Medie dificultate" and "12 echipe"
3. A `RouteTrail` of three sections ("Povestea" with the story text, "Ce vă așteaptă" with the three chips, and "Organizator" as `finish`)
4. Chips in all three styles ("Toate" selected, "Luna asta", "Hartă" outlined)
5. All three `StickyActionBar` states from the mockup
6. A small parchment swatch row under an `EventThemeScope(parchment)`, showing the palette colours and one line in the voice font

- [ ] **Step 1: Write the failing test.** Pumping `ComponentGallery` under light and dark themes throws no exception, and finds the mockup copy `'Înscrie echipa'` and `'4,5 km · 6 misiuni'`.
- [ ] **Step 2: Run** `flutter test test/dev/`. Expected: FAIL.
- [ ] **Step 3: Implement** the gallery. Update the two docs.
- [ ] **Step 4: Verify everything.**
  - Run: `flutter analyze && flutter test`. Expected: no issues, all pass.
  - Then run `flutter run -t lib/dev/gallery_main.dart` on a device or emulator. Compare the screen with `docs/roadmap/mockups/01-event-details.html` in a browser, and note any mismatch for Victor.
- [ ] **Step 5: Commit** with the message "Add a component gallery to compare against the mockups".
- [ ] **Step 6: Merge.**
  - `git checkout redesign/mockups && git merge --no-ff redesign/step-1-foundations -m "Merge step 1: foundations into redesign/mockups"`, ending with the Co-Authored-By line.
  - Run `flutter test` again on `redesign/mockups`. Do not push.
