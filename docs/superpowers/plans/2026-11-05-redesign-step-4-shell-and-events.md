# Redesign step 4: five-tab shell and the Evenimente tab Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** The player app gets the mockups' five-tab menu, with a raised centre "Joacă" that turns into a red "În joc" during a game, and the new Evenimente tab: list/map switch, filter chips, "Înscrierile tale" and the open-event cards. Echipe becomes a tab.

**Architecture:**
- `AppBottomNav` learns five items and a raised centre item, and drops the active pill (mockup `.nav`). The admin shell keeps its four tabs and picks up the same look.
- Every decision is a pure function in a `logic/` file, with unit tests:
  - which events appear in which section
  - what the filters keep
  - the "peste 3 zile" and "Mai sunt 2 locuri" texts
  - what the Joacă tab shows
- Screens are thin: a controller (EventList, UserProvider, TeamService) feeds a pure view widget, which is tested and shown in the gallery with mockup data.

**Tech Stack:** Flutter, provider, flutter_map (already used by the admin map), cloud_firestore count queries, flutter_tabler_icons.

**Spec:**
- `docs/roadmap/mockups-roadmap.md`: L3 (L3.3 filters, L3.4 events map) and U2, U3.3; step 4 of "Order and size".
- Binding visual reference: the left phone of `docs/roadmap/mockups/03-events-and-teams-tabs.html` (Evenimente), and the `.nav` bar of 02, 03 and 08, including the live "În joc" variant in 02.

**Not in this step:**
- The Home redesign: step 5. This step only adds a way to reach Știri.
- The Joacă start-code flow and intro (mockup 05): step 6. Until then the Joacă tab is an interim screen (Task 4).
- The past-edition photos on the event page: step 7.
- The rules and Cloud Functions: step 3b.

## Global Constraints

- **Branch:** `redesign/step-4-shell` from `redesign/mockups`. Merge into `redesign/mockups` only. Never `main`, never push, never `firebase deploy`.
- **The mockup binds.** Where this plan's prose and the mockup differ, follow the mockup and record a ruling. 1 CSS px = 1 logical px, CSS borders sit outside the padding (add the border to the padding), and line height is 1.45.
- **Code:**
  - Colours from `context.colors`, with no literals in `lib/features`.
  - One widget per file, a controller per screen, and no `x!`.
  - `lib/ui/` takes its copy as parameters and never imports `lib/features/`.
  - Icons from `flutter_tabler_icons`, with snake_case names.
- **Copy:** Romanian, exactly as in the mockups. Short months and days follow `lib/utils/event_formats.dart` ("nov", "Sâm").
- **After every task:** `flutter analyze` shows no new issues, `flutter test` passes, and `test/ui/no_hardcoded_colors_test.dart` stays green. Run `dart format` only on the files you change.
- Commit messages end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- **Docs to update:** `docs/features.md`, `docs/screens.md` and `docs/ui-and-theme.md` (and the CLAUDE.md "Navigation & startup" line about `UserShell`), in the task that changes what they describe.

## Review Focus

1. **A registered event whose enrolment is still open** appears once, under "Înscrierile tale", never also under "Deschise pentru înscriere". Covered in Task 3.
2. **Filters combine as people expect.** "Ușor" plus "Mediu" shows both difficulties. "Luna asta" plus "Sub 2 h" shows only events matching both. "Toate" clears everything. An event with no difficulty, or no duration, is hidden by those filters but shown under "Toate". Covered in Task 3.
3. **The map with events that have no start pin.** They are left out of the map without a crash, and with no pins at all the map shows a short note instead of an empty world map. Covered in Task 7.
4. **The centre tab flips to "În joc" and back.** It does so when a game starts and ends while the shell stays open, driven by the same active-event logic as Home. Covered in Tasks 4 and 8.
5. **A 320 px phone at 1.3× text.** The five-tab bar, the chips row and the event cards don't overflow, and the chips row scrolls sideways. Covered in Tasks 1 and 6.

---

### Task 1: Five-tab bar with a raised centre item

**Files:**
- Modify: `lib/ui/components/navigation/app_bottom_nav.dart`, `lib/ui/components/navigation/app_nav_item.dart`
- Create: `lib/ui/components/navigation/nav_button.dart`, `lib/ui/components/navigation/raised_nav_button.dart` (the private `_NavButton` moves out, one widget per file)
- Test: `test/ui/components/app_bottom_nav_test.dart` (update), plus new cases

