# UI redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Introduce a shared UI layer with light and dark themes, a labelled bottom navigation shell, and the redesigned Home screen, in small mergeable phases.

**Architecture:** A new `lib/ui/` folder holds theme tokens (a `ThemeExtension`), `ThemeData` builders, and reusable components. Existing `lib/widgets/` moves into it with no visual change first, new components are added and tested in isolation, then screens migrate onto the tokens batch by batch. Theme mode and Home hero selection are plain, unit-tested Dart (a `ThemeController` and a pure `resolveHomeHero` function) wired to the existing `provider` state.

**Tech Stack:** Flutter 3.41.9, Dart ^3.7.2, provider, flutter_svg, cached_network_image, **new:** shared_preferences. Font: Poppins (already bundled).

**Spec:** `docs/superpowers/specs/2026-10-19-ui-redesign-design.md`

## Global Constraints

- Font family is `Poppins` only; weights 400/500/600/700.
- Token hex values, radii and spacing are exactly those in the spec's Tokens table. No other colours in `lib/ui/`.
- Bottom bar is solid and full-width with four labelled tabs: `Acasă`, `Evenimente`, `Știri`, `Profil`.
- Romanian copy exactly as in the spec; sentence case; comma-below `ș ț`.
- Never `x!` in new code; use local variable promotion or a fallback (user convention). One widget per file; one `*Controller` per screen; screens stay thin.
- `Component`/`component_conversion` widgets are not themed.
- A phase merges to `main` only when: `flutter analyze` shows **0 errors and no more warnings than baseline (28)**, `flutter test` passes, and the manual smoke list for that phase passes on a device.
- Baseline before phase 1: `flutter analyze` = 0 errors, 28 warnings, 210 infos.

## Review Focus

Failure modes the spec implies but tasks could miss (each has a test in the owning task):
1. Event with `dateEvent == null` or an empty `landingImageUrl` on hero and poster cards: must render a fallback, never throw (Tasks 5, 12).
2. `SharedPreferences` read/write throws or returns garbage: theme falls back to light, app still starts (Task 8).
3. Event crosses the 3 h mark while Home is open: hero must switch away from Live without a manual refresh (Task 12).
4. Text scale 1.5 and long Romanian titles: hero, panel header and nav labels must not overflow (Tasks 3, 4, 6).
5. Android back button inside the tab shell: back on Evenimente/Știri/Profil returns to Acasă; back on Acasă exits; tab state is kept (Task 10).
6. User with no registrations and no future public events with open enrollment: Home shows the no-hero layout, not an error (Task 11).

---

## File Structure

```
lib/ui/
  ui.dart                      barrel export
  theme/
    app_colors.dart            ThemeExtension<AppColors> (light + dark)
    app_radius.dart
    app_spacing.dart
    app_theme.dart             AppTheme.light / AppTheme.dark (ThemeData)
    theme_context.dart         extension on BuildContext -> AppColors
    theme_mode_store.dart      interface + SharedPreferences impl
    theme_controller.dart      ChangeNotifier
  components/
    buttons/app_button.dart
    inputs/app_text_field.dart
    layout/section_card.dart
    feedback/status_pill.dart
    navigation/app_bottom_nav.dart, app_nav_item.dart
    event/hero_card_frame.dart, live_hero_card.dart, starting_soon_hero_card.dart,
          upcoming_hero_card.dart, recommended_hero_card.dart,
          countdown_tiles.dart, checklist_row.dart, poster_card.dart
lib/features/home/logic/home_hero.dart            sealed class + resolveHomeHero
lib/features/shell/screen/user_shell.dart         tab shell
lib/features/shell/controller/user_shell_controller.dart
lib/features/profile/screen/profile_screen.dart   + controller/
test/ui/..., test/features/home/home_hero_test.dart, test/theme/...
```

---

## Phase 0: Git housekeeping (branch `ui/00-housekeeping`, no app code)

### Task 1: Land pending work and clean branches

**Why first:** `features/chat_new_design` (4 commits ahead of `main`, 3 behind) already changes `lib/constants/colors.dart`, `lib/widgets/my_appbar.dart`, `home.dart`, `admin_home.dart`. Starting the refactor before it lands guarantees conflicts. `feature/geolocation-puzzle`, `feature/live-event-admin`, `features/upload-a-photo` and `chore/update-android-toolchain` have **0 commits ahead** of `main` (already merged).

