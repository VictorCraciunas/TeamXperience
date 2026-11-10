# Step 8: The Organiser's Live Room Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace "Gestionare eveniment" with the live room of mockup 09: a map of the teams, live counts, a queue of what needs attention, a progress board with filters, announce and stop.

**Architecture:** A new `lib/features/live_room/` feature. Pure functions in `logic/` turn teams and the time into statuses, a queue and board rows. `LiveRoomController` streams the event and its teams and does the actions, with its writes passed in so tests can replace them. The views take plain values, so the gallery can show them without Firebase.

**Tech Stack:** Flutter, provider, Firestore, flutter_map 8.1, url_launcher, flutter_tabler_icons.

**Spec:** `docs/roadmap/mockups-roadmap.md` (L8, U3.10), `docs/roadmap/mockups/09-admin-live-control-room.html`.

## Global Constraints

- Branch `redesign/step-8-live-room`, merged with `--no-ff` into `redesign/mockups`. Never push. Never deploy Firebase.
- Lighter testing: tests first for logic, data and the controller. Each screen gets one overflow check (320 px at 1.3x text). No exact size or colour tests. Relevant tests during the work, the full suite once before merging. Code with no seam to Firebase is read through and reported as untested. The final Opus review stays.
- No `x!`, one widget per file, one controller per screen (the room and its board share one, see Decisions), `lib/ui` never imports `lib/features`.
- Colours come from `context.colors`; `test/ui/no_hardcoded_colors_test.dart` must pass.
- Mockup measures: 1 CSS px = 1 logical px, line height 1.45, CSS width is the content box.

## Decisions

1. **Unread messages need no server.** L8 wanted `unreadByAdmin` set by `onChatMessage`, which is parked. A player's text message and `unreadByAdmin: {text, at}` on the team go in one batch; the organiser's chat clears it on open and on leaving. Costs one rule for 3b.
2. **Pins are coloured by state, as the mockup draws them** (L8 said per team): navy in play, amber stuck, teal finished, grey when no phone was seen for 5 minutes. A team that has not started, or has no position yet (0, 0), has no pin.
3. **The board opens** from a second round icon in the navy header and from tapping a count. The mockup shows both pages but no link. "Neporniți" opens it on that filter; the others on "Toate".
4. **The live room replaces `EventManagementScreen`** on `Routes.eventManagement`, also before the start and after the end. Its links are covered: announce, the map, chats through the team sheet. Admin Home keeps its own links to chats and notifications.
5. **The map moves** to `features/live_room` (admin only; `EventDetailsController.navigateToMap` is unused and goes). `Routes.map` keeps its arguments.
6. **"Blocate" means stuck:** started, not finished, no mission solved for 20 minutes, no photo waiting. A team waiting on the organiser's decision is not stuck.
7. **One queue card per team for being stuck and wrong attempts together**, as the mockup does.
8. **Double push on announcements until 3b/7c.** The announcement is posted to each chat with `announcement: true`; `onChatMessage` must skip those, which goes on the parked list. Until then a player can get two notifications.
9. Wording follows the mockup ("Cometele stau de 25 min"), so a singular name reads oddly ("Rapsodia stau").

## Review Focus

1. The event is stopped or ran out while the room is open: stuck cards disappear, no "Oprește", the state comes from the stream and not the `Event` argument.
2. A photo decided in the chat, or by a second organiser, leaves the queue; a double tap on approve writes once.
3. An empty event: no teams, no missions, no mission pins, no start pin. Nothing crashes and the map still shows.
4. Odd team data: empty name, an emoji first letter, progress past the mission count, `startedAt` null on a started team, a server time still pending (null).
5. An announcement half fails: the chats got it, the push did not. The organiser is told exactly that, and text is not lost on a total failure.

---

### Task 1: Data

**Files:**
- Modify: `lib/model/team.dart`, `lib/model/message.dart`, `lib/backend/repo/messages_repo.dart`, `lib/backend/repo/teamRepo.dart`, `lib/service/message_service.dart`, `lib/service/team_service/team_service.dart`, `lib/features/admin/home/.../admin_event_stats.dart`
- Test: `test/model/team_unread_test.dart`, `test/model/message_announcement_test.dart`, the existing stats test