**Interfaces:**
- Produces:
  - `AppNavItem({required IconData icon, required String label, bool showBadge = false, bool raised = false, bool live = false})`
    - `raised` draws the item as the centre circle
    - `live` turns a raised item red
  - `AppBottomNav` accepts up to 5 items (assert `<= 5`).

Layout from mockups 02, 03 and 08 (`.nav`, `.ni`, `.on`, the centre span):
- **Bar:** `panel` fill, a 1 px top `border`, and padding 6 top (+1 for the border), 4 sides, 10 bottom, inside `SafeArea(top: false)`. Items share the width, aligned to the bottom.
- **Plain item:** a 54 px wide column with a 2 px gap: the icon at 20, then the label at 11. It is `muted`, or `accent` and w500 when active. There is no active pill (remove `navActivePill` from the bar).
- **Raised item:**
  - a 50 px circle with a `navy` fill, a 4 px ring in `page` and the icon at 22 in `onNavy`
  - it sits 26 px above the bar's top edge, overflowing upward and not clipped
  - the label below it is w500 `navy`
  - when `live`, the circle is `live` red and the label is `live`
  - the whole raised column is the tap target
- The badge dot keeps working on plain items.

- [ ] **Step 1: Write the failing tests.**
  - Five items render.
  - The raised item's circle is 50 × 50, navy, with a page-coloured 4 px ring, and its top is 26 px above the bar's top.
  - `live` makes the circle and label `AppColors.light.live`.
  - The active plain item's label is `accent` and w500, and no pill is drawn.
  - Tapping the raised item calls `onSelected(2)`.
  - No overflow at 320 px and 1.3×.
  - The existing four-item behaviour (admin) still passes.
- [ ] **Step 2: Run** `flutter test test/ui/components/app_bottom_nav_test.dart`. Expected: FAIL.
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run** `flutter test test/ui`. Expected: PASS.
- [ ] **Step 5: Commit** with the message "Bottom bar: five tabs, raised centre item, mockup colours".

### Task 2: ScreenBar fills its slot (carried from step 3)

**Files:** `lib/ui/components/navigation/screen_bar.dart`, `test/ui/components/screen_bar_test.dart`

At 1× text the bar renders 3–5 px shorter than its `preferredSize`, because Scaffold gives the app bar loose constraints. That leaves a thin page-coloured strip under the bar on the register and join screens.

- [ ] **Step 1: Write a failing test.** At text scales 1.0, 1.15 and 1.3, a Scaffold with `ScreenBar(title + subtitle)` has the bar's rendered height equal to `preferredSize.height` (± 0.5), with its bottom border at the body's top.
- [ ] **Step 2: Run** it. Expected: FAIL at 1.0.
- [ ] **Step 3: Implement.** Make the bar fill `preferredSize`, for example with `ConstrainedBox(minHeight: ...)` and the content centred vertically.
- [ ] **Step 4: Run** `flutter test test/ui test/features/register_team test/features/join_team`. Expected: PASS.
- [ ] **Step 5: Commit** with the message "Screen bar fills its slot at every text size".

### Task 3: Events tab logic

**Files:**
- Create: `lib/features/events_tab/logic/event_filters.dart`, `lib/features/events_tab/logic/event_sections.dart`, `lib/features/events_tab/logic/event_card_texts.dart`
- Modify: `lib/backend/repo/teamRepo.dart` (`Future<int> countTeams(String eventId)` using `.count().get()`), `lib/service/team_service/team_service.dart` (`countTeams` passthrough)
- Test: `test/features/events_tab/event_filters_test.dart`, `event_sections_test.dart`, `event_card_texts_test.dart`