- [ ] **Step 1:** Owner confirms which branch is the "current design" they run. Run `git log --oneline main..features/chat_new_design`; expected 4 commits (chat new design, photo approval tracking, topbar redesign, subtitle).
- [ ] **Step 2:** `git checkout features/chat_new_design && git merge main`; resolve conflicts (likely `colors.dart`, `my_appbar.dart`); run `flutter analyze` (0 errors) and smoke Home, chat, game on a device.
- [ ] **Step 3:** `git checkout main && git merge --no-ff features/chat_new_design`.
- [ ] **Step 4:** With owner approval, delete merged branches: `git branch -d feature/geolocation-puzzle feature/live-event-admin features/upload-a-photo chore/update-android-toolchain`.
- [ ] **Step 5:** Record baseline: `flutter analyze` counts into `docs/superpowers/plans/baseline.txt`; `git push origin main`.
- [ ] **Step 6:** Replace the broken template `test/widget_test.dart` with `test/smoke_test.dart` containing one passing test `'test harness runs'` (`expect(1 + 1, 2)`); commit `Replace template widget test`.

---

## Phase 1: Theme foundation (branch `ui/01-theme-foundation`, no visual change)

### Task 2: Tokens and ThemeData

**Files:** Create `lib/ui/theme/{app_colors,app_radius,app_spacing,app_theme,theme_context}.dart`, `lib/ui/ui.dart`; Modify `lib/main.dart:~120` (MaterialApp theme); Test `test/ui/theme/app_colors_test.dart`.

**Interfaces:**
- Produces: `class AppColors extends ThemeExtension<AppColors>` with `final Color page, panel, border, inset, insetBorder, text, muted, accent, tick, navy, navActivePill, iconButtonBg, live, soon;` `static const AppColors light`, `static const AppColors dark`; `LinearGradient get ctaGradient`; `abstract class AppRadius { static const double panel=20, hero=22, card=14, button=12, pill=99; }`; `abstract class AppSpacing { static const double panelMargin=14, panelPadding=12, gap=12; }`; `extension AppThemeContext on BuildContext { AppColors get colors; }` returning `Theme.of(this).extension<AppColors>() ?? AppColors.light`; `abstract class AppTheme { static ThemeData get light; static ThemeData get dark; }`.

- [ ] **Step 1: Write failing test** `light tokens match spec`: `expect(AppColors.light.page, const Color(0xFFE7ECF3))`, `panel 0xFFFFFFFF`, `text 0xFF0C092A`, `accent 0xFF1B8A8E`; `dark tokens match spec`: `page 0xFF0E1116`, `panel 0xFF171B22`, `accent 0xFF5CC8CB`; `lerp at 0 returns this, at 1 returns other`.
- [ ] **Step 2:** Run `flutter test test/ui/theme/app_colors_test.dart`; expect FAIL (file missing).
- [ ] **Step 3:** Implement the classes. `AppTheme.light/dark`: `useMaterial3: true`, `fontFamily: 'Poppins'`, `scaffoldBackgroundColor: page`, `extensions: [AppColors.x]`, `brightness` set. Use the spec Tokens table verbatim.
- [ ] **Step 4:** In `main.dart` set `theme: AppTheme.light, darkTheme: AppTheme.dark, themeMode: ThemeMode.light` (visually identical to today: only `scaffoldBackgroundColor`/`canvasColor` stay white until Phase 4, so pass `AppTheme.light.copyWith(scaffoldBackgroundColor: Colors.white)` for this phase only).
- [ ] **Step 5:** Run tests (PASS), `flutter analyze` (no new warnings), smoke Home + login (look unchanged). Commit `Add UI tokens and theme builders`.

### Task 3: Move shared widgets under `lib/ui/components`, no behaviour change

**Files:** `git mv` per row; update imports; add `lib/ui/ui.dart` exports.
| From | To |
|---|---|
| `lib/widgets/my_button.dart` | `lib/ui/components/buttons/my_button.dart` |
| `lib/widgets/my_text_field.dart` | `lib/ui/components/inputs/my_text_field.dart` |
| `lib/widgets/my_dropdown/` | `lib/ui/components/inputs/my_dropdown/` |
| `lib/widgets/my_appbar.dart`, `menu.dart` | `lib/ui/components/navigation/` |
| `lib/widgets/event_card/`, `registered_events/`, `stire_card/`, `EventImage.dart`, `misison_state_widget.dart`, `StepRegisterIcon.dart`, `CustomIconDashboard.dart`, `slider_widget.dart`, `terms_text.dart`, `color_picker_dialog.dart` | `lib/ui/components/event/`, `.../news/`, `.../misc/` (group by responsibility) |
| `lib/utils/snackbars.dart` | `lib/ui/components/feedback/snackbars.dart` |

