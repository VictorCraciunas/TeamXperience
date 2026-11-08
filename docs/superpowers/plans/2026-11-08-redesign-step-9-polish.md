# Step 9: Authoring and Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Finish the redesign's app side: organisers place pins on a map and can walk through their own event, every screen works in dark mode and when things go wrong, game controls are easy to hit outdoors, and the mockups' small animations are in.

**Architecture:** No new feature folder. A map pin picker in `admin/create_event/common_widgets`, a preview mode on the game controllers, a tap-area wrapper in `lib/ui`, and repairs in the existing screens.

**Tech Stack:** Flutter, flutter_map 8.1, provider.

**Spec:** `docs/roadmap/mockups-roadmap.md` (U3 item 11, L9, U4, the "delete the unused components" line in U1).

## Global Constraints

- Branch `redesign/step-9-polish`, merged with `--no-ff` into `redesign/mockups`. Never push, never deploy Firebase. The merge to `main` stays Victor's call.
- Lighter testing: tests first for logic, data and controllers. One overflow check per new screen. No exact size or colour tests, except that a control's tap area is at least 48 px. Relevant tests during the work, the full suite once before merging. Firebase code with no seam is read through and reported as untested. The final Opus review stays.
- No `x!` in new code, one widget per file, one controller per screen, `lib/ui` never imports `lib/features`.
- Inside a game, colours come from `context.eventPalette`: the event's look stays as authored. Text sizes follow the mockups; only tap areas grow.
- A wrapper must not move what the mockup draws: when a control's tap area grows, its parent's padding shrinks by the same amount.

## Decisions

1. **What L9 still lacks is small.** Every L9 field is already in the editor. Not added: `series` (the season belongs to the parked 7c), `theme` (Victor, 6b: the look comes only from the puzzles), the puzzle `badge` (badges are awarded by the parked 7c).
2. **Pins on a map, and typing stays.** Each coordinates field keeps its text, because organisers paste from Google Maps, and gets a map button beside it.
3. **The preview writes nothing.** "Vezi Eveniment" walks through the event with a throwaway team that exists only on the phone. Solving moves it forward. No team, chat, location, photo upload or finish is saved.
4. **The hint field goes from photo puzzles,** because the game never shows it there. Old values stay stored and unused.
5. **No golden tests.** U4 asked for them, but they pin exact looks, which is what Victor removed on 2026-11-08 and judges in the gallery himself. Say otherwise and they come back as one task.
6. **Dark mode covers the screens organisers and players reach.** Full-screen photo viewers stay black on purpose and are the only lines left in the colour allow-list, plus any line a task rules on.
7. Parked and unchanged: 3b, 7c, and with them the double push on announcements.

## Review Focus

1. A pin picked on the map with an unreadable or empty field, and cancelling the picker: the field and the model stay as they were.
2. Preview: a location puzzle far from the organiser, a photo puzzle, the last mission, and leaving midway. Nothing reaches Firestore and nothing crashes on the missing team doc.
3. The app offline on first open: Home, Evenimente, Joacă, Echipe and Știri say they could not load instead of "no events", and recover when retried.
4. Tap areas: a grown control must not shift the layout it sits in or overflow at 320 px and 1.3x text.
5. Repeating animations: reduced motion is respected, and they stop when the widget leaves.

---

### Task 1: Remove what nothing uses

**Files:**
- Delete: `lib/ui/components/event/events_carousel.dart`, `registered_events_carousel.dart`, `registered_events_list.dart`, `lib/ui/components/misc/custom_icon_dashboard.dart`, and, after a grep shows no caller, `lib/ui/components/feedback/async_state.dart` and `lib/ui/components/misc/theme_mode_button.dart`, with their tests and gallery entries.
- Modify: `test/ui/colour_allowlist.txt` (drop lines for files that no longer hold literals), `docs/known-issues.md` (drop what is stale: the dark-mode note on rebuilt screens, the Evenimente toggle if it now reads well), `docs/ui-and-theme.md`.

- [ ] **Step 1:** Grep each component. One that has a real caller stays, with a ledger ruling.
- [ ] **Step 2:** Delete. Run: `flutter analyze` (no new errors) and `flutter test test/ui --timeout 60s`. Commit: `Remove unused components`.

### Task 2: Pins on a map