**Interfaces:**
- Produces:
  - `enum EventFilter { thisMonth, easy, medium, hard, under2h }`
  - `class EventQuery { final Set<EventFilter> filters; final String search; bool get isAll; }`, where `isAll` means no filters and an empty search.
  - `List<Event> applyQuery(List<Event> events, EventQuery q, DateTime now)`:
    - `thisMonth` keeps events in `now`'s month and year.
    - The difficulty filters are OR among themselves, using `effectiveDifficulty`; an event without one fails any difficulty filter.
    - `under2h` keeps `effectiveDurationMinutes <= 120`, and fails events with no duration.
    - Different kinds of filter combine with AND.
    - `search` matches name, location or area, ignoring case and diacritics.
  - `({List<Event> registered, List<Event> open, List<Event> soon}) sectionEvents(List<Event> events, Set<String> registeredIds, DateTime now)`:
    - Over events are dropped. Use `isOverAt` from `lib/features/event_details/logic/enrolment_window.dart`; Task 3 may move it to `lib/utils/` if two features need it, and must say so.
    - `registered`: events in `registeredIds`, soonest first.
    - `open`: not registered and enrolment open (not `enrolmentNotOpenYet`, not `enrolmentClosed`), soonest first.
    - `soon`: not registered and enrolment not open yet, soonest first.
    - Events whose enrolment has closed and that the player isn't in are not shown.
  - `String untilText(DateTime now, DateTime start)`, counting calendar days: `'azi'`, `'mâine'`, `'peste 3 zile'`.
  - `String? spotsBadge(int? maxTeams, int teamsCount)`:
    - null without `maxTeams`, or when more than 5 places are left
    - `'Mai sunt 2 locuri'`, `'Mai e un loc'` for one place, `'Nu mai sunt locuri'` at 0
  - `String cardDate(DateTime d)`: `'Sâm 21 nov'` (`shortDay` + `dayAndMonth`).
  - `String cardRouteFacts(Event e)`: `'3,2 km · 1 h 30'`. Only the parts the event has are joined with `' · '`, and it is `''` with none.

- [ ] **Step 1: Write the failing tests.** One per rule above, including Review Focus 1 and 2.
- [ ] **Step 2: Run** them. Expected: FAIL.
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run** `flutter test test/features/events_tab`. Expected: PASS.
- [ ] **Step 5: Commit** with the message "Events tab: sections, filters and card texts".

### Task 4: Joacă tab (interim) and the live centre item

**Files:**
- Create: `lib/features/play_tab/logic/play_tab_state.dart`, `lib/features/play_tab/controller/play_tab_controller.dart`, `lib/features/play_tab/screen/play_tab_screen.dart`, `lib/features/play_tab/widgets/play_tab_view.dart` (plus a widget file per card)
- Test: `test/features/play_tab/play_tab_state_test.dart`, `test/features/play_tab/play_tab_view_test.dart`

**Interfaces:**
- Consumes: `resolveHomeHero` and its `HomeHero` cases (`lib/features/home/logic/home_hero.dart`), plus the inputs `HomeController` already gathers from `UserEventsProvider`.
- Produces:
  - `sealed class PlayTabState` with `PlayLive(event, team)`, `PlayEnterCode(event, minutesLeft)`, `PlayNext(event, untilStart)` and `PlayNone`
  - `PlayTabState playTabState(HomeHero hero)`: `LiveHero` → `PlayLive`, `StartingSoonHero` → `PlayEnterCode`, `UpcomingHero` → `PlayNext`, and `RecommendedHero` or `NoHero` → `PlayNone`
  - `bool isLive(PlayTabState s)`, which the shell uses to make the centre item `live`

Interim view (not in the mockups; step 6 replaces it with mockup 05). It uses existing components: page padding 14, `OutlineCard`s and `NavyButton`.

| state | content | button |
|---|---|---|
| `PlayLive` | the event name and "Echipa {team} e în joc" | "Continuă jocul" opens `Routes.eventGame` with `{'event', 'team'}` |
| `PlayEnterCode` | the event name and "{m} min să intri" | "Introdu codul" opens `Routes.enterCodeScreen` with the event |
| `PlayNext` | "Următorul tău joc", the event name, then `eventDayLine` | "Vezi evenimentul" opens the event page |
| `PlayNone` | "Nu ai niciun joc programat." | "Vezi evenimentele" switches the shell to the Evenimente tab (through `ShellController`) |

- [ ] **Step 1: Write the failing tests.**
  - Each mapping case.
  - `isLive`.
  - The view shows each state's copy, and each button calls its callback.
  - No overflow at 320 px and 1.3×.
- [ ] **Step 2: Run** them. Expected: FAIL.
- [ ] **Step 3: Implement.** The controller reuses `HomeController`'s inputs (`UserEventsProvider`, the clock), or a shared helper extracted from it (say so), and refreshes every 30 s like Home does.
- [ ] **Step 4: Run** `flutter test test/features/play_tab test/features/home`. Expected: PASS.
- [ ] **Step 5: Commit** with the message "Joacă tab: what to do now, until the start-code flow lands".