**Interfaces:**
- Produces: `Team.unreadText` (`String?`), `Team.unreadAt` (`DateTime?`), read from `unreadByAdmin`, never written by `toJson`. `Message.announcement` (`bool`, default false, written only when true). `AdminEventStats.notStarted` (`int`). `TeamService.clearUnread(eventId, teamName)`. `MessageService.announce(eventId, List<String> teamNames, String text)`.

- [ ] **Step 1: Write the failing tests**
  - `unreadByAdmin: {text: 'Ușa e închisă', at: Timestamp}` gives both fields; absent gives null and null; a pending `at` gives the text and a null time; a non-map value gives null and null; `toJson` has no `unreadByAdmin`.
  - `Message.toJson` has no `announcement` by default and `true` when set; `fromFirestore` reads it, missing means false.
  - `AdminEventStats.fromTeams` of one started, one finished, one not started: `inPlay 1, finished 1, notStarted 1`.
- [ ] **Step 2: Run them, watch them fail.** Run: `flutter test test/model/team_unread_test.dart test/model/message_announcement_test.dart --timeout 60s`
- [ ] **Step 3: Implement.** `MessageRepo.sendPlayerMessage` writes the message and `unreadByAdmin` in one `WriteBatch` (`at` is the server time). `MessageRepo.sendToTeams` batches one message per team. `MessageService.sendMessage` uses the batch for a USER and the plain add for an ADMIN. Images are not unread (they come through the photo queue). `TeamRepo.clearUnread` does `update({'unreadByAdmin': FieldValue.delete()})`. The repo bodies have no seam: read them through.
- [ ] **Step 4: Run the tests, expect PASS.** Commit: `Unread messages on the team, announcements, not-started count`.

### Task 2: Logic

**Files:**
- Create: `lib/features/live_room/logic/live_status.dart`, `attention_queue.dart`, `live_board.dart`, `live_texts.dart`
- Test: `test/features/live_room/live_status_test.dart`, `attention_queue_test.dart`, `live_board_test.dart`, `live_texts_test.dart`

**Interfaces:**
- Consumes: `rankTeams` (`lib/service/leaderboard.dart`), `Team`, `initialsOf`.
- Produces:
  ```dart
  enum LiveState { notStarted, playing, waitingPhoto, stuck, finished, stopped }
  const stuckAfter = Duration(minutes: 20); const silentAfter = Duration(minutes: 5); const wrongLimit = 3;
  LiveState liveStateOf(Team team, {required int missionCount, required DateTime now, required bool eventOver});
  DateTime? lastActivity(Team team);            // lastMissionAt ?? startedAt
  int wrongOnCurrent(Team team);                // attempts[puzzleKey(missionProgress, puzzleNumber)] ?? 0
  bool isSilent(Team team, DateTime now);       // has presence, the newest older than silentAfter

  sealed class AttentionItem { Team team; DateTime at; }
  class PhotoAttention extends AttentionItem { String key; String? url; int mission; }   // mission is 1-based
  class StuckAttention extends AttentionItem { int? minutes; int mission; int wrong; }   // minutes null when only wrong attempts
  class MessageAttention extends AttentionItem { String text; }
  List<AttentionItem> attentionQueue(List<Team> teams, {required int missionCount, required DateTime now, required bool eventOver});

  enum BoardFilter { all, stuck, notStarted }
  class BoardRow { Team team; int? place; int done; LiveState state; DateTime? since; }
  List<BoardRow> boardRows(List<Team> teams, {required int missionCount, required DateTime now, required bool eventOver, BoardFilter filter = BoardFilter.all});
  ```
  `live_texts.dart`: `liveHeaderLine(Event, now)`, `boardHeaderLine(teams, missions)`, `boardStatusText(BoardRow, now)`, `stuckTitle(StuckAttention)`, `stuckSubtitle(StuckAttention)`, `teamInitial(String name)`.

