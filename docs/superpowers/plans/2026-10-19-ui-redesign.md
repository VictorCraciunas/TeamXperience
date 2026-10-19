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
- UI elements are shared by player and admin screens. `lib/ui/` is role-neutral: components receive content via parameters (no role-specific copy or logic inside them); `lib/features/<area>/` maps domain objects to component parameters. Admin Home has no approved design yet (spec section "Admin Home"); no shared component may assume a player.
- A phase merges to `main` only when: `flutter analyze` shows **0 errors and no more warnings than baseline (25)**, `flutter test` passes, and the manual smoke list for that phase passes on a device.
- Baseline before phase 1: `flutter analyze` = 0 errors, 25 warnings, 192 infos (see `baseline.txt`; it dropped from 28 after merging `chat_new_design`).

## Review Focus

Failure modes the spec implies but tasks could miss (each has a test in the owning task):
1. Event with `dateEvent == null` or an empty `landingImageUrl` on hero and poster cards: must render a fallback, never throw (Tasks 5, 12).
2. `SharedPreferences` read/write throws or returns garbage: theme falls back to light, app still starts (Task 8).
3. Event crosses the 3 h mark while Home is open: hero must switch away from Live without a manual refresh (Task 12).
4. Text scale 1.5 and long Romanian titles: hero, panel header and nav labels must not overflow (Tasks 3, 4, 6).
5. Android back button inside the tab shell: back on Evenimente/Știri/Profil returns to Acasă; back on Acasă exits; tab state is kept (Task 10).
6. User with no registrations and no future public events with open enrollment: Home shows the no-hero layout, not an error (Task 14).
7. Admin account after the player shell lands: login still reaches the existing admin Home (`Routes.adminHome` untouched until Phase 8), it is themed, dark mode works, and the theme toggle is reachable from the admin app bar menu (Tasks 11, 12).
8. Shared components used by both roles (`EventHeroCard`, `StatTile`, `ActionTile`, `AppShell`) work with admin-style content as well as player content: long event names, zero counts, no image, no progress, no countdown (Tasks 7, 12).

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
    layout/stat_tile.dart, action_tile.dart
    navigation/app_bottom_nav.dart, app_nav_item.dart, app_shell.dart, shell_controller.dart
    event/hero_card_frame.dart, event_hero_card.dart, countdown_tiles.dart, checklist_row.dart,
          poster_card.dart, format_remaining.dart
lib/features/home/logic/home_hero.dart            sealed class + resolveHomeHero (player)
lib/features/home/widgets/                        home_hero_section.dart (HomeHero -> EventHeroCard), preparation_panel.dart, how_it_works_panel.dart
lib/features/shell/screen/user_shell.dart         AppShell with the 4 player tabs
lib/features/profile/screen/profile_screen.dart   + controller/ (role-aware: logout + theme toggle)
(Phase 8) lib/features/admin/home/logic/admin_hero.dart, lib/features/admin/home/widgets/admin_hero_section.dart (AdminHero -> EventHeroCard), lib/features/admin/shell/screen/admin_shell.dart
test/ui/..., test/features/home/..., test/theme/...
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

### Task 7: Generic event/overview components