- [ ] **Step 1:** One commit per group with `git mv` only plus import fixes (`dart fix --apply` is not allowed to reformat). Rename files to snake_case (`EventImage.dart` → `event_image.dart`, `CustomIconDashboard.dart` → `custom_icon_dashboard.dart`).
- [ ] **Step 2:** After each group: `flutter analyze` must report 0 errors.
- [ ] **Step 3:** Final: `flutter analyze` warnings ≤ 28; smoke the screens that use moved widgets (Home, dashboards, register team, news). Empty `lib/widgets/` deleted. Update `CLAUDE.md` and `docs/ui-and-theme.md` paths. Commit `Move shared widgets into lib/ui/components`.

**Merge:** `git checkout main && git merge --no-ff ui/01-theme-foundation`, tag `ui-phase-1`, push.

---

## Phase 2: New components (branch `ui/02-new-components`, built and tested, used nowhere yet)

All tests use a helper `test/ui/pump_ui.dart`: `Future<void> pumpUi(WidgetTester t, Widget child, {ThemeData? theme, double textScale = 1})` wrapping `MaterialApp(theme: theme ?? AppTheme.light, home: Scaffold(body: child))` with `MediaQuery` text scale.

### Task 4: AppButton

**Files:** Create `lib/ui/components/buttons/app_button.dart`; Test `test/ui/components/app_button_test.dart`.
**Produces:** `enum AppButtonVariant { primary, secondary, ghost }`; `class AppButton extends StatelessWidget { const AppButton({super.key, required this.label, required this.onPressed, this.variant = AppButtonVariant.primary, this.leading, this.isLoading = false, this.expand = true}) }` where `final VoidCallback? onPressed; final Widget? leading;`.

- [ ] **Step 1: Write failing tests:** `calls onPressed when tapped`; `does not call onPressed when isLoading` (also finds a `CircularProgressIndicator`); `does not call onPressed when onPressed is null` and renders muted background; `shows label text`; `has 44dp minimum height`; `label does not overflow at text scale 1.5` (no exception in `tester.takeException()`).
- [ ] **Step 2:** Run; FAIL.
- [ ] **Step 3:** Implement with `Material` + `InkWell` (ripple), gradient decoration for primary (`AppColors.ctaGradient`), 1px `border`-coloured outline for secondary, no fill for ghost; radius `AppRadius.button`; semantics `button: true`.
- [ ] **Step 4:** Run; PASS. Commit `Add AppButton`.

### Task 5: AppTextField

**Files:** `lib/ui/components/inputs/app_text_field.dart`; Test `test/ui/components/app_text_field_test.dart`.
**Produces:** `AppTextField({super.key, this.controller, required this.label, this.hint, this.helper, this.required = false, this.validator, this.obscure = false, this.keyboardType, this.maxLines = 1, this.readOnly = false, this.onTap, this.leading, this.trailing, this.inputFormatters, this.textInputAction, this.onChanged})`.

- [ ] **Step 1: Failing tests:** `shows label and a red asterisk when required`; `shows helper text when no error`; `shows validator message with an alert icon after validate()` (wrap in `Form`, call `validate()`); `obscure field toggles visibility via eye icon`; `readOnly field calls onTap`; `multiline uses 14 radius`; `does not auto-generate a validator message when validator is null` (validate() returns true with empty text).
- [ ] **Step 2:** FAIL. **Step 3:** Implement on `TextFormField` with `InputDecoration` from tokens: border 1px `border`, focus border 2px `tick` + 4px soft ring via decoration `focusedBorder`, error border `live`. **Step 4:** PASS. Commit `Add AppTextField`.

### Task 6: SectionCard, StatusPill, AppBottomNav