- [ ] **Step 1: Write the failing tests** (`now` fixed; helper `_team(...)`):
  - **State:** not started; playing; stuck exactly at 20 min and not at 19; from `startedAt` before the first mission; a pending photo beats stuck; `startedAt` null is playing; `hasFinished` with every mission is `finished`, with fewer is `stopped`; `eventOver` never gives `stuck`.
  - **Silent:** no presence is not silent; 4 min no; 6 min yes; the newest phone counts.
  - **Queue:**
    - a pending photo gives one `PhotoAttention` with its url and mission 3 from key `2_0_1`; approved and denied give nothing
    - stuck 25 min with 3 wrong gives one card, minutes 25, wrong 3, mission 2
    - 3 wrong and not stuck gives one card with minutes null; 2 wrong and not stuck gives nothing
    - attempts on another puzzle do not count
    - `unreadText` gives `MessageAttention`, for a finished team too
    - `eventOver` drops stuck and wrong, keeps photos and messages
    - a not-started team gives nothing
    - newest first by `at`, ties by team name; a null time (pending) sorts first
  - **Board:**
    - places from `rankTeams` for started teams only; not started last, place null, by name
    - `done` is clamped to the mission count
    - filters: `stuck` keeps stuck, `notStarted` keeps not started
    - no teams gives an empty list; 0 missions does not throw
  - **Texts:**
    - before the start `Începe în 2 h 10 min`; live `1:17:42 rămase`; stopped `Oprit`; ran out `Încheiat`
    - `12 echipe · 6 misiuni`, `O echipă · O misiune`
    - status: `acum 2 min`, `acum` under a minute, `acum 1 h 5 min`, `poză în așteptare`, `blocați 25 min`, `n-au introdus codul`, `au terminat`, `oprită`
    - `Cometele stau de 25 min` / `Misiunea 2 · 3 încercări greșite`; zero wrong gives `Misiunea 2`; wrong only gives `Cometele: 3 încercări greșite` / `Misiunea 2`
    - `teamInitial('')` is `?`; an emoji stays whole; `vulpile` gives `V`
- [ ] **Step 2: Run them, watch them fail.** Run: `flutter test test/features/live_room --timeout 60s`
- [ ] **Step 3: Implement.** No Flutter imports in `logic/` except what `Team`/`Event` bring.
- [ ] **Step 4: Run the tests, expect PASS.** Commit: `Live room logic: statuses, attention queue, board`.

### Task 3: Controller

**Files:**
- Create: `lib/features/live_room/controller/live_room_controller.dart`
- Test: `test/features/live_room/live_room_controller_test.dart`

**Interfaces:**
- Consumes: Tasks 1 and 2.
- Produces:
  ```dart
  class LiveRoomController extends ChangeNotifier {
    LiveRoomController({required Event event, Stream<Event>? eventStream, Stream<List<Team>>? teamStream,
      Future<void> Function(Team, String key, PhotoApprovalStatus, {String? reason, String? url})? writeApproval,
      Future<void> Function(String eventId)? stopEvent,
      Future<void> Function(List<String> teams, String text)? postToChats,
      Future<bool> Function(String title, String text)? pushNotification,
      Future<bool> Function(Uri)? openPhone,
      DateTime Function()? now});
    Event get event; List<Team> get teams; bool get loading; Object? get error;
    bool get canStop; bool get hasStarted; AdminEventStats get stats;
    Stream<List<Team>> get teamsStream;          // broadcast, for the big map
    BoardFilter filter; void setFilter(BoardFilter f);
    Future<bool> decidePhoto(PhotoAttention item, {required bool approve, String? reason});   // false on failure or when already busy
    Future<bool> stop();
    Future<AnnounceResult> announce(String text);  // sent, chatsOnly, failed
    Future<CallResult> callCaptain(Team team);     // opened, noPhone, failed
  }
  Uri? phoneUri(String phone);                     // tel: with only digits and +; null when empty
  ```
  Default arguments reach `EventService`, `TeamService`, `MessageService` and `NetworkAPI`. Dialogs, snackbars and navigation stay in the screens.