**Files:** `lib/ui/components/event/{hero_card_frame,event_hero_card,hero_action,countdown_tiles,checklist_row,poster_card,format_remaining}.dart`, `lib/ui/components/layout/{stat_tile,action_tile}.dart`; Test `test/ui/components/overview_components_test.dart`.
**Produces (all role-neutral, no Firebase imports):**
- `HeroCardFrame({super.key, required this.child, this.imageUrl})`: cover image (cached network) under a scrim gradient `transparent -> #0C092A @ 0.92`; if `imageUrl` is null/empty or fails to load, paints a solid `navy` fallback (no asset dependency).
- `enum HeroStatus { live, soon, upcoming, recommended }` (drives the pill colour: live = red `live`, soon = amber `soon`, upcoming/recommended = teal `tick`); `class HeroAction { const HeroAction({required this.label, required this.onTap, this.icon}); final String label; final VoidCallback onTap; final IconData? icon; }`.
- `EventHeroCard({super.key, required this.status, required this.statusLabel, required this.title, this.subtitle, this.timeChip, this.imageUrl, this.progressDone, this.progressTotal, this.countdown, required this.primary, this.secondaryIcon, this.onSecondary})`: one configurable hero for every state and both roles. `timeChip` (e.g. `2:14:09 rămase`, `Mai ai 47 min să intri`) shows top right; segmented progress renders only when `progressTotal` is non-null; `CountdownTiles` render only when `countdown` is non-null; the secondary icon button renders only when both `secondaryIcon` and `onSecondary` are set. All texts come from the caller.
- `CountdownTiles({required Duration remaining})` showing `zile`, `ore`, `min` (zero-padded two digits).
- `ChecklistRow({required String title, required String subtitle, required bool done})`.
- `PosterCard({required String title, required String dateLabel, required String place, String? imageUrl, VoidCallback? onTap})`.
- `StatTile({required String label, required String value, IconData? icon})` and `ActionTile({required IconData icon, required String label, required VoidCallback onTap})` (admin Home needs team/person counts and quick actions; player Home may use them too).
- `String formatRemaining(Duration d)` -> `h:mm:ss` (`2:14:09`), negative clamps to `0:00:00`.

- [ ] **Step 1: Failing tests:** `formatRemaining(Duration(hours:2,minutes:14,seconds:9)) == '2:14:09'`; `formatRemaining(Duration(seconds:-5)) == '0:00:00'`; `CountdownTiles(Duration(days:3,hours:14,minutes:22))` shows `03`,`14`,`22`; `HeroCardFrame` pumps with `imageUrl: null` and `imageUrl: ''` showing its child and no exception (Review Focus 1); `PosterCard` pumps with a null image and a 60-character title at text scale 1.5 without overflow (Review Focus 4, 8); `StatTile(label:'Echipe', value:'0')` shows both texts; `ActionTile` fires `onTap`; `ChecklistRow(done:true)` shows a check icon, `done:false` a lock icon; `EventHeroCard`: shows `statusLabel`, `title`, `subtitle` and `timeChip` as passed; tapping the primary action fires its `onTap`; with `progressTotal:5, progressDone:1` renders 5 segments of which 1 is filled; without `progressTotal` renders no segments; with `countdown` shows the tiles, without it none; the secondary button appears only when both its fields are set and fires `onSecondary`; pumps with `imageUrl: null`/`''`, no subtitle and a 60-character title at text scale 1.5 without overflow (Review Focus 1, 4, 8).
- [ ] **Step 2:** FAIL. **Step 3:** Implement. **Step 4:** PASS. Commit `Add generic overview components`.

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

- [ ] **Step 1:** In the (future) Profil screen task a `SegmentedButton<ThemeMode>` with `Sistem / Luminos / Întunecat`. Until the shells exist, put a temporary toggle on the user Home app bar menu **and** the admin Home app bar menu (admins get no Profil tab until Phase 8).
- [ ] **Step 2:** Walk every screen in dark: fix leftover white patches (grep `Colors.white` again), tint SVG icons via `ColorFilter.mode(context.colors.text, BlendMode.srcIn)` for single-colour icons, status bar icon brightness via `AnnotatedRegion<SystemUiOverlayStyle>`.
- [ ] **Step 3:** Map screen keeps OSM light tiles (documented limitation). Game screens render admin colours unchanged.
- [ ] **Step 4:** `flutter analyze`, smoke all in both modes; commit; merge, tag `ui-phase-4`.

---

## Phase 5: Navigation shell (branch `ui/05-nav-shell`)

### Task 12: Generic AppShell and the player tab shell