**Files:**
- Create: `lib/features/admin/create_event/common_widgets/pin_picker_sheet.dart`, `pin_field_button.dart`
- Modify: `create_event_landing/screen/create_event_screen.dart` (start), `mission_list/mission_text_fields.dart` (mission place), `puzzle_rules/puzzle_rules_form.dart` and its controller (location puzzle), `logic/coordinates.dart`
- Test: `test/features/admin/create_event/pin_picker_test.dart`

**Interfaces:**
- Produces: `Future<({double lat, double lng})?> showPinPicker(BuildContext context, {({double lat, double lng})? initial, ({double lat, double lng})? near})`. `PinFieldButton({required TextEditingController field, ({double lat, double lng})? near, required void Function(String text) onPicked})`.

- [ ] **Step 1: Failing tests.** The picker's start point: `pinStart(initial, near)` gives `initial`, else `near`, else Sibiu. `PinFieldButton`: an unreadable field opens the picker with no initial pin; cancelling leaves the text and calls nothing; a picked pin writes `formatCoordinates(lat, lng)` and calls `onPicked`. Pump with a fake picker passed in, since the map cannot be pumped.
- [ ] **Step 2: Run, watch them fail.** Run: `flutter test test/features/admin/create_event/pin_picker_test.dart --timeout 60s`
- [ ] **Step 3: Implement.** The sheet: full-height `flutter_map`, a fixed pin in the centre, "Alege locul" and "Anulează". The map's centre is the choice, so a thumb never hides it. `near` for a mission is the start pin, for a puzzle its mission's pin.
- [ ] **Step 4: Run, expect PASS.** Commit: `Choose the start, mission and puzzle places on a map`.

### Task 3: The organiser's walk-through

**Files:**
- Modify: `lib/ui/components/navigation/menu.dart`, `lib/features/event_game/screen/event_game_screen.dart`, `screen/puzzle_game_screen.dart`, `controller/event_game_controller.dart`, `controller/puzzle_game_controller.dart`, and the location and photo widgets as the reading demands
- Test: `test/features/event_game/preview_mode_test.dart`

**Interfaces:**
- Produces: route arguments `{'event': Event, 'preview': true}` on `Routes.eventGame`; `previewTeamOf(Event)` gives a team named "Previzualizare", started now, in `features/event_game/logic/`. Controllers take `bool preview = false`.

- [ ] **Step 1: Failing tests.** A correct answer in preview moves the local team forward with no call to its writing functions; a wrong answer counts locally and writes nothing; the last mission returns to the route, not the finish screen; the presence and location timers do not start; a banner line `Previzualizare: nimic nu se salvează.` is on the route.
- [ ] **Step 2: Run, watch them fail.** Step 3: **Implement.** Read `puzzle_game_controller.dart` first; where a write has no seam, add the guard at the one place it starts. In preview a location puzzle offers "Sari peste" instead of needing the place, and a photo puzzle offers "Sari peste" instead of uploading.
- [ ] **Step 4: Run, expect PASS.** Commit: `Vezi Eveniment walks through the event without saving`.

### Task 4: The hint on photo puzzles

**Files:** Modify `puzzle_rules/puzzle_rules_form.dart`. Test: the existing `puzzle_rules_form_test.dart`.

- [ ] **Step 1:** Failing test: a photo puzzle has no hint field; a code puzzle and a location puzzle keep theirs.
- [ ] **Step 2:** Implement, run, expect PASS. Run: `flutter test test/features/admin/create_event --timeout 60s`. Commit: `No hint field where the game shows no hint`.

### Task 5: Dark mode

**Files:** Modify whichever files remain in `test/ui/colour_allowlist.txt`, starting with `chat/widgets/chat_composer.dart`, `chat/widgets/message_bubble.dart`, `team_chats/screen/team_chats_screen.dart`, `event_see_registered_teams/widgets/team_card_widget.dart`, `news_details/news_screen.dart`, `news_dashboard/screen/stiri_dashboard_screen.dart`, `news_category_manipulation/...`, `log-in/screen/log_in_screen.dart`, `sign-up/screen/register.dart`, the two `create_components` editors.