**Files:** `layout/section_card.dart`, `feedback/status_pill.dart`, `navigation/app_bottom_nav.dart`, `navigation/app_nav_item.dart`; Tests in `test/ui/components/`.
**Produces:**
- `SectionCard({super.key, required this.title, required this.child, this.count, this.tickColor, this.actionLabel, this.onAction})` (action link only when `onAction != null`; default `actionLabel = 'Vezi toate'`).
- `enum StatusPillKind { live, soon, info }`; `StatusPill({super.key, required this.label, this.kind = StatusPillKind.info, this.icon})`.
- `class AppNavItem { const AppNavItem({required this.icon, required this.label, this.showBadge = false}); }`; `AppBottomNav({super.key, required this.currentIndex, required this.onSelected, required this.items})` (4 items max assert).

- [ ] **Step 1: Failing tests:** SectionCard `shows title, count badge text, and action link that fires onAction`; `hides the link when onAction is null`; `title ellipsizes at text scale 1.5`. StatusPill `live kind uses live colour background`; AppBottomNav `tapping an item calls onSelected with its index`; `active item has the active pill`; `badge dot shown only when showBadge`; `labels remain visible at text scale 1.5 without overflow`.
- [ ] **Step 2:** FAIL. **Step 3:** Implement (panel: `Container` with `panel` fill, 1px `border`, `AppRadius.panel`, 12 padding; nav: `SafeArea` bottom, 68dp tall, top border). **Step 4:** PASS. Commit per widget group.

### Task 7: Event cards: hero frame, variants, countdown, checklist, poster

**Files:** `event/hero_card_frame.dart`, `live_hero_card.dart`, `starting_soon_hero_card.dart`, `upcoming_hero_card.dart`, `recommended_hero_card.dart`, `countdown_tiles.dart`, `checklist_row.dart`, `poster_card.dart`; Tests `test/ui/components/event_cards_test.dart`.
**Produces:**
- `HeroCardFrame({super.key, required this.child, this.imageUrl})`: cover image (cached network) under a scrim gradient `transparent → #0C092A @ 0.92`; if `imageUrl` is null/empty or fails to load, paints a solid `navy` fallback (no asset dependency).
- `LiveHeroCard({required String title, required String subtitle, required Duration remaining, required int missionsDone, required int missionsTotal, String? imageUrl, required VoidCallback onContinue, required VoidCallback onChat})`.
- `StartingSoonHeroCard({required String title, required String subtitle, required int minutesLeftToEnter, String? imageUrl, required VoidCallback onEnterCode})`.
- `UpcomingHeroCard({required String title, required String placeAndTime, required Duration untilStart, String? imageUrl, required VoidCallback onDetails, required VoidCallback onShare})`.
- `RecommendedHeroCard({required String title, required String facts, String? imageUrl, required VoidCallback onRegister})`.
- `CountdownTiles({required Duration remaining})` showing `zile`, `ore`, `min` (zero-padded two digits).
- `ChecklistRow({required String title, required String subtitle, required bool done})`; `PosterCard({required String title, required String dateLabel, required String place, String? imageUrl, VoidCallback? onTap})`.
- Remaining time format helper: `String formatRemaining(Duration d)` → `h:mm:ss` (`2:14:09`), negative clamps to `0:00:00`.

- [ ] **Step 1: Failing tests:** `formatRemaining(Duration(hours:2,minutes:14,seconds:9)) == '2:14:09'`; `formatRemaining(Duration(seconds:-5)) == '0:00:00'`; `CountdownTiles(Duration(days:3,hours:14,minutes:22))` shows `03`,`14`,`22`; `LiveHeroCard` shows `LIVE`, `Continuă jocul`, taps fire `onContinue`/`onChat`, renders 5 progress segments with 1 done for `missionsDone:1, missionsTotal:5`; `StartingSoonHeroCard` shows `Mai ai 47 min să intri` for 47; `RecommendedHeroCard` shows `Înscrie-ți echipa`; every card pumps with `imageUrl: null` and `imageUrl: ''` without exceptions (Review Focus 1); `LiveHeroCard` at text scale 1.5 has no overflow (Review Focus 4).
- [ ] **Step 2:** FAIL. **Step 3:** Implement; no Firebase imports in `lib/ui`. **Step 4:** PASS. Commit `Add event hero cards and related components`.

**Merge:** analyze/tests/smoke (nothing visible changed), `--no-ff` merge, tag `ui-phase-2`, push.

---

## Phase 3: Migrate screens onto tokens (branches `ui/03a-auth`, `03b-player`, `03c-admin`)