**Files:** `lib/ui/components/navigation/{app_shell,shell_controller}.dart`, `lib/features/shell/screen/user_shell.dart`, `lib/features/profile/screen/profile_screen.dart` (+ `controller/`), `lib/constants/routes.dart` (`Routes.home` now points at `UserShell`; `Routes.adminHome` is **unchanged**), `lib/main.dart`; Modify `events_dashboard_user/screen/events_dashboard_screen.dart` and `news_dashboard/screen/stiri_dashboard_screen.dart` to read their lists from `EventList`/`NewsList` instead of route arguments (the shell has none); Tests `test/ui/components/shell_controller_test.dart`, `test/ui/components/app_shell_test.dart`.
**Produces (role-neutral, reusable by the admin shell in Phase 8):**
- `class ShellController extends ChangeNotifier { ShellController(this.tabCount); final int tabCount; int get index; void select(int i); bool handleBack(); }` where `handleBack()` returns `true` when it consumed the back press (index != 0 -> select 0).
- `class AppShellTab { const AppShellTab({required this.item, required this.builder}); final AppNavItem item; final WidgetBuilder builder; }`
- `AppShell({super.key, required List<AppShellTab> tabs, ShellController? controller})`: `IndexedStack` of the tab bodies + `AppBottomNav` + `PopScope(canPop: false)` delegating to `handleBack`.
- `UserShell` = `AppShell` with tabs Acasă (`Home`), Evenimente (user events dashboard), Știri (news dashboard), Profil (`ProfileScreen`). Badge dot on Evenimente when a hero is live (wired in Task 14).

- [ ] **Step 1: Failing tests (controller):** `starts at 0`; `select changes index and notifies`; `handleBack from tab 2 selects 0 and returns true`; `handleBack at 0 returns false`; `select out of range is ignored`. Widget test with stub tab bodies (including a 2-tab shell, proving it is not hard-wired to 4): `tapping the second tab shows its body and keeps the first body's state alive` (IndexedStack with a counter) (Review Focus 5).
- [ ] **Step 2:** FAIL. **Step 3:** Implement (note commit `de1ca5a` fixed an IndexedStack crash in `mission_widget.dart`; verify no nested-key collisions). Profil: user name, email, theme toggle (`Sistem/Luminos/Întunecat`), `Deconectare` (existing `HomeController.logout` logic; role-aware so the admin shell can reuse it).
- [ ] **Step 4:** PASS; smoke on device including the Android back gesture, and log in as an admin to confirm the old admin Home still opens (Review Focus 7). Commit; merge; tag `ui-phase-5`.

---

## Phase 6: Player Home redesign and logic (branch `ui/06-home`)

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

**Files:** Modify `lib/features/home/screen/home.dart`, `controller/home_controller.dart`; Create in `lib/features/home/widgets/`: `home_hero_section.dart`, `preparation_panel.dart`, `how_it_works_panel.dart`; Tests `test/features/home/home_hero_section_test.dart`, `test/features/home/preparation_steps_test.dart`. The hero itself is the shared `EventHeroCard` from Task 7; this task only maps `HomeHero` to its parameters.
**Interfaces:** `HomeHeroSection({required HomeHero hero, required HomeController controller})` returns an `EventHeroCard` configured per state or `SizedBox.shrink()` for `NoHero`. Mapping (copy as in the spec): `LiveHero` -> `status: live`, `statusLabel: 'LIVE'`, `timeChip: '<formatRemaining> rămase'`, `progressDone/Total` from the team's `missionProgress` and `event.nrMissions`, `primary: 'Continuă jocul'`, secondary chat icon; `StartingSoonHero` -> `status: soon`, `'A început'`, `timeChip: 'Mai ai N min să intri'`, `primary: 'Introdu codul de start'`; `UpcomingHero` -> `status: upcoming`, `'Următorul eveniment'`, `countdown: untilStart`, `primary: 'Detalii înscriere'`, secondary share icon; `RecommendedHero` -> `status: recommended`, `'Recomandat pentru tine'`, `primary: 'Înscrie-ți echipa'`. Preparation checklist rule (pure, in `home_hero.dart`): `List<PreparationStep> preparationSteps(Event event, Team? team, DateTime now)` → `[Înscriere confirmată: team != null; Detalii echipă complete: name, captainName, phoneNumber, captainEmail all non-empty; Codul de start: done when now >= event day start]`.