- [ ] **Step 1:** Replace literals with tokens, one file at a time, lowering its allow-list count. `team_chats_screen.dart` also gets Romanian copy instead of "Captain", "Members" and "No teams available".
- [ ] **Step 2:** Run: `flutter test test/ui/no_hardcoded_colors_test.dart test/features/chat --timeout 60s`. Expected PASS, with only the photo viewers left on the allow-list. Commit: `Theme colours on the remaining screens`.

### Task 6: When things go wrong

**Files:** Modify the screens and controllers that show a list, and from step 8's and 7b's deferred lists: `live_room_controller.dart`, `live_room_actions.dart`, `attention_section.dart`, `board_view.dart`, `profile_controller.dart`.

- [ ] **Step 1: Failing tests:**
  - **Announcement:** no teams and a refused push gives `failed`; a failed first read gives `failed`.
  - **Stop:** an event already stopped gives success, not an error.
  - **After leaving:** a late `decidePhoto` or `stop` after `dispose` does not throw.
  - **Failed read:** the room shows no "Nimic de rezolvat acum." next to the failure, and the board says it could not load.
  - **Profil:** a failed memories read says so instead of looking empty.
- [ ] **Step 2: Survey** Home, Evenimente, Joacă, Echipe, Știri and the admin lists for a failed read that reads as "nothing here". For each one found, add a failing controller test and the line `Nu am putut încărca …` with "Încearcă din nou", reusing the pattern already on Evenimente.
- [ ] **Step 3: Implement, run, expect PASS.** Run: `flutter test test/features --timeout 60s`. Commit: `Failed reads say so; live room leftovers`.

### Task 7: Tap areas

**Files:**
- Create: `lib/ui/components/misc/tap_area.dart`
- Modify: `lib/ui/components/game/round_icon_button.dart`, `game_icon_button.dart`, `game_outline_button.dart`, `features/live_room/widgets/live_header.dart`, `live_header_action.dart`, `queue_round_button.dart`, `board_row_tile.dart`, and the bars holding them
- Test: `test/ui/components/tap_area_test.dart`, and the screens' existing overflow checks

**Interfaces:**
- Produces: `TapArea({required Widget child, required VoidCallback? onTap, String? label})`: at least 48 x 48, the child centred, the whole area answering.

- [ ] **Step 1: Failing tests:** a 32 px child in `TapArea` measures 48 and answers a tap 20 px from its centre; `RoundIconButton`, `GameIconButton` and `QueueRoundButton` measure at least 48.
- [ ] **Step 2: Implement.** Shrink the parents' padding so the drawn layout stays where the mockups put it. Run: `flutter test test/ui/components test/features/event_game test/features/live_room --timeout 60s`. Expected PASS. Commit: `Game and live room controls are at least 48 px to tap`.

### Task 8: Animations

**Files:**
- Modify: `lib/ui/components/event/countdown_box.dart` (tick), `lib/features/event_game/widgets/trail_current_card.dart` or its dot (pulse), `lib/ui/components/inputs/code_boxes_input.dart` (shake on a wrong start code)
- Test: `test/ui/components/animations_test.dart`

- [ ] **Step 1: Failing tests:** with `disableAnimations` nothing repeats and `pumpAndSettle` returns; `CodeBoxesInput` going from no error to error shakes once and ends in place. The pop on a correct answer already exists and is left alone.
- [ ] **Step 2: Implement.** A pulse that repeats must not hang existing `pumpAndSettle` tests: they run with animations disabled or use `pump`. Run: `flutter test test/ui/components test/features/event_game test/features/home --timeout 60s`. Expected PASS. Commit: `Countdown tick, route pulse, code box shake`.

### Task 9: Gallery, docs, final

- [ ] **Step 1:** The gallery gets the pin picker and the dark switch where a preview lacks it. Docs: roadmap (step 9 done, what was left out and why, goldens), `docs/features.md`, `docs/ui-and-theme.md` (`TapArea`), `docs/screens.md`, CLAUDE.md if a folder changed.
- [ ] **Step 2:** Run: `flutter analyze` (no new warnings) and `flutter test --timeout 60s`. Expected: all pass. Commit: `Step 9 docs and gallery`.
- [ ] **Step 3:** Whole-branch review on Opus, one fix pass, the full suite once more, merge with `--no-ff`, delete the branch, report rulings, deferred minors and what is untested.