**Scope measured:** 568 `Colors.*` uses in 89 files, 76 `Color(0x…)` in 29 files, 79 `fontFamily: 'Poppins'` strings, 176 raw `TextStyle(`, 38 `Scaffold(`. Heaviest files: `stiri_dashboard_screen.dart`, `news_screen.dart`, both events dashboards, `create_news_screen.dart`, `register_team_screen.dart`, `calendar_screen.dart`, `my_dropdown.dart`, `snackbars.dart`.

### Task 8: Make MyButton and MyTextField thin wrappers

- [ ] **Step 1: Failing tests:** `MyButton(buttonText:'x', buttonOnTap: f)` renders an `AppButton`; `MyTextField` with `validator: null` no longer injects the "Introdu …" message **only** when `required: false` (new param, default `true` to preserve today's behaviour for the 48 existing call sites).
- [ ] **Step 2:** FAIL. **Step 3:** Re-implement the two classes with their current public signatures delegating to `AppButton`/`AppTextField`; mark with `@Deprecated('Use AppButton')` only in Phase 5. **Step 4:** PASS; smoke login, register team, create event. Commit.

### Task 9: Replace hardcoded colours per feature folder

For each batch below, per file: replace `Colors.white`/`Color(0x…)`/`MyColors.*` with `context.colors.<token>`, `fontFamily: 'Poppins'` is dropped (theme provides it), `Scaffold` background from theme. **Do not** touch `lib/utils/component_conversion/`, `lib/model/`, or colours the admin picks for puzzles.

- [ ] **Batch 3a (auth):** `splash`, `log-in`, `sign-up`, `forgot-password`, `loader_page`.
- [ ] **Batch 3b (player):** `home`, `events_dashboard/events_dashboard_user`, `event_details`, `register_team`, `team_details`, `enter_code`, `event_game` (screen chrome only), `calendar`, `map`, `news_dashboard`, `news_details`, `filter/*`, `chat`.
- [ ] **Batch 3c (admin):** `admin/*`, `events_dashboard/events_dashboard_admin`, `event_management`, `event_see_registered_teams`, `team_chats`, `notification`, `news_category_manipulation`.
- [ ] **Per batch verification:** `flutter analyze` ≤ baseline; `grep -rn "Colors\.white\|Color(0x" <batch folders>` returns only allowed exceptions listed in the commit message; smoke every screen in the batch in light mode and compare with before (screenshots).
- [ ] **Step (after 3c):** switch `main.dart` to `scaffoldBackgroundColor: page` (remove the Phase 1 override). Commit `Use themed page background`.

**Merge each batch separately** (`--no-ff`, tag `ui-phase-3a/b/c`, push).

---

## Phase 4: Dark mode logic (branch `ui/04-dark-mode`)

### Task 10: ThemeController and persistence

**Files:** `pubspec.yaml` (+ `shared_preferences`), `lib/ui/theme/theme_mode_store.dart`, `lib/ui/theme/theme_controller.dart`, `lib/main.dart`; Test `test/theme/theme_controller_test.dart`.
**Produces:** `abstract class ThemeModeStore { Future<ThemeMode?> read(); Future<void> write(ThemeMode mode); }`; `class SharedPrefsThemeModeStore implements ThemeModeStore`; `class ThemeController extends ChangeNotifier { ThemeController(this._store); ThemeMode get mode; Future<void> load(); Future<void> setMode(ThemeMode mode); }` default `ThemeMode.light`.

- [ ] **Step 1: Failing tests** with a fake store: `defaults to light before load`; `load restores stored dark`; `setMode persists and notifies once`; `load keeps light when store returns null`; `load keeps light when store throws`; `setMode still updates the in-memory mode when write throws` (Review Focus 2).
- [ ] **Step 2:** FAIL. **Step 3:** Implement; wrap store calls in try/catch. Register `ChangeNotifierProvider<ThemeController>` in `main.dart` and bind `themeMode: controller.mode` via `Consumer`; call `load()` before `runApp`.
- [ ] **Step 4:** PASS; commit `Add ThemeController with persistence`.

### Task 11: Dark pass over all screens and Settings toggle

- [ ] **Step 1:** In the (future) Profil screen task a `SegmentedButton<ThemeMode>` with `Sistem / Luminos / Întunecat`. Until the shell exists, put a temporary toggle on the user Home app bar menu.
- [ ] **Step 2:** Walk every screen in dark: fix leftover white patches (grep `Colors.white` again), tint SVG icons via `ColorFilter.mode(context.colors.text, BlendMode.srcIn)` for single-colour icons, status bar icon brightness via `AnnotatedRegion<SystemUiOverlayStyle>`.
- [ ] **Step 3:** Map screen keeps OSM light tiles (documented limitation). Game screens render admin colours unchanged.
- [ ] **Step 4:** `flutter analyze`, smoke all in both modes; commit; merge, tag `ui-phase-4`.

---

## Phase 5: Navigation shell (branch `ui/05-nav-shell`)

### Task 12: UserShell with four tabs

**Files:** `lib/features/shell/screen/user_shell.dart`, `controller/user_shell_controller.dart`, `lib/features/profile/screen/profile_screen.dart` (+ `controller/`), `lib/constants/routes.dart` (`Routes.home` now points at the shell), `lib/main.dart`; Modify `events_dashboard_user/screen/events_dashboard_screen.dart` and `news_dashboard/screen/stiri_dashboard_screen.dart` to read their lists from `EventList`/`NewsList` instead of route arguments (the shell has none); Test `test/features/shell/user_shell_test.dart`.
**Produces:** `class UserShellController extends ChangeNotifier { int get index; void select(int i); bool handleBack(); }` where `handleBack()` returns `true` when it consumed the back press (index ≠ 0 → select 0).

- [ ] **Step 1: Failing tests (controller):** `starts at 0`; `select changes index and notifies`; `handleBack from tab 2 selects 0 and returns true`; `handleBack at 0 returns false`; `select out of range is ignored`. Widget test with stub tab bodies: `tapping Evenimente shows the second body and keeps the first body state alive` (IndexedStack with a counter) (Review Focus 5).
- [ ] **Step 2:** FAIL. **Step 3:** Implement with `IndexedStack` (note commit `de1ca5a` fixed an IndexedStack crash in `mission_widget.dart`; verify no nested-key collisions) and `PopScope(canPop: false)` delegating to `handleBack`. `AppBottomNav` shows the red badge dot on Evenimente when a hero is live (wired in Phase 6). Profil: user name, email, theme toggle (`Sistem/Luminos/Întunecat`), `Deconectare` (existing `HomeController.logout` logic).
- [ ] **Step 4:** PASS; smoke on device including the Android back gesture. Commit; merge; tag `ui-phase-5`.

---

## Phase 6: Home redesign and logic (branch `ui/06-home`)

### Task 13: resolveHomeHero (pure logic)

**Files:** `lib/features/home/logic/home_hero.dart`; Test `test/features/home/home_hero_test.dart`.
**Produces:**
```dart
sealed class HomeHero {}
class LiveHero extends HomeHero { LiveHero(this.event, this.team); final Event event; final Team team; }
class StartingSoonHero extends HomeHero { StartingSoonHero(this.event, this.minutesLeftToEnter); final Event event; final int minutesLeftToEnter; }
class UpcomingHero extends HomeHero { UpcomingHero(this.event, this.untilStart); final Event event; final Duration untilStart; }
class RecommendedHero extends HomeHero { RecommendedHero(this.event); final Event event; }
class NoHero extends HomeHero { const NoHero(); }

HomeHero resolveHomeHero({
  required DateTime now,
  required Event? activeEvent, required Team? activeTeam,   // from UserEventsProvider
  required Event? startedRecently, required Team? startedRecentlyTeam,
  required List<Event> registeredUpcoming,
  required List<Event> allEvents, required Set<String> registeredIds,
});
```
Rules (priority): Live (activeEvent+activeTeam non-null, team `hasStarted && !hasFinished`, `!event.isOver`) → StartingSoon (`startedRecently` started ≤ 60 min ago, `!isOver`, team null or `!hasStarted`; `minutesLeftToEnter = 60 − minutes since start`, min 0) → Upcoming (nearest `registeredUpcoming` with `dateEvent` after `now`) → Recommended (earliest future `EventType.PUBLIC` event not in `registeredIds` with `dateStartEnrollment <= now <= dateDeadlineEnrollment`) → NoHero.

- [ ] **Step 1: Failing tests** (build events with a test helper): `live wins over everything`; `stopped event is never live`; `event past 3h is never live (isOver)` (Review Focus 3); `started 10 minutes ago, team not started → StartingSoon(50)`; `started 61 minutes ago, team not started → falls through`; `registered future events → nearest is Upcoming with correct untilStart`; `no registrations → Recommended picks earliest public open-enrollment event`; `private event is never recommended`; `closed enrollment is skipped`; `already registered event is skipped`; `event with null dateEvent is ignored everywhere`; `nothing available → NoHero` (Review Focus 6).
- [ ] **Step 2:** FAIL. **Step 3:** Implement as a pure function (no Flutter imports besides models). **Step 4:** PASS. Commit `Add Home hero resolver`.

### Task 14: Home screen on new components

**Files:** Modify `lib/features/home/screen/home.dart`, `controller/home_controller.dart`; Create `lib/features/home/widgets/home_hero_section.dart`, `preparation_panel.dart`, `how_it_works_panel.dart`; Test `test/features/home/home_hero_section_test.dart`.
**Interfaces:** `HomeHeroSection({required HomeHero hero, required HomeController controller})` returns the matching hero card or `SizedBox.shrink()` for `NoHero`. Preparation checklist rule (pure, in `home_hero.dart`): `List<PreparationStep> preparationSteps(Event event, Team? team, DateTime now)` → `[Înscriere confirmată: team != null; Detalii echipă complete: name, captainName, phoneNumber, captainEmail all non-empty; Codul de start: done when now >= event day start]`.

- [ ] **Step 1: Failing tests:** `preparationSteps` returns 2 done + 1 pending for a complete team before the event day; widget test `HomeHeroSection(LiveHero)` shows `Continuă jocul`; `NoHero` renders nothing; refresh timer test: with `fakeAsync`, a `LiveHero` built 1 s before the 3 h mark re-resolves to non-live after 2 s (`HomeController` owns a 30 s `Timer.periodic` that calls `notifyListeners`) (Review Focus 3).
- [ ] **Step 2:** FAIL. **Step 3:** Wire `Consumer3<EventList, NewsList, UserEventsProvider>` through `resolveHomeHero`; panels: Înscrierile tale, Pregătirea echipei (upcoming only), Cum funcționează (recommended only), Evenimente (posters), Noutăți. Event image from `landingImageUrl`; recommended facts line: `'<d MMM> · <lungimeTraseu> · <n> echipe'` where the team count is one `TeamService.getTeams` call for that single event.
- [ ] **Step 4:** PASS; smoke the five states by editing event dates in a test project. Commit; merge; tag `ui-phase-6`; push.

---

## Phase 7: Cleanup (branch `ui/07-cleanup`)

- [ ] Remove `MyButton`/`MyTextField` shims and `MyColors`/`MyPaddings` once `grep` shows no uses; migrate stragglers.
- [ ] Update `CLAUDE.md`, `docs/ui-and-theme.md`, `docs/screens.md`, `docs/known-issues.md` (remove resolved items).
- [ ] Final `flutter analyze` ≤ baseline; `flutter test` green; merge; tag `ui-v1`.

## Follow-up plans (not in this plan)
Event details, game mission list, register-team steps, auth screens and the admin home each get their own plan after Phase 6. Separately: enforce the enrollment window on the register button, add `Event.maxTeams`, safe package bumps (`chore/deps-safe-bumps`), then the major Firebase upgrades one family at a time.

## Git workflow (applies to every phase)

1. `git checkout main && git pull`, then `git checkout -b ui/0N-name`.
2. One commit per task; messages are short sentences in the style of the repo history.
3. Never commit to `main` directly. Merge with `git merge --no-ff ui/0N-name` so each phase is one revertable merge commit; tag `ui-phase-N`; push main and tags.
4. Rollback of a phase: `git revert -m 1 <merge-commit>`.
5. Phases are merged sequentially (no stacked branches). Any other feature branch must merge `main` before continuing, to avoid drift in `lib/widgets/` paths after Phase 1.
6. Hard dependencies: Phase 3 needs 1–2; Phase 4 needs 3; Phase 5 needs 2 (and 4 for the theme toggle on Profil); Phase 6 needs 2, 3b, 5.

## Self-review notes
- Spec coverage: tokens (Task 2), components (Tasks 4–7), dark mode (Tasks 10–11), nav shell (Task 12), Home states 1–5 (Tasks 13–14), copy strings (Tasks 4, 7, 12, 14). Out-of-scope items are listed.
- Type names are consistent across tasks (`AppColors`, `AppButton`, `HomeHero`, `UserShellController`).
- One open risk: Task 14's recommended-hero team count adds one Firestore read per Home load; acceptable for a single event, cache it in `HomeController` if it shows up in profiling.