- [ ] **Step 1: Failing tests:** `HomeHeroSection(LiveHero)` shows `LIVE` and `Continuă jocul` and 5 progress segments with 1 done for `missionProgress: 1, nrMissions: 5`; `StartingSoonHero(47)` shows `Mai ai 47 min să intri` and `Introdu codul de start`; `UpcomingHero` shows the countdown tiles and `Detalii înscriere`; `RecommendedHero` shows `Înscrie-ți echipa`; an event with an empty `landingImageUrl` renders without exception (Review Focus 1); `preparationSteps` returns 2 done + 1 pending for a complete team before the event day; `NoHero` renders nothing; refresh timer test: with `fakeAsync`, a `LiveHero` built 1 s before the 3 h mark re-resolves to non-live after 2 s (`HomeController` owns a 30 s `Timer.periodic` that calls `notifyListeners`) (Review Focus 3).
- [ ] **Step 2:** FAIL. **Step 3:** Wire `Consumer3<EventList, NewsList, UserEventsProvider>` through `resolveHomeHero`; panels: Înscrierile tale, Pregătirea echipei (upcoming only), Cum funcționează (recommended only), Evenimente (posters), Noutăți. Event image from `landingImageUrl`; recommended facts line: `'<d MMM> · <lungimeTraseu> · <n> echipe'` where the team count is one `TeamService.getTeams` call for that single event.
- [ ] **Step 4:** PASS; smoke the five states by editing event dates in a test project. Commit; merge; tag `ui-phase-6`; push.

---

## Phase 7: Admin Home design (no app code; branch `docs/admin-home-design`)

The approved mockups only cover the player Home. This phase produces the admin equivalent before any admin code is written.

### Task 15: Admin Home mockup and spec addendum

- [x] **Step 1:** Collect the real admin Home content from `lib/features/admin/home/` and the existing admin screens (list in the spec section "Admin Home"); capture a screenshot of the current admin Home from the device.
- [x] **Step 2:** Mock up the admin Home (light and dark) using the approved tokens and the generic components: hero states live / starting within 24 h / none, `StatTile` rows (teams, people), `ActionTile` quick actions (Creează eveniment, Creează știre, Trimite notificare), events with stats, news. Decide the admin tab set (proposal: Acasă, Evenimente, Știri, Profil).
- [x] **Step 3:** Owner approves (2026-10-19); append a section "Admin Home (approved)" to the spec with the hero rules, copy, tabs and any new tokens. Commit `Add admin Home design to spec`; merge.

---

## Phase 8: Admin shell and Admin Home (branch `ui/08-admin-home`), needs Phases 5, 6, 7

### Task 16: resolveAdminHero (pure logic)

**Files:** `lib/features/admin/home/logic/admin_hero.dart`; Test `test/features/admin/home/admin_hero_test.dart`.
**Produces:** `sealed class AdminHero`; `AdminLiveHero(Event event)`, `AdminSoonHero(Event event, Duration untilStart)`, `NoAdminHero()`; `AdminHero resolveAdminHero({required DateTime now, required List<Event> events})` (final rules fixed by the Task 15 addendum; provisional: live = started and `!event.isOver`; soon = starts within 24 h; ties -> earliest start).
- [ ] **Step 1: Failing tests:** `started and not over -> AdminLiveHero`; `stopped event is not live`; `event past 3 h is not live`; `starts in 2 h -> AdminSoonHero(untilStart: 2h)`; `starts in 30 h -> NoAdminHero`; `null dateEvent ignored`; `two live events -> earliest start wins`; `empty list -> NoAdminHero`.
- [ ] **Step 2:** FAIL. **Step 3:** Implement as a pure function. **Step 4:** PASS. Commit.