- [ ] **Step 1: Write the failing tests** with `StreamController`s and fakes:
  - teams and event arrive and notify; a later `isStopped` makes `canStop` false; before the start `canStop` is false; a stream error sets `error`.
  - `decidePhoto` approve passes the key and url with no reason; reject passes the reason; a second call while the first runs does nothing; a failing write returns false.
  - `announce` calls `postToChats` with every team's name and then the push; push false gives `chatsOnly`; a post that throws gives `failed` and sends no push; blank text does nothing.
  - `phoneUri('0722 123-456')` is `tel:0722123456`; `''` is null. `callCaptain` with no phone is `noPhone`.
  - `dispose` cancels both subscriptions.
- [ ] **Step 2: Run, watch it fail.** Run: `flutter test test/features/live_room/live_room_controller_test.dart --timeout 60s`
- [ ] **Step 3: Implement.** Step 4: **Run, expect PASS.** Commit: `LiveRoomController`.

### Task 4: The two pages

**Files:**
- Create in `lib/features/live_room/widgets/`: `live_header.dart`, `live_room_view.dart`, `live_map.dart`, `team_pin.dart`, `live_counts.dart`, `attention_section.dart`, `photo_attention_card.dart`, `stuck_attention_card.dart`, `message_attention_card.dart`, `board_view.dart`, `board_row_tile.dart`, `board_segments.dart`, `board_actions_bar.dart`, `team_sheet.dart`
- Test: `test/features/live_room/live_room_view_test.dart`, `board_view_test.dart`

**Interfaces:**
- Consumes: Task 2, `OutlineCard`, `AppChip` (`AppChipStyle.selected`), `SectionHeader`, `initialsOf` not used (`teamInitial`).
- Produces: `LiveRoomView({event, teams, missionCount, now, eventOver, Widget map, callbacks...})` and `BoardView({title line, rows, filter, now, canStop, callbacks...})`, plus `LiveMap({event, teams, now, onTeam, onBigMap, MapController?})` and `showTeamSheet(context, team, statusText, onCall, onMessage)`.

Measures from the mockup: navy header (padding 12/14, 18 px back arrow, 32 px round icon on `onNavy` at 12 %); map 170 high with a 1 px border under it; pins 24 px with a 2 px white ring, 11 px w500; "Hartă mare" pill bottom right 8 in; three count cards 6 apart with a 15 px w500 value (`success`, `warning` for the 2nd and 3rd) over an 11 px muted label; queue cards 6 apart with padding 8, 44 px thumbnail radius 8, 30 px round reject (`dangerSoft`/`danger`) and approve (`successSoft`/`success`); stuck card border `warning`; board rows padding 8/12, 16 px place, 92 px name column, 5 px segments 2 apart (done `tick`, current `warning` when stuck or waiting, the rest `border`), a row with a waiting photo tinted `iconButtonBg`, not started at 55 % with `Sună căpitanul` in the accent; bottom bar two 1.5 px outline buttons `Anunț` (accent) and `Oprește` (danger) with the header's board icon `TablerIcons.list_numbers`. Pin text on `warning` uses `text`, on the rest `onNavy`.

The map: `TileLayer` as in `LocationMap`, a dashed `tick` line through the start pin and mission pins when there are at least two, `CameraFit.coordinates` over pins and the line when there is at least one point, else a default centre of Sibiu at zoom 13. An empty queue says `Nimic de rezolvat acum.`.

- [ ] **Step 1: Write the view tests:** the mockup's texts appear with `Necesită atenție` and the count 3; reject and approve and the chat icon call back with the right item; an empty queue shows its line; board filters report; `Sună căpitanul` calls back; no `Oprește` when `canStop` is false; a team at (0, 0) or not started has no pin. One overflow check per page at 320 px and 1.3x with long names, in light and dark.
- [ ] **Step 2: Run, watch it fail.** Step 3: **Implement.** Step 4: **Run, expect PASS.** Run: `flutter test test/features/live_room --timeout 60s`. Commit: `The live room and board pages`.

