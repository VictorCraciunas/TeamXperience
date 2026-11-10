# Redesign step 6c: location and photo puzzles — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Mockup 07 inside 6b's game frame, in each event's own colours.
- **Location puzzle:** the map card, a compass card ("140 m", "spre nord-est · ~2 min pe jos", "mai aproape") and "Intră în cerc".
- **Photo puzzle:** the photo card with "Refă", the waiting / approved / rejected rows (the rejection with the organiser's reason) and "Chat" / "Fă altă poză".
- **Organisers:** they give a reason when they reject a photo.
- **Progress fix:** a slower phone can no longer set the team's progress back.

**Architecture:**
- **Pure logic, tested alone:**
  - compass words, walking time and the closer/farther trend;
  - the photo state of a puzzle;
  - the progress maths.
- **Plain-value views:** each puzzle type gets a view widget that takes plain values (`LocationPuzzleView`, `PhotoPuzzleView`). The stateful widgets around them keep the GPS stream and the map, or the upload and the team stream.
- **The puzzle's bar:** each puzzle type owns its bottom bar. 6b's `PuzzleBottomBar` stays for code puzzles.
- **Photo approvals:** each approval is stored as a map, `{status, reason?, url?, at}`. Plain strings from older data are still read.

**Tech Stack:** Flutter (Dart 3.7), provider, cloud_firestore, geolocator, flutter_map + latlong2 (already used), flutter_tabler_icons.

**Spec:**
- `docs/roadmap/mockups-roadmap.md`: L6.3 (location), L6.4 (photo), L1.3 (`radiusMeters`), L1.4 (`photoApprovals` values `{status, reason?, decidedAt}`), U1 (`DistanceCompass`, `PhotoStatusBanner` in `game/`) and U3.8.
- The mockup `docs/roadmap/mockups/07-location-and-photo-puzzles.html`, for layout and sizes.
- **Victor's decisions:**
  - 2026-11-05: a team waits for a photo's approval, so the mockup's "Puteți merge spre misiunea următoare" is replaced by a waiting line.
  - 2026-11-06: the look comes from the event's own puzzles. Solved missions stay closed.

## Global Constraints

- **Branch:** `redesign/step-6c-location-and-photo` from `redesign/mockups`; merge back with `--no-ff`; never push.
- **Layout and colours:**
  - Layout and sizes come from mockup 07. 1 CSS px = 1 logical px; line height 1.45.
  - No box-sizing reset: borders and padding add to a CSS width or height.
  - Colours come from `context.eventPalette`, plus the app's feedback tokens (`context.colors.success/warning/danger` and their `*Soft`) for the status rows and "mai aproape". No literal colours in `lib/features` (`test/ui/no_hardcoded_colors_test.dart`).
- **Code rules:** no `x!` in new code; one widget per file; one controller per screen; `lib/ui` never imports `lib/features`.
- **Data:** new Firestore fields are optional with defaults. The JSON import reads `radiusMeters`.
- **Docs:** `docs/data-model.md`, `docs/features.md`, `docs/screens.md`, `docs/ui-and-theme.md` and `docs/skills/event-json/SKILL.md` follow in the task that changes them.
- **Copy:**
  - Location:
    - "{d}" (as 6b's `distanceText` without "la … de tine": "140 m", "1,2 km");
    - "spre {nord|nord-est|est|sud-est|sud|sud-vest|vest|nord-vest} · ~{n} min pe jos";
    - "mai aproape" / "mai departe";
    - "Intră în cerc";
    - "Ești în cerc" when inside;
    - "Permite accesul la locație ca să vedeți cât de aproape sunteți." with "Deschide setările";
    - "Organizatorul n-a pus locul pe hartă. Puteți merge mai departe." for a puzzle without coordinates.
  - Photo:
    - "Fă poza" (nothing sent yet);
    - "Refă";
    - "Organizatorul se uită la poză" with "acum {n} min" / "chiar acum";
    - "Poza a ajuns și în chat. Mergeți mai departe după ce e aprobată.";
    - "Aprobată. Bravo!";
    - "Respinsă: „{reason}”" (or "Respinsă" with no reason);
    - "Chat";
    - "Fă altă poză";
    - "Continuă".
  - Organiser dialog: title "Respinge poza", field "Motivul (îl vede echipa)", buttons "Respinge" (disabled while empty) and "Anulează".

## Rulings made while planning (report them to Victor)

1. **Out of scope:**
   - **Badges ("+ insignă foto"):** step 7, so `badgeId` is not added now.
   - **Finishing (`finishedAt`, place, finish screen):** step 7.
   - **The distance walked (`distanceMeters`):** step 7; it feeds mockup 08.
   - **The organiser's attention queue:** step 8.
2. **Pending photos:** the mockup's "Puteți merge spre misiunea următoare" contradicts Victor's decision. The pending row stays, and the line under it becomes "Poza a ajuns și în chat. Mergeți mai departe după ce e aprobată." "Continuă" appears only once the photo is approved.
3. **The compass is absolute.** The arrow turns by `Geolocator.bearingBetween` from north ("spre nord-est"); it does not follow the phone's heading, so no new sensor package is needed. The distance on the card is the straight line, so it agrees with the arrow. The walking route from `RouteService` stays as the dashed line on the map.
4. **The closer / farther trend.** It uses the last three distance readings: it is "mai aproape" if the newest is at least 3 m less than the oldest, "mai departe" if at least 3 m more, and nothing otherwise or with fewer than three readings.
5. **The circle size:** `Puzzle.radiusMeters` (int, default 20, from 10 to 200) replaces the fixed 20 m. It is set in the puzzle's "Reguli" tab for location puzzles ("Raza cercului (m)", empty = 20) and in the JSON.
6. **A location puzzle without coordinates:** today the target becomes (0, 0), thousands of km away, and the team is stuck. Now it shows the missing-place line and enables "Intră în cerc".
7. **Location refused or off:** a card in the palette with "Deschide setările" (`Geolocator.openAppSettings`). It replaces today's white error text on the organiser's picture. "Intră în cerc" stays disabled.
8. **Photo approvals keep their key.** `Team.photoApprovals` stays `Map<String, PhotoApprovalStatus>`, so the chat and the controller helpers keep working. A new `Team.photoDetails` (`Map<String, PhotoDetail{status, reason?, url?, at?}>`) carries the rest.
   - `setPhotoApproval` writes `{status, reason?, url?, at: serverTimestamp}`.
   - A rejection without a reason is refused in the dialog, but still read.
   - The photo card shows the latest try's `url`, or the file just picked while it uploads.
9. **"Refă":** it is offered while pending and after a rejection. A new upload is a new try (`nextTryIndex`), as today. Only the latest try decides the state.
10. **The progress fix (found in 6b's review):**
    - A solved mission writes `max(stored, missionIndex + 1)` and stamps `missionCompletedAt` only when this phone is the first to solve it. Today it writes this phone's local count + 1, which a teammate a mission ahead gets set back by.
    - The puzzle number is written the same way.
    - The puzzle controller takes `missionProgress`/`puzzleNumber` from the team stream as the higher of the two. It does not move the player's screen.
11. **Bottom bars by type:**
    - code: 6b's "Indiciu" + chat;
    - location: "Indiciu" + "Intră în cerc" (mockup);
    - photo: "Chat" + the main photo action (mockup).

    The location and photo widgets draw their own bars inside a `FrameBand`.

## Review Focus

1. **The player refuses location, or turns GPS off mid-puzzle:** the card asks for access, nothing crashes, and "Intră în cerc" stays off. (Task 5 test on the view.)
2. **A location puzzle with no coordinates:** no "8 000 km", no stuck team. (Task 3 test on `locationTarget` + Task 5 view test.)
3. **A photo approved on the organiser's side while this phone shows "pending":** the state flips to approved from the team stream and "Continuă" appears, without leaving the puzzle. (Task 6 test on `photoState` + view.)
4. **Reject, then re-upload:** the older rejection's reason disappears, and the new try shows as pending. Two phones uploading make two tries, and the latest decides. (Task 6 test.)
5. **Mixed data** (old plain-string approvals next to new maps, a pending server timestamp `at: null`, a reason with quotes): everything still reads. (Task 1 test.)

---

### Task 1: Photo details, circle radius; JSON, editor and approval writes

**Files:**
- Create: `lib/model/photo_detail.dart`
- Modify:
  - Models: `lib/model/puzzle.dart` (`radiusMeters`) and `lib/model/team.dart` (`photoDetails`; `photoApprovals` also reads map values).
  - Data: `lib/backend/repo/teamRepo.dart` + `lib/service/team_service/team_service.dart` (`setPhotoApproval(eventId, teamName, key, status, {String? reason, String? url})`).
  - Callers: `lib/features/event_game/controller/image_upload_puzzle_controller.dart` (passes `url`) and `lib/features/chat/controller/chat_controller.dart` (`denyPhoto(team, key, reason)`).
  - Import: `lib/service/event_service/event_json_import.dart` (`radiusMeters`, 10–200).
  - Editor: `puzzle_rules_controller.dart` + `puzzle_rules_form.dart` ("Raza cercului (m)", location puzzles only; cleared on type change).
  - Docs: `docs/data-model.md`, `docs/skills/event-json/SKILL.md`.
- Test: `test/model/photo_detail_test.dart`, `test/model/mission_puzzle_rules_test.dart` (add), `test/service/event_service/event_json_import_test.dart` (add), `test/features/admin/create_event/puzzle_rules_controller_test.dart` + `puzzle_rules_form_test.dart` (add).

**Interfaces:**
- Produces:
  - `class PhotoDetail { final PhotoApprovalStatus status; final String? reason; final String? url; final DateTime? at; }`, with `static PhotoDetail? fromValue(Object? value)`:
    - a plain status string becomes a detail with only `status`;
    - a map is read as `{status, reason, url, at}` (`at`: a Timestamp or DateTime, else null);
    - an unknown status gives null.
  - `Team.photoDetails` (`Map<String, PhotoDetail>`).
  - `Team.photoApprovals` still holds every readable status.
  - `toJson` writes `photoApprovals` as maps (`{status, reason?, url?}`; `at` is left for the server).
  - `Puzzle.radiusMeters` (`int`, default 20; below 10 or not whole reads as 20); `toJson` writes it only when it is not 20.

- [ ] **Step 1: Write the failing tests:**
  - `PhotoDetail.fromValue`:
    - `'pending'` gives a pending detail with no reason;
    - `{'status': 'denied', 'reason': 'Nu se vede „ceasul”', 'url': 'https://x/y.jpg', 'at': Timestamp}` reads every field;
    - `{'status': 'approved', 'at': null}` has `at` null;
    - `'maybe'` and `{'status': 7}` give null.
  - `Team.fromMap` with one old string entry and one new map entry: both are in `photoApprovals` and `photoDetails`; `isPuzzleApproved` works with the map form.
  - `radiusMeters` round-trips; defaults to 20; `0` reads as 20.
  - The import:
    - reads `"radiusMeters": 35`;
    - reports `5` as an error with its path.
  - The rules form:
    - shows "Raza cercului (m)" for a location puzzle only;
    - `"35"` saves 35;
    - empty saves 20;
    - `"500"` is an error and saves 20;
    - changing the type resets it.
- [ ] **Step 2: Run; expect failures.** `flutter test test/model test/service/event_service/event_json_import_test.dart test/features/admin/create_event`
- [ ] **Step 3: Implement.** Wire the writes:
  - the upload passes `url`;
  - `approvePhoto` passes no reason;
  - `denyPhoto` takes the reason (the dialog comes in Task 7; until then the bubble passes `''`).
- [ ] **Step 4: Run the same; expect PASS; then `flutter test`; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "Photo approvals carry reason, picture and time; location puzzles get their circle size"`

---

### Task 2: Progress that never goes back

**Files:**
- Create: `lib/features/event_game/logic/mission_progress.dart`
- Modify: `lib/features/event_game/controller/puzzle_game_controller.dart` (`navigate`, `_absorb`)
- Test: `test/features/event_game/mission_progress_test.dart`

**Interfaces:**
- `({int progress, int? stamp}) solvedMission(int missionIndex, int storedProgress)`:
  - `progress = max(storedProgress, missionIndex + 1)`;
  - `stamp = missionIndex` only when `storedProgress <= missionIndex`, else null.
- `int nextPuzzleNumber(int selected, int storedPuzzleNumber, {required bool sameMission})`: `max(selected + 1, storedPuzzleNumber)` when on the stored mission, else `selected + 1`.
- `TeamService.updateMissionProgress` takes the stamp as `completedMission`. With a null stamp, nothing is stamped.

- [ ] **Step 1: Write the failing tests:**
  - `solvedMission(3, 3)` gives `(4, 3)`.
  - `solvedMission(3, 5)` gives `(5, null)`: a teammate is ahead, so the progress is not set back and nothing is re-stamped.
  - `solvedMission(0, 0)` gives `(1, 0)`.
  - `nextPuzzleNumber(0, 2, sameMission: true)` gives 2.
  - `nextPuzzleNumber(2, 1, sameMission: true)` gives 3.
- [ ] **Step 2: Run; expect failures.**
- [ ] **Step 3: Implement.**
  - `navigate` uses both functions.
  - `_absorb` raises `team.missionProgress` and `team.puzzleNumber` to the stream's values when those are higher. It never lowers them and never changes `selectedPuzzleNotifier`.
- [ ] **Step 4: Run; expect PASS; then `flutter test`; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "A slower phone never sets the team's progress back"`

---

### Task 3: Location logic

**Files:**
- Create: `lib/features/event_game/logic/location_texts.dart`
- Test: `test/features/event_game/location_texts_test.dart`

**Interfaces:**
- `String compassWord(double bearing)`: 8 sectors of 45° centred on north (−22.5..22.5 is "nord"). It accepts −180..360 and returns "nord", "nord-est", "est", "sud-est", "sud", "sud-vest", "vest" or "nord-vest".
- `String walkLine(double meters, double bearing)`: "spre nord-est · ~2 min pe jos", with minutes = `ceil(meters / 80)` and at least 1.
- `String shortDistance(double meters)`: "140 m" (rounded to ten), from 995 m "1,2 km"; under 20 m "câțiva metri".
- `enum DistanceTrend { closer, farther }` and `DistanceTrend? trendOf(List<double> readings)` (ruling 4: only the last three count).
- `String? trendLabel(DistanceTrend? trend)`: "mai aproape" / "mai departe".
- `({double lat, double lng})? locationTarget(Puzzle puzzle)`: null unless both coordinates are set.
- `bool insideCircle(double meters, int radius)`: `meters <= radius`.

- [ ] **Step 1: Write the failing tests:**
  - `compassWord`: 0 → "nord", 40 → "nord-est", 90 → "est", −90 → "vest", 337.6 → "nord", 200 → "sud".
  - `walkLine(140, 40)` → "spre nord-est · ~2 min pe jos"; `walkLine(10, 0)` → "spre nord · ~1 min pe jos".
  - `shortDistance`: 143 → "140 m", 1234 → "1,2 km", 12 → "câțiva metri".
  - `trendOf`:
    - `[150, 146, 140]` → closer;
    - `[140, 141, 142]` → null (under 3 m);
    - `[140, 150]` → null;
    - `[200, 150, 152, 160]` → farther (only the last three count).
  - `locationTarget`: a puzzle with only a latitude gives null.
  - `insideCircle(20, 20)` is true.
- [ ] **Step 2: Run; expect failures.**
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "Location logic: compass words, walking time, trend, circle"`

---

### Task 4: Shared game pieces for mockup 07

**Files:**
- Create in `lib/ui/components/game/`:
  - `game_filled_button.dart`: the mockup's main button. Accent fill, `onAccent` w500 12, radius 12, padding 10, optional 15 px icon 4 px before the label. Disabled: the ink at 12 % fill and `muted` text.
  - `distance_compass.dart`: the `.pc` card (surface, 1 px `border`, radius 14, padding 10/12 plus the border, gap 12):
    - a 46 px accent circle with a 24 px `onAccent` `arrow_up`, turned by the bearing;
    - "140 m" at 22 w500, line height 1.1;
    - the walk line at 11, ink 80 %;
    - the trend at 11 w500 in `context.colors.success` ("mai aproape") or `context.colors.danger` ("mai departe").
  - `photo_status_banner.dart`: the `.st` row (radius 12, padding 7/10, gap 8, w500, a 16 px icon, an optional trailing text at 11 w400).
- Modify: `docs/ui-and-theme.md`.
- Test: `test/ui/components/game_pieces_07_test.dart`

**Interfaces:**
- `GameFilledButton({required String label, IconData? icon, VoidCallback? onTap})`
- `DistanceCompass({required String distance, required String line, required double bearing, String? trend, bool closer = true})`: `bearing` is in degrees, and the arrow turns by `bearing * pi / 180`.
- `enum PhotoBannerKind { waiting, approved, rejected }`
- `PhotoStatusBanner({required PhotoBannerKind kind, required String text, String? trailing})`:
  - waiting: `warningSoft` fill, `warning` text, `clock` icon;
  - approved: `successSoft` / `success`, `circle_check`;
  - rejected: `dangerSoft` / `danger`, `circle_x`.

- [ ] **Step 1: Write the failing tests:**
  - `GameFilledButton`:
    - the accent fill and the `onAccent` label;
    - disabled: the ink 12 % fill, `muted` text, and a tap does nothing.
  - `DistanceCompass`:
    - the circle is 46 px;
    - "140 m" is 22 w500;
    - the arrow's `Transform.rotate` angle is 40° in radians;
    - the trend colour;
    - no trend: no text.
  - `PhotoStatusBanner`: each kind's fill, text colour and icon; the trailing text.
  - Everything follows a black-and-green palette.
  - 320 px at 1.3×, no overflow.
- [ ] **Step 2: Run; expect failures.**
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "Game pieces of mockup 07: filled button, distance compass, photo status"`

---

### Task 5: The location puzzle

**Files:**
- Create in `lib/features/event_game/widgets/`:
  - `location_puzzle_view.dart`: the plain-value view. Its children:
    - the map card (210 tall, radius 14, 1 px `border`, margin 12/14);
    - the `DistanceCompass` (margin 10/14), or the "Ești în cerc" `PhotoStatusBanner(approved)` when inside;
    - the bar in a `FrameBand`: `GameOutlineButton` "Indiciu" (flex 1) + `GameFilledButton` "Intră în cerc" (flex 1.4).

    It also has two alternative states: the refused-location card and the missing-place card.
  - `location_map.dart`: the `flutter_map`:
    - OSM tiles;
    - a `CircleLayer` of `radiusMeters` (accent at 12 % fill, a 2 px accent border);
    - a 17 px accent flag at the target;
    - the walking route as a 2.5 px accent dashed polyline;
    - the player as a 16 px `context.colors.accent` dot with a 3 px `context.colors.panel` ring;
    - a `RoundIconButton(current_location)` at top-left 8 that fits both points.
- Modify:
  - `lib/features/event_game/widgets/geolocation_puzzle_widget.dart`: it keeps the GPS stream, the readings list (last three), the distance, the bearing and the route, and builds `LocationPuzzleView`. It gains the params `onHint` (VoidCallback?) and `radius`, from `puzzle.radiusMeters`.
  - `lib/features/event_game/screen/puzzle_game_screen.dart`: it passes `onHint` (`controller.canUseHint ? _openHint : null`). The screen's own bottom bar shows only for code / other types.
- Test: `test/features/event_game/location_puzzle_view_test.dart`

**Interfaces:**
- `enum LocationViewState { tracking, waiting, denied, noTarget }`. `waiting` means there is no fix yet; it shows the map and a disabled button, with no compass.
- `LocationPuzzleView({required LocationViewState state, required Widget map, double? meters, double? bearing, DistanceTrend? trend, required bool inside, required VoidCallback onEnter, VoidCallback? onHint, required VoidCallback onOpenSettings})`
- "Intră în cerc" is enabled when `inside` or `state == noTarget`, and calls `onEnter`. A completed mission keeps today's behaviour (the widget calls `onSolved` straight away).

- [ ] **Step 1: Write the failing tests** (the `map` slot is a `SizedBox`):
  - Tracking at 140 m, bearing 40, closer: "140 m", "spre nord-est · ~2 min pe jos" and "mai aproape"; "Intră în cerc" is disabled.
  - Inside: "Ești în cerc" with "Intră în cerc" enabled, which calls `onEnter`.
  - Denied: the access line and "Deschide setările" (calls back); no map; "Intră în cerc" is disabled.
  - No target: the missing-place line; "Intră în cerc" is enabled.
  - Waiting: no compass; the button is disabled.
  - "Indiciu" is greyed when `onHint` is null.
  - Neon palette; 320 px at 1.3×, no overflow.
- [ ] **Step 2: Run; expect failures.**
- [ ] **Step 3: Implement**; rebuild the stateful widget on top of the view.
- [ ] **Step 4: Run; expect PASS; then `flutter test`; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "Location puzzle as mockup 07: map, compass, trend, the circle"`

---

### Task 6: The photo puzzle

**Files:**
- Create:
  - `lib/features/event_game/logic/photo_state.dart`;
  - `lib/features/event_game/widgets/image_upload/photo_puzzle_view.dart`;
  - `lib/features/event_game/widgets/image_upload/photo_card.dart`. This is the `.pc` card with padding 8: the 150 px picture with radius 10, from a `File` or a URL, falling back to a camera prompt "Fă poza" while empty. The "Refă" pill sits top-right at 8 (surface 92 %, radius 99, padding 2/9, 11 w500, a 12 px `refresh` icon), then the banner and the waiting line.
- Modify:
  - `image_upload_puzzle_widget.dart`: builds the view from the stream and the controller.
  - `image_upload_puzzle_controller.dart`: `latest(Team)` returns the latest try's key and detail.
  - Remove: `image_upload_status_banner.dart`, `image_upload_action_button.dart`, `image_upload_picker.dart`, `image_upload_preview.dart`, once they have no users.
  - Docs: `docs/screens.md`, `docs/features.md`.
- Test: `test/features/event_game/photo_state_test.dart`, `test/features/event_game/photo_puzzle_view_test.dart`

**Interfaces:**
- `enum PhotoStep { none, uploading, waiting, approved, rejected }`
- `({PhotoStep step, PhotoDetail? detail}) photoState(Team team, int mission, int puzzle, {required bool uploading})`:
  - uploading wins;
  - otherwise the latest try (the highest try index under `Team.approvalKeyPrefix`) decides.
- `String sentAgo(DateTime? at, DateTime now)`: "chiar acum" under 1 min, else "acum {n} min" (and "acum {h} h" from 60 min); "" when `at` is null.
- `String rejectedLine(String? reason)`: "Respinsă: „…”", or "Respinsă".
- `PhotoPuzzleView({required PhotoStep step, ImageProvider? picture, String? reason, DateTime? sentAt, required DateTime now, required VoidCallback onTakePhoto, required VoidCallback onContinue, required VoidCallback onChat})`. The bar shows "Chat" plus:
  - none: "Fă poza" (camera);
  - uploading: disabled "Se trimite…";
  - waiting: "Fă altă poză";
  - approved: "Continuă";
  - rejected: "Fă altă poză".

  "Refă" shows while waiting or rejected and calls `onTakePhoto`.

- [ ] **Step 1: Write the failing tests:**
  - `photoState`:
    - no tries → none;
    - try 0 denied plus try 1 pending → waiting, with try 1's detail;
    - try 0 approved → approved;
    - uploading over a denied try → uploading;
    - keys of another puzzle are ignored.
  - `sentAgo`: 30 s → "chiar acum"; 4 min → "acum 4 min"; null → "".
  - `rejectedLine("Nu se vede ceasul")` → "Respinsă: „Nu se vede ceasul”".
  - The view:
    - waiting shows "Organizatorul se uită la poză", "acum 1 min", the waiting line and "Refă";
    - approved shows "Aprobată. Bravo!" and "Continuă" (which calls back), with no "Refă";
    - rejected shows the reason and "Fă altă poză";
    - none shows the camera prompt;
    - uploading has a disabled main button;
    - "Chat" calls back;
    - neon palette; 320 px at 1.3×, no overflow.
- [ ] **Step 2: Run; expect failures.**
- [ ] **Step 3: Implement**; the widget passes `FileImage(selected)` while uploading, else a `NetworkImage(detail.url)` when there is one.
- [ ] **Step 4: Run; expect PASS; then `flutter test`; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "Photo puzzle as mockup 07: the picture, waiting, approved, rejected with its reason"`

---

### Task 7: The organiser gives a reason

**Files:**
- Create: `lib/features/chat/widgets/reject_photo_dialog.dart` (`Future<String?> showRejectPhotoDialog(BuildContext context)`)
- Modify:
  - `lib/features/chat/widgets/message_stream.dart`: "Respinge" opens the dialog; `denyPhoto` is called with the reason; cancel does nothing.
  - `lib/features/chat/widgets/image_message_bubble.dart`: the rejected chip shows the reason under the picture, at 12 in `context.colors.danger`, when there is one.
- Test: `test/features/chat/reject_photo_dialog_test.dart`

- [ ] **Step 1: Write the failing tests:**
  - The dialog shows "Respinge poza" and the field.
  - "Respinge" is disabled while the field is empty or blank, and enabled after typing.
  - It returns the trimmed text.
  - "Anulează" returns null.
  - The bubble with a rejected status and a reason shows the reason.
- [ ] **Step 2: Run; expect failures.**
- [ ] **Step 3: Implement**; pass the reason down from `team.photoDetails[key]?.reason`.
- [ ] **Step 4: Run; expect PASS; then `flutter test`; expect PASS.**
- [ ] **Step 5: Commit** — `git commit -m "Rejecting a photo needs a reason the team sees"`

---

### Task 8: Gallery previews and docs

**Files:**
- Create: `lib/dev/location_puzzle_preview.dart` (tracking / inside / denied, parchment / neon) and `lib/dev/photo_puzzle_preview.dart` (waiting / approved / rejected, parchment / neon). Both are inside the 6b header and segments, with a placeholder map and picture.
- Modify:
  - `lib/dev/sample_event.dart`: mission 5 ("Unde dorm clopotele") gets a location puzzle with coordinates, `radiusMeters: 30` and its question; mission 3 ("Turnul Sfatului") gets its photo question.
  - `lib/dev/shell_previews_launcher.dart` ("Locație", "Poză").
  - Docs: `docs/screens.md`, `docs/features.md`, `docs/roadmap/mockups-roadmap.md` (6c done; the step 3b rules note for `photoApprovals` maps and the reason).
- Test: `test/dev/shell_previews_test.dart` (both previews, every state, both looks, light and dark, no exception; the launcher opens them).

- [ ] **Step 1: Write the failing test.**
- [ ] **Step 2: Run; expect failure.**
- [ ] **Step 3: Implement and update the docs.**
- [ ] **Step 4: Run `flutter test` and `flutter analyze`; expect PASS and no new issues.**
- [ ] **Step 5: Commit** — `git commit -m "Gallery: location and photo puzzles in two looks; docs"`