### Task 17: AdminShell and Admin Home on the new components

**Files:** Create `lib/features/admin/shell/screen/admin_shell.dart` (an `AppShell` with the Task 15 tabs, Profil reused with the logout and theme toggle), `lib/features/admin/home/widgets/` (`admin_hero_section.dart` mapping `AdminHero` to the shared `EventHeroCard`, a stats row of shared `StatTile`s, a quick-actions row of shared `ActionTile`s); Modify `lib/features/admin/home/screen/admin_home.dart`, `admin_controller.dart`, `lib/constants/routes.dart` (`Routes.adminHome` -> `AdminShell`), admin dashboards that take route arguments (read from `EventList`/`NewsList`); Tests `test/features/admin/home/admin_hero_section_test.dart`.
- [ ] **Step 1: Failing tests:** `AdminHeroSection(AdminLiveHero)` shows `LIVE` + `Gestionează eveniment` and fires its callback; `AdminSoonHero` shows the soon pill and the time chip; the stats row shows `nrTeams`/`nrPerson` from the passed values and renders `0`; a null image and a 60-character event name at text scale 1.5 render without overflow (Review Focus 8).
- [ ] **Step 2:** FAIL. **Step 3:** Implement; wire `resolveAdminHero` into `AdminController` with the same 30 s refresh timer as the player Home. **Step 4:** PASS; smoke the admin flows (create event, event management, map, chat, stop event) in light and dark. Commit; merge; tag `ui-phase-8`; push.

---

## Phase 9: Cleanup (branch `ui/09-cleanup`)

Measured before this phase (after Phase 3): about 205 raw `TextStyle(...)`, 139 `BorderRadius.circular(...)`, 27 `MyColors.*` uses, 42 `MyButton(` and 47 `MyTextField(` call sites, about 200 `Colors.*` and 55 `Color(0x...)` literals (mostly intentional: white over photos, map markers, button label colours).

### Task 18: Text theme

**Files:** `lib/ui/theme/app_text_styles.dart`, `lib/ui/theme/app_theme.dart` (TextTheme), `test/ui/theme/app_text_styles_test.dart`; then replace hand-written `TextStyle(...)` in `lib/features/` and `lib/ui/components/` batch by batch.
**Produces:** `abstract class AppTextStyles { static TextStyle headline(BuildContext c); sectionTitle; title; body; bodyMuted; caption; label; button; }` (each reads `context.colors` and uses Poppins weights 400/500/600/700; sizes from the approved screens: section title 15/600, body 12-14/400, caption 11, button 14/600, wordmark 18/700) and the same set registered in `AppTheme` `TextTheme`.
- [ ] **Step 1: Failing tests:** each style has the spec size and weight (`sectionTitle.fontSize == 15`, `fontWeight == FontWeight.w600`); `bodyMuted` uses `AppColors.light.muted` in the light theme and `AppColors.dark.muted` in the dark theme; styles never set a `fontFamily` (the theme provides Poppins).
- [ ] **Step 2:** FAIL. **Step 3:** Implement and register in `TextTheme`. **Step 4:** PASS. Commit.
- [ ] **Step 5:** Migrate screens in the same batches as Phase 3 (auth, player, admin); a `TextStyle(` that only sets colour and size from the token list becomes `AppTextStyles.x(context)`. Smoke each batch.

### Task 19: Spacing and radius tokens