### Task 5: Wiring

**Files:**
- Create: `lib/features/live_room/screen/live_room_screen.dart`, `live_board_screen.dart`, `live_map_screen.dart`
- Modify: `lib/main.dart`, `lib/constants/routes.dart` (`Routes.liveBoard`), `lib/features/chat/screen/chat_screen.dart`, `lib/features/chat/controller/chat_controller.dart`, `lib/features/chat/widgets/image_message_bubble.dart`, `test/ui/colour_allowlist.txt`, `lib/features/event_details/controller/event_details_controller.dart`
- Delete: `lib/features/event_management/`, `lib/features/map/`

**Interfaces:**
- Consumes: Tasks 3 and 4. `showRejectPhotoDialog`, `showAppDialog`, `FullScreenImage`, `MySnackBars`.
- Produces: `Routes.eventManagement` opens `LiveRoomScreen` (argument `Event`). `Routes.liveBoard` opens `LiveBoardScreen` (argument `LiveRoomController`, plus a starting filter set before the push). `Routes.map` opens `LiveMapScreen` (`{eventId, teams}`).

- [ ] **Step 1: Implement.**
  - Screens are thin, each wrapping its view in `AnimatedBuilder` and `ClockBuilder` (30 s; the header's own `ClockBuilder` 1 s).
  - Announce uses `showTextInputDialog` (`Anunț`, `Mesajul pentru toate echipele`, `Trimite`, `emptyMessage: 'Scrie un mesaj'`), then snackbars `Anunțul a fost trimis.`, `Anunțul e în chat, dar notificarea n-a plecat.`, `Nu am putut trimite anunțul.`. On a total failure the dialog reopens with the text, or the text is shown back in the snackbar.
  - Stop uses the existing dialog text.
  - Failures: `Nu am putut salva decizia.`, `Nu am putut opri evenimentul.`, `Echipa nu are număr de telefon.`, `Nu am putut deschide telefonul.`
  - The chat: when the user is an ADMIN, `controller.clearUnread()` on open and in `dispose`.
  - `LiveMapScreen` is `LiveMap` full screen under a `ScreenBar`; a tapped pin opens the team sheet.
  - `image_message_bubble.dart`: the literals at lines 87 and 172 become tokens; lower its allow-list count.
- [ ] **Step 2: Add one overflow check per new screen where the view test does not cover it.** Run: `flutter test test/features/live_room test/ui/no_hardcoded_colors_test.dart test/features/chat --timeout 60s`. Expected PASS.
- [ ] **Step 3: Read through what has no test** (the chat clear, the routes, the map screen) and say so in the report. Commit: `The live room replaces event management`.

### Task 6: Gallery and docs

**Files:**
- Create: `lib/dev/live_room_preview.dart`
- Modify: `lib/dev/shell_previews_launcher.dart`, `lib/dev/sample_event.dart`, `docs/roadmap/mockups-roadmap.md`, `docs/features.md`, `docs/screens.md`, `docs/data-model.md`, `docs/services-and-backend.md`, `CLAUDE.md`

- [ ] **Step 1:** The preview shows both pages with the mockup's teams (Bufnițele, Vulpile, Lupii de Cetate, Cometele, Rapsodia, Pisicile) in light and dark, with an empty-event switch.
- [ ] **Step 2:** Docs: L8 says what changed; the parked list gains "a member may set `unreadByAdmin`; only an organiser may delete it; `onChatMessage` skips `announcement: true`; `onEventFinished` fires on the stop". Route table, feature map, data model and CLAUDE.md's feature list updated.
- [ ] **Step 3:** Run: `flutter analyze` (no new warnings) and `flutter test --timeout 60s`. Expected: all pass. Commit: `Live room preview and docs`.

### Final

- [ ] Whole-branch review on Opus, one fix pass, the full suite once more, merge with `--no-ff`, delete the branch, report rulings, deferred minors and what is untested.