### Task 5: Shared event-list pieces (UI)

**Files:**
- Create: `lib/ui/components/event/registered_event_tile.dart`, `lib/ui/components/event/open_event_card.dart`, `lib/ui/components/misc/section_header.dart`, `lib/ui/components/misc/pill_switch.dart`
- Test: `test/ui/components/event_list_pieces_test.dart`

These go in `lib/ui` because Home (step 5) shows the same tiles. Layout follows mockup 03's left phone:

- **`SectionHeader({required String title, String? trailing, String? link, VoidCallback? onLink})`** (`.hd`): margin 14 top, 14 sides, 8 bottom. Title 14 w500. `trailing` (a count) 11 muted at the right, or `link` 11 w500 accent.
- **`PillSwitch({required List<(IconData, String)> options, required int selected, required ValueChanged<int> onSelected})`**: the Listă/Hartă switch.
  - Track: `inset` fill, 1 px `insetBorder`, pill radius, 3 px padding.
  - Selected segment: `panel` fill, 1 px `border`, pill radius, padding 4, w500 `accent`, with the icon at 13 before the label.
  - Other segments: `muted`.
- **`RegisteredEventTile({required String day, required String month, required String title, required String subtitle, required String badge, required VoidCallback onTap})`**:
  - `OutlineCard` with padding 8 and a gap of 10.
  - A date block 46 wide: `navy` fill, radius 10, padding 4 vertical. The day is 16 w500 `onNavy` at line height 1.1, the month 11.
  - The title in `cardTitle`, the subtitle 11 muted.
  - The badge pill: `successSoft` fill, `success` text, 11 w500, padding 2/8.
- **`OpenEventCard({String? imageUrl, String? badge, required String title, required String date, required String facts, required VoidCallback onTap, required VoidCallback onShare})`**:
  - `OutlineCard` with no padding, clipped.
  - A top strip 92 tall: the image (cover, `CachedNetworkImage` for http), or `accent` fill without one.
  - The badge pill at 8, 8: `soon` fill, `onTick` text, 11 w500, padding 1/8.
  - A share circle at the top right, 8 in: 28 px, `heroButton`, `TablerIcons.share` 15.
  - Body padding 8/12: the title (w500 12), then 4 below a row with a gap of 6: `TablerIcons.map_pin` 13 accent, `date` 11 muted, a flexible dashed line (`DashedLine` from the route components), and `facts` 11 muted.

**Ruling:** mockup 03 draws a second card smaller (60 px strip, one text line); every open event uses the first card's style for consistency, recorded in the ledger.

- [ ] **Step 1: Write the failing tests.**
  - Each piece shows its copy with the mockup's sizes: date block 46 wide, strip 92 tall, share circle 28.
  - Callbacks fire.
  - `PillSwitch` taps call `onSelected`.
  - No overflow at 320 px and 1.3×, light and dark.
- [ ] **Step 2: Run** them. Expected: FAIL.
- [ ] **Step 3: Implement.** Add a "Evenimente" gallery section with mockup copy.
- [ ] **Step 4: Run** `flutter test test/ui test/dev`. Expected: PASS.
- [ ] **Step 5: Commit** with the message "Event list pieces: section header, pill switch, registered tile, open event card".

### Task 6: Evenimente tab (list)

**Files:**
- Create in `lib/features/events_tab/`:
  - `controller/events_tab_controller.dart`
  - `screen/events_tab_screen.dart`
  - in `widgets/`: `events_tab_view.dart`, `events_header.dart`, `filter_chips_row.dart`, `events_list.dart`, `events_search_field.dart`
- Modify: `lib/constants/routes.dart` and `lib/main.dart`, so `Routes.eventDashboardUser` points to `EventsTabScreen`
- Delete: `lib/features/events_dashboard/events_dashboard_user/` (the old player feed), once nothing imports it (grep). Remove its allow-list lines.
- Test: `test/features/events_tab/events_tab_view_test.dart`, `events_tab_controller_test.dart`

**Interfaces:**
- Consumes: Tasks 3 and 5.
- Produces:
  - `EventsTabController` (`ChangeNotifier`):
    - reads `EventList` (published events) and `UserProvider`
    - holds `EventQuery`, `bool mapMode` and `bool searching`
    - `teamNames`: registered event id → team name, looked up once per registered event with `getUserTeamForEvent`, quietly skipping failures
    - `teamCounts`: event id → count, only for events with `maxTeams`, through `TeamService.countTeams`
    - methods: `toggle(EventFilter)`, `selectAll()`, `setSearch(String)`, `setMapMode(bool)`, `refresh()`
    - it takes `TeamService` and a clock for tests
  - `EventsTabView`: a pure view widget fed by the sections, query, mode, team names, counts, `now` and callbacks.