**Files:** `lib/ui/theme/app_spacing.dart`, `lib/ui/theme/app_radius.dart`; tests `test/ui/theme/app_spacing_test.dart`.
**Produces:** extend `AppSpacing` with `xs=4, sm=8, md=12, lg=16, xl=24, page=16`; keep `AppRadius`; `MyPaddings.appHorizontalPadding` (25) is replaced by `AppSpacing.page`.
- [ ] **Step 1: Failing tests:** the scale values above; `AppSpacing.page` replaces the 25 px side padding (decide in the plan review: the approved mockups use 14-16 px panel margins).
- [ ] **Step 2:** FAIL. **Step 3:** Implement. **Step 4:** PASS. **Step 5:** Replace `MyPaddings.appHorizontalPadding` and obvious fixed paddings/radii per batch; do not touch one-off layout values that are not on the scale.

### Task 20: Remove legacy wrappers and `MyColors`

- [ ] **Step 1:** Add `AppDropdown<T>` (+ `AppDropdownItem<T>`) in `lib/ui/components/inputs/` on the theme tokens, with tests: shows label and selected item, opens a list in the panel colour, reports selection, shows an error state. Replace `MyDropdownField`/`DropdownItem` (create event, create news, filters) and delete them.
- [ ] **Step 2:** Replace each `MyButton(` with `AppButton(` and each `MyTextField(` with `AppTextField(` (map `buttonText -> label`, `buttonOnTap -> onPressed`, gradient/themed fills -> primary, `withBorder:true` -> secondary, brand colours -> `backgroundColor`/`foregroundColor`; `labelText -> label`, `hintText -> hint`, `obscureText -> obscure`, drop all ignored style parameters; for fields that relied on the automatic "Introdu ..." message pass an explicit validator). Delete `my_button.dart`, `my_text_field.dart`, `legacy_wrappers_test.dart`.
- [ ] **Step 3:** `grep -rn "MyColors\." lib` must return nothing but intentional brand constants moved into `AppColors` (Facebook blue). Delete `lib/constants/colors.dart` and `lib/constants/padding.dart`.
- [ ] **Step 4:** `flutter analyze` <= baseline, `flutter test` green, smoke every screen. Commit per sub-step.

### Task 21: Semantic colour tokens and feedback components

**Files:** `lib/ui/theme/app_colors.dart` (add `success`, `warning`, `danger` plus their soft backgrounds), `lib/ui/components/feedback/snackbars.dart`, `lib/ui/components/feedback/app_dialog.dart`, `lib/ui/components/feedback/async_state.dart`; tests `test/ui/components/feedback_components_test.dart`.
**Produces:** `AppColors.success/warning/danger` (+ `successSoft/warningSoft/dangerSoft`) for light and dark; `showAppDialog(BuildContext, {required String title, String? message, required String confirmLabel, String? cancelLabel, bool destructive})` returning `Future<bool>`; `AsyncState({required bool isLoading, Object? error, required bool isEmpty, required Widget child, VoidCallback? onRetry, String emptyMessage})` that shows a spinner, an error with a retry button, an empty message, or the child.
- [ ] **Step 1: Failing tests:** `AsyncState` shows a spinner while loading, an error with a `Reîncearcă` button that fires `onRetry`, the empty message when `isEmpty`, and the child otherwise; `showAppDialog` returns true on confirm and false on cancel, the destructive confirm uses `danger`; `MySnackBars` success/error/warning/info use the matching semantic tokens (assert on the rendered `SnackBar` background).
- [ ] **Step 2:** FAIL. **Step 3:** Implement; replace the red delete icons, the photo-approval banner colours (`image_upload_status_banner`) and the hand-built `AlertDialog`s with these. **Step 4:** PASS. Commit.

### Task 22: Icon tinting, accessibility and a colour guard test

- [ ] **Step 1: Failing tests:** `AppSvgIcon('assets/images/chat.svg', size: 24)` applies a `ColorFilter` with `context.colors.text` by default and with a given colour when passed; a guard test `test/ui/no_hardcoded_colors_test.dart` scans `lib/features/**` and fails on `Color(0x`/`Colors.` outside an allow-list file `test/ui/colour_allowlist.txt` (white over photos, map markers, admin puzzle colours); passes today with the allow-list generated from the then-current code.
- [ ] **Step 2:** FAIL. **Step 3:** Implement `lib/ui/components/misc/app_svg_icon.dart` and switch single-colour SVG usages to it (dark mode needs it; Phase 4 starts this, this task finishes it). **Step 4:** PASS.
- [ ] **Step 5:** Accessibility pass: contrast check of `AppColors` pairs in both themes (a test computing WCAG ratios, text on page/panel >= 4.5), 48 dp tap targets on icon-only buttons, `semanticLabel`/tooltips on icon-only buttons, no overflow at text scale 1.5 on the Home screens.

### Task 23: Housekeeping and docs

- [ ] Remove leftover `fontFamily: 'Poppins'` strings, the duplicate `NewsList` provider registration in `main.dart`, and stray debug `print(...)` calls in files touched by this plan.
- [ ] Update `CLAUDE.md`, `docs/ui-and-theme.md`, `docs/screens.md`, `docs/known-issues.md` (remove resolved items) and the plan's own checkboxes.
- [ ] Final `flutter analyze` <= baseline; `flutter test` green; merge; tag `ui-v1`.

**Optional, only if the owner asks:** move Romanian strings into localisation files (separate project); fix the mixed file naming (`FCMService.dart`, `log-in/`, `component-type.dart`).

## Follow-up plans (not in this plan)
Deferred on purpose (owner, 2026-10-19): the **splash screen** and the **game screens** (mission list, puzzle screen, geolocation and photo-upload widgets) are redesigned later and get their dark-mode treatment then, so they are not polished for dark mode in Phase 4 (known gaps: splash logo on a dark background, game screens keep their own backgrounds and colours).

Event details, game mission list, register-team steps, auth screens and the remaining admin screens (dashboards, event management, builder) each get their own plan after Phase 6; Admin Home is Phases 7-8 of this plan. Separately: enforce the enrollment window on the register button, add `Event.maxTeams`, safe package bumps (`chore/deps-safe-bumps`), then the major Firebase upgrades one family at a time.

## Git workflow (applies to every phase)

1. `git checkout main && git pull`, then `git checkout -b ui/0N-name`.
2. One commit per task; messages are short sentences in the style of the repo history.
3. Never commit to `main` directly. Merge with `git merge --no-ff ui/0N-name` so each phase is one revertable merge commit; tag `ui-phase-N`; push main and tags.
4. Rollback of a phase: `git revert -m 1 <merge-commit>`.
5. Phases are merged sequentially (no stacked branches). Any other feature branch must merge `main` before continuing, to avoid drift in `lib/widgets/` paths after Phase 1.
6. Hard dependencies: Phase 3 needs 1–2; Phase 4 needs 3; Phase 5 needs 2 (and 4 for the theme toggle on Profil); Phase 6 needs 2, 3b, 5; Phase 7 needs only the approved tokens (design only, can run any time after Phase 2); Phase 8 needs 5, 6, 7; Phase 9 is last.

## Self-review notes
- Spec coverage: tokens (Task 2), components (Tasks 4–7), dark mode (Tasks 10–11), generic shell (Task 12), player Home states 1–5 (Tasks 13–14), admin Home (Tasks 15–17), copy strings (Tasks 4, 12, 14). Out-of-scope items are listed.
- Type names are consistent across tasks (`AppColors`, `AppButton`, `HomeHero`, `AdminHero`, `ShellController`, `AppShell`, `AppShellTab`).
- Shared UI: one generic `EventHeroCard` (Task 7) is configured by player mapping (Task 14) and admin mapping (Task 17); no role-specific widgets live in `lib/ui/`.
- One open risk: Task 14's recommended-hero team count adds one Firestore read per Home load; acceptable for a single event, cache it in `HomeController` if it shows up in profiling.