Layout from mockup 03's left phone:
- **Header:** `panel`, a 1 px bottom border, padding 12/14 (bottom +1).
  - "Evenimente" at 17 w500, and at the right a 32 px `iconButtonBg` circle with `TablerIcons.search` 17. Tapping it toggles an `AppTextField` search under the title.
  - 10 below: `PillSwitch` with Listă (`TablerIcons.list`) and Hartă (`TablerIcons.map`).
- **Chips row:** horizontal scroll, padding 10 top and 14 sides, gap 6.
  - "Toate" is `selected` when `isAll`, and tapping it calls `selectAll`.
  - Then "Luna asta", "● Ușor", "●● Mediu", "●●● Greu" and "Sub 2 h". The dots are `accent`, and a chip is selected while its filter is on. ("Greu" is not visible in the mockup's clipped row; recorded as a ruling.)
- **List mode:**
  - "Înscrierile tale" (`SectionHeader`), with a `RegisteredEventTile` per event, gap 8. Its subtitle is `'{team} · {untilText}'`, or just `untilText` when the team name isn't known, and its badge is "Înscriși".
  - "Deschise pentru înscriere" with the count as `trailing`, then an `OpenEventCard` per event, gap 8, padding 0/14. Its badge comes from `spotsBadge`, its date from `cardDate`, its facts from `cardRouteFacts`. Share uses `ShareService.shareText` with `eventShareText`.
  - "În curând" (only when not empty) with the same cards.
  - A section with no events is skipped. When nothing matches at all: "Niciun eveniment nu se potrivește." (13 muted, centred) and a "Arată toate" link calling `selectAll`.
  - Pull-to-refresh calls `refresh` (`EventList.loadEvents(forceRefresh: true)`).
- Tapping a tile or card opens `Routes.eventDetails` with `{'event': e, 'isAdmin': false}`.

- [ ] **Step 1: Write the failing tests.**
  - The view with the mockup data (Moștenirea registered with team Vulpile three days ahead; Protocolul Cerber open with `maxTeams` 12 and 10 teams; Noaptea muzeelor open) shows: "Evenimente", "Listă", "Hartă", "Toate", "Înscrierile tale", "Vulpile · peste 3 zile", "Înscriși", "Deschise pentru înscriere", "2", "Mai sunt 2 locuri" and "Sâm 21 nov".
  - Tapping "Luna asta" calls `toggle(thisMonth)`.
  - The empty-filter state shows "Arată toate".
  - The controller resolves team names and counts with a fake `TeamService`.
  - Review Focus 5: the chips row scrolls and nothing overflows at 320 px and 1.3×, in dark mode too.
- [ ] **Step 2: Run** them. Expected: FAIL.
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run** `flutter test`. Expected: PASS.
- [ ] **Step 5: Commit** with the message "Evenimente tab: header, filters, your registrations and open events".

### Task 7: Evenimente tab (map)

**Files:**
- Create: `lib/features/events_tab/widgets/events_map.dart`, `lib/features/events_tab/widgets/event_map_pin.dart`, `lib/features/events_tab/logic/map_points.dart`
- Test: `test/features/events_tab/map_points_test.dart`, `test/features/events_tab/events_map_test.dart`

**Interfaces:**
- Produces:
  - `List<(Event, LatLng)> mapPoints(List<Event> events)`: events with a start pin only.
  - `LatLngBounds? pointsBounds(List<LatLng>)`: null when empty.
  - `EventsMap({required List<Event> events, required Set<String> registeredIds, required void Function(Event) onOpen})`

The map is not drawn in the mockup; it reuses the app's styles:
- `FlutterMap` with OpenStreetMap tiles, the same tile settings as `lib/features/map/screen/map_screen.dart`.
- It fits the bounds of the points with padding 40, or centres on the single point at zoom 15.
- Each pin is a 32 px circle with `TablerIcons.map_pin` 16 in `onNavy`: `navy` fill, or `tick` fill with `onTick` icon for registered events.
- Tapping a pin shows a card along the bottom (padding 14) with the `RegisteredEventTile` layout, its badge "Înscriși" or "Deschis". Tapping the card calls `onOpen`.
- With no points: "Niciun eveniment nu are încă locul pe hartă." centred (Review Focus 3).
- The map shows the same filtered events as the list. Sections don't apply.

- [ ] **Step 1: Write the failing tests.**
  - `mapPoints` drops pinless events.
  - `pointsBounds` of an empty list is null.
  - `EventsMap` with no points shows the note.
  - With two points, tapping a pin shows its title, and tapping the card calls `onOpen`. Use a test that doesn't load network tiles: a `TileLayer` with a `tileProvider` that returns a blank image, or no tile layer in tests via a parameter.
- [ ] **Step 2: Run** them. Expected: FAIL.
- [ ] **Step 3: Implement.** The tab switches between list and map with `mapMode`.
- [ ] **Step 4: Run** `flutter test`. Expected: PASS.
- [ ] **Step 5: Commit** with the message "Evenimente tab: map of start pins".

### Task 8: Five-tab player shell

**Files:**
- Modify: `lib/features/shell/screen/user_shell.dart`, `lib/features/home/...` (a way to Știri), `lib/features/profile/widgets/profile_view.dart` (remove the "Echipele mele" row and `profile_teams_row.dart`, since Echipe is a tab now), `lib/features/join_team/controller/join_team_controller.dart`, `CLAUDE.md` ("Navigation & startup"), `docs/features.md`, `docs/screens.md`
- Test: `test/features/shell/user_shell_test.dart` (create or update), `test/features/join_team/join_team_controller_test.dart`

**Interfaces:**
- Produces: `UserShell` with five tabs, in order:

  | tab | icon | screen |
  |---|---|---|
  | Acasă | `TablerIcons.home` | `Home` |
  | Evenimente | `TablerIcons.map_2` | `EventsTabScreen` |
  | Joacă | `TablerIcons.key`, `raised` | `PlayTabScreen` |
  | Echipe | `TablerIcons.users_group` | `TeamsScreen` |
  | Profil | `TablerIcons.user` | `ProfileScreen` |

  The centre item becomes `live` with `TablerIcons.player_play` and the label "În joc" while `isLive(playTabState(...))` is true. The shell listens to the same provider `HomeController` uses, so it flips without a restart (Review Focus 4).

Other changes:
- **Știri** leaves the bar. Home's news panel gets a `SectionHeader` link "Vezi toate" that opens `Routes.newsDashboard`. If Home has no news panel when this task starts, add one with the latest 3 news items, using `StireCard` and the existing `NewsList`.
- **Join from Echipe:** when a join has no event, the join screen now just pops back to the Echipe tab, whose crew stream already shows the new team. `Routes.teams` is no longer pushed. Keep the route for deep entry. Update the step 3 controller test that expected a push.

- [ ] **Step 1: Write the failing tests.**
  - The shell shows the five labels.
  - Tapping Echipe shows "Echipe".
  - With a fake live game the centre label is "În joc", and it changes back when the fake ends.
  - The join controller pops on a no-event join.
  - Profil no longer shows "Echipele mele".
- [ ] **Step 2: Run** them. Expected: FAIL.
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run** `flutter test` and `flutter analyze`. Expected: PASS, no new issues.
- [ ] **Step 5: Commit** with the message "Five-tab player shell: Acasă, Evenimente, Joacă, Echipe, Profil".

### Task 9: Gallery, review and merge

**Files:** `lib/dev/` (an Evenimente tab preview with the mockup's three events in list and map modes, the nav bar in its normal and live states, and the Joacă tab's four states; mockup data in `lib/dev/sample_event.dart` gains `sampleOpenEvents()`), `test/dev/`

- [ ] **Step 1: Write a failing test.** Each preview renders in light and dark with no exception.
- [ ] **Step 2: Implement the previews.** Then run `flutter test` and `flutter analyze`. Expected: pass, no new issues.
- [ ] **Step 3: Commit** with the message "Gallery: Evenimente tab, bottom bar and Joacă tab".
- [ ] **Step 4: Review the whole branch** with a fresh reviewer on the most capable model, against Review Focus 1–5 and the mockups. Fix Critical and Important findings test-first.
- [ ] **Step 5: Merge** with `git checkout redesign/mockups && git merge --no-ff redesign/step-4-shell`, then run `flutter test`. Do not push.
