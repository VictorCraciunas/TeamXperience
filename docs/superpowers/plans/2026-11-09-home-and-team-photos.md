# Home with Pictures, Team Photos and Memories Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Acasă full and picture-led in every situation, let teams take optional start and final photos, and turn Amintiri into a real album.

**Architecture:** Team photos live on the team document (`teamPhotos.{start|finish}`). Memories read their album from the team when shown, so no Cloud Function changes. Home decides what to show in pure functions; a small controller feeds it the memory and season data.

**Tech Stack:** Flutter (Dart ^3.7.2, so `.nonNulls`, no null-aware list elements), provider, Firestore, Firebase Storage, `image_picker`, `cached_network_image`; emulator tests for `firestore.rules`.

**Spec:** `docs/superpowers/specs/2026-11-09-home-and-team-photos-design.md`

## Global Constraints

- Work on branch `redesign/home-team-photos`, cut from `redesign/mockups`. Merge with `--no-ff` into `redesign/mockups`. Not into `main`.
- Never push. Never run `firebase deploy` (no `--dry-run` either). Install nothing new; `image_picker` is already a dependency.
- No Cloud Functions change.
- Lighter testing: tests first for logic and data; one overflow check per screen; no exact size or colour tests; full suite before merging; a final review of the whole branch.
- Follow `CLAUDE.md`: no `x!` in new code, one widget per file, screens stay thin, colours from `context.colors`, no literal colours in `lib/features`.
- Section titles are plain text (`SectionHeader`), with no dot.
- Many files are CRLF: keep each file's line endings.
- Copy is Romanian and exactly as written here.
- End every commit message with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- App tests: `flutter test --timeout 60s --reporter expanded <path>`. Rules tests: `npm --prefix functions test` (reuses an emulator on 127.0.0.1:8080).

## Review Focus

1. Camera cancelled, permission denied or upload failed: the card stays usable, a line explains, and "Pornește jocul" still works. Test in Task 2.
2. A memory whose team can't be read (network error, team removed): it falls back to `photoUrls`, then the event's picture, then the icon, and never throws. Test in Task 3.
3. An event with no picture or a broken picture link: flat colour and route line, no error box. Overflow test in Task 6.
4. A team that finished inside the start-code window: Home shows "Ați terminat" and never asks for the code; an active game in another event wins over it. Test in Task 5.
5. Long event and team names at 1.3× text on a 320 px screen: nothing overflows. Overflow tests in Tasks 4, 6, 7 and 8.

---

### Task 1: Team photos in the data and rules

**Files:**
- Create: `lib/enums/team_photo_slot.dart`
- Modify: `lib/model/team.dart`, `lib/backend/repo/teamRepo.dart`, `lib/service/team_service/team_service.dart`, `firestore.rules`, `functions/src/test/rules.emu.test.ts`, `docs/data-model.md`
- Test: `test/model/team_photos_test.dart`

**Interfaces:**
- Produces: `enum TeamPhotoSlot { start, finish }`; `Team.startPhotoUrl` and `Team.finishPhotoUrl` (`String?`); `TeamService.setTeamPhoto(String eventId, String teamName, TeamPhotoSlot slot, String url, String uid) → Future<void>`.

- [ ] **Step 1: Create the branch**

```bash
git switch -c redesign/home-team-photos redesign/mockups
```

- [ ] **Step 2: Write the failing model test**

```dart
test('reads both photos', () {
  final team = Team.fromMap(base..['teamPhotos'] = {'start': {'url': 'a', 'by': 'u1'}, 'finish': {'url': 'b', 'by': 'u2'}});
  expect(team.startPhotoUrl, 'a');
  expect(team.finishPhotoUrl, 'b');
});
test('older teams and bad data have none', () {
  expect(Team.fromMap(base).startPhotoUrl, isNull);
  expect(Team.fromMap(base..['teamPhotos'] = 'x').finishPhotoUrl, isNull);
  expect(Team.fromMap(base..['teamPhotos'] = {'start': {'url': 7}}).startPhotoUrl, isNull);
});
test('toJson never writes them', () {
  final team = Team.fromMap(base..['teamPhotos'] = {'start': {'url': 'a'}});
  expect(team.toJson().containsKey('teamPhotos'), isFalse);
});
```

`base` is a minimal team map, as in the existing team model tests.

- [ ] **Step 3: Run it and watch it fail**

Run: `flutter test --timeout 60s test/model/team_photos_test.dart`. Expected: FAIL, `startPhotoUrl` isn't defined.

- [ ] **Step 4: Implement**

Add the enum and the two fields, following `startedAt` (read in `fromMap`, never in `toJson`). `TeamRepo.setTeamPhoto` updates `{'teamPhotos.${slot.name}': {'url': url, 'by': uid, 'at': FieldValue.serverTimestamp()}}`. `TeamService.setTeamPhoto` forwards to it.

- [ ] **Step 5: Run it and watch it pass**

Same command. Expected: PASS.

- [ ] **Step 6: Write the failing rules test, beside "walked: your own, only more"**

```ts
test("team photos: any member, one at a time, in their own name", async () => {
  const photo = (by: string) => ({url: "a", by, at: serverTimestamp()});
  await assertSucceeds(member().update({"teamPhotos.start": photo("u2")}));
  await assertSucceeds(member().update({"teamPhotos.start": photo("u2")}));
  await assertSucceeds(member().update({"teamPhotos.finish": photo("u2")}));
  await assertFails(member().update({"teamPhotos.middle": photo("u2")}));
  await assertFails(member().update({"teamPhotos.start": photo("u1")}));
  await assertFails(member().update({"teamPhotos.start": {url: "a", by: "u2", at: serverTimestamp(), extra: 1}}));
  await assertFails(member().update({"teamPhotos.start": {url: 7, by: "u2", at: serverTimestamp()}}));
  await assertFails(member().update({"teamPhotos.start": {url: "a", by: "u2", at: Timestamp.fromDate(new Date("2020-01-01"))}}));
  await assertFails(member().update({"teamPhotos.start": FieldValue.delete()}));
});
```

Use the file's existing server-time helper, and name `member()` as the file does. Also add one `assertFails` for a signed-in non-member, using the same helper as the file's other non-member cases.

- [ ] **Step 7: Run it and watch it fail**

Run: `npm --prefix functions test`. Expected: this test FAILS, the others pass.

- [ ] **Step 8: Add the rule**

Add `'teamPhotos'` to the `memberUpdateOk` key list and `&& (!keys.hasAny(['teamPhotos']) || teamPhotosOk())`. The new function, next to `walkedOk`, uses the file's `after`/`before` helpers:

```
function teamPhotosOk() {
  let d = after('teamPhotos').diff(before('teamPhotos'));
  let slot = d.affectedKeys();
  return slot.size() == 1
    && slot.hasOnly(['start', 'finish'])
    && d.removedKeys().size() == 0
    && (('start' in slot && photoValueOk(after('teamPhotos').start))
        || ('finish' in slot && photoValueOk(after('teamPhotos').finish)));
}
function photoValueOk(p) {
  return p.keys().hasOnly(['url', 'by', 'at']) && p.url is string && p.by == request.auth.uid && p.at == request.time;
}
```

- [ ] **Step 9: Run the rules tests**

Run: `npm --prefix functions test`. Expected: all pass, and the count goes up by one.

- [ ] **Step 10: Document and commit**

Add `teamPhotos` to the team section of `docs/data-model.md`.

```bash
git add lib/enums/team_photo_slot.dart lib/model/team.dart lib/backend/repo/teamRepo.dart lib/service/team_service/team_service.dart firestore.rules functions/src/test/rules.emu.test.ts docs/data-model.md test/model/team_photos_test.dart
git commit -m "Teams can hold a start and a final photo"
```

### Task 2: Taking a team photo

**Files:**
- Create: `lib/features/team_photo/controller/team_photo_controller.dart`
- Modify: `lib/utils/image_helper.dart`, `ios/Runner/Info.plist`, `docs/platform-and-config.md`
- Test: `test/features/team_photo/team_photo_controller_test.dart`

**Interfaces:**
- Consumes: `TeamPhotoSlot`, `TeamService.setTeamPhoto`.
- Produces: `ImageHelper.takePhoto() → Future<File?>`; `TeamPhotoController({required String eventId, required String teamName, required TeamPhotoSlot slot, required String uid, Future<File?> Function()? take, Future<String?> Function(File file, String path)? upload, Future<void> Function(String url)? save})` extending `ChangeNotifier`, with `busy` (`bool`), `error` (`String?`), `takeAndSend() → Future<void>`, `static const failedLine = 'Poza nu s-a trimis. Încearcă din nou.'`.

- [ ] **Step 1: Write the failing tests**

```dart
test('uploads under the team and slot, then saves the link', ...);   // path == 'team_photos/Vulpile_start', saved url == uploaded url
test('cancelling the camera changes nothing', ...);                  // take → null: no upload, no save, no error
test('a camera error shows the line', ...);                          // take throws: error == failedLine, busy false
test('a failed upload shows the line and saves nothing', ...);       // upload → null
test('a failed save shows the line', ...);                           // save throws
test('a second tap while sending does nothing', ...);                // take called once
test('a retake clears the old error', ...);                          // after failure, success: error null
```

Follow the structure of the existing `ImageUploadPuzzleController` tests.

- [ ] **Step 2: Run them and watch them fail**

Run: `flutter test --timeout 60s test/features/team_photo/team_photo_controller_test.dart`. Expected: FAIL, the controller doesn't exist.

- [ ] **Step 3: Implement**

Build the controller like `ImageUploadPuzzleController`. The defaults are `ImageHelper.takePhoto`, `ImageRepo().uploadImage(file, eventId, path)` and `TeamService().setTeamPhoto`. The path is `team_photos/${teamName}_${slot.name}`, so a retake replaces the file.

`takePhoto` uses `ImageSource.camera`, `maxWidth: 1600`, `imageQuality: 75`. Leave `pickImage` as it is.

Add to `ios/Runner/Info.plist`:
- `NSCameraUsageDescription`: `Ai nevoie de cameră pentru pozele echipei din joc.`
- `NSPhotoLibraryUsageDescription`: `Alegi din galerie pozele trimise în joc.`

- [ ] **Step 4: Run them and watch them pass**

Same command. Expected: PASS.

- [ ] **Step 5: Document and commit**

Note the two iOS texts in `docs/platform-and-config.md`.

```bash
git add lib/features/team_photo lib/utils/image_helper.dart ios/Runner/Info.plist docs/platform-and-config.md test/features/team_photo
git commit -m "Taking and sending a team photo"
```

### Task 3: The album

**Files:**
- Create: `lib/features/team_photo/logic/team_album.dart`
- Modify: `lib/features/finish/logic/finish_recap.dart`
- Test: `test/features/team_photo/team_album_test.dart`

**Interfaces:**
- Produces:
  - `class AlbumPhoto { const AlbumPhoto(this.url, {this.label}); final String url; final String? label; }`
  - `List<({int mission, String url})> approvedPuzzlePhotos(Team team)` in `finish_recap.dart`, with the existing `approvedPhotos` built from it
  - `List<AlbumPhoto> teamAlbum(Team team)`
  - `Future<List<AlbumPhoto>> memoryAlbum(Memory memory, Future<Team?> Function(String eventId) findTeam)`
  - `String? memoryThumbnail(List<AlbumPhoto> album, String? eventPicture)`

- [ ] **Step 1: Write the failing tests**

```dart
test('start, puzzle photos by mission, final, with labels', () {
  final album = teamAlbum(team(start: 's', finish: 'f', approved: {'2_0_1': 'b', '0_1_5': 'a'}));
  expect(album.map((p) => p.url), ['s', 'a', 'b', 'f']);
  expect(album.map((p) => p.label), ['Start', 'Misiunea 1', 'Misiunea 3', 'Final']);
});
test('only what exists', () => expect(teamAlbum(team(finish: 'f')).map((p) => p.label), ['Final']));
test('the team has none: the memory photos, without labels', () async {
  final album = await memoryAlbum(memoryWith(['x']), (_) async => team());
  expect(album.single.url, 'x');
  expect(album.single.label, isNull);
});
test('the team cannot be read: the memory photos, without throwing', () async {
  final album = await memoryAlbum(memoryWith(['x']), (_) async => throw Exception());
  expect(album.single.url, 'x');
});
test('no team: the memory photos', () async {
  expect((await memoryAlbum(memoryWith(['x']), (_) async => null)).length, 1);
});
test('thumbnail: first photo, then the event picture, then nothing', () {
  expect(memoryThumbnail(const [AlbumPhoto('a'), AlbumPhoto('b')], 'e'), 'a');
  expect(memoryThumbnail(const [], 'e'), 'e');
  expect(memoryThumbnail(const [], null), isNull);
  expect(memoryThumbnail(const [], ''), isNull);
});
```

- [ ] **Step 2: Run them and watch them fail**

Run: `flutter test --timeout 60s test/features/team_photo/team_album_test.dart`. Expected: FAIL, the file doesn't exist.

- [ ] **Step 3: Implement, keeping `approvedPhotos`' results unchanged**

- [ ] **Step 4: Run these and the finish tests**

Run: `flutter test --timeout 60s test/features/team_photo test/features/finish`. Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/team_photo lib/features/finish/logic/finish_recap.dart test/features/team_photo
git commit -m "A team's album: start, puzzles, final"
```

### Task 4: Photo cards on the start and finish screens

**Files:**
- Create: `lib/features/enter_code/widgets/start_photo_card.dart`, `lib/features/finish/widgets/finish_photo_card.dart`, `lib/features/team_photo/widgets/album_strip.dart`
- Modify: `lib/features/enter_code/widgets/start_code_view.dart`, `lib/features/enter_code/screen/enter_code.dart`, `lib/features/finish/widgets/finish_view.dart`, `lib/features/finish/screen/finish_screen.dart`, `docs/screens.md`
- Delete: `lib/features/finish/widgets/photo_strip.dart`, once nothing uses it
- Test: extend `test/features/enter_code/start_code_view_test.dart` and `test/features/finish/finish_view_test.dart`

**Interfaces:**
- Consumes: `TeamPhotoController`, `teamAlbum`, `AlbumPhoto`.
- Produces: `AlbumStrip({required List<AlbumPhoto> photos, ValueChanged<AlbumPhoto>? onTap})`: up to three tiles, with labels where present, and "+N" on the third when there are more. `StartCodeView` gains `Widget? photoCard`. `FinishView` gains `Widget? photoCard` and takes `List<AlbumPhoto> photos`.

- [ ] **Step 1: Write the failing view tests**

```dart
testWidgets('the start card sits above the start button and never disables it', ...);
testWidgets('the finish strip shows labels', ...);          // finds 'Start' and 'Misiunea 3'
testWidgets('start screen with the card fits 320 px at 1.3x text', ...);
testWidgets('finish screen with the card fits 320 px at 1.3x text', ...);
```

- [ ] **Step 2: Run them and watch them fail**

Run: `flutter test --timeout 60s test/features/enter_code/start_code_view_test.dart test/features/finish/finish_view_test.dart`. Expected: FAIL.

- [ ] **Step 3: Build the cards, as drawn on the canvas ("Start screen", "Finish screen")**

Copy:
- Start card, no photo: `Poza echipei`, `Opțional. O găsiți la Amintiri.`, button `Fă poza`.
- Start card, with a photo: the 44 px thumbnail, `Poza echipei`, button `Refă poza`.
- Finish card, no photo: `O poză de final?`, `Opțional. Rămâne la Amintiri.`, `Fă poza`.
- Finish card, with a photo: the thumbnail, `Poza de final`, `Refă poza`.
- Both show `controller.error` under the text, and a small spinner on the button while `busy`.

The start card uses the navy colours (`onNavy`, `tickOnNavy`), the finish card `context.eventPalette`.

`EnterCode` creates one `TeamPhotoController` once the team and uid are known, and disposes it. The card shows for a late teammate too (`started` true). `FinishScreen` does the same. The finish strip takes `teamAlbum(controller.team)`, and tapping a tile opens `FullScreenImage`.

- [ ] **Step 4: Run them and watch them pass**

Same command. Expected: PASS.

- [ ] **Step 5: Document and commit**

Update the `StartCodeView` and finish entries in `docs/screens.md`.

```bash
git add lib/features/enter_code lib/features/finish lib/features/team_photo docs/screens.md test/features/enter_code test/features/finish
git commit -m "Optional team photos on the start and finish screens"
```

### Task 5: What Home shows

**Files:**
- Create: `lib/features/home/logic/home_content.dart`, `lib/features/home/controller/home_extras_controller.dart`
- Modify: `lib/features/home/logic/home_hero.dart`, `lib/features/home/logic/hero_from_providers.dart`, `lib/features/home/widgets/home_hero_section.dart`, `lib/state_management/user_registered_events.dart`
- Test: `test/features/home/home_content_test.dart`, `test/features/home/home_extras_controller_test.dart`, extend `test/features/home/home_hero_test.dart`

**Interfaces:**
- Consumes: `memoryAlbum`, `seasonOf`, `AlbumPhoto`.
- Produces:
  - `class FinishedHero extends HomeHero { final Event event; final Team team; }`, with signature `'finished:$eventId'`
  - `resolveHomeHero` gains `Event? finishedEvent`, `Team? finishedTeam`; priority is live → finished → soon → upcoming → recommended → none
  - `UserEventsProvider.finishedEvent`, `.finishedTeam`
  - `bool isNewPlayer(int games, int xp)`: both zero
  - `bool memoryGoesFirst(Memory? newest, DateTime now)`: event date no more than 3 days ago
  - `List<Event> newEventsToShow(List<Event> open, HomeHero hero)`: without the recommended event, at most 4
  - `List<Event> pastGamesToShow(List<Event> past, DateTime now)`: public, over, at most 4
  - `Stire? latestNews(List<Stire> news, DateTime now)`: newest not in the future; a null date is oldest
  - `({int place, SeasonStanding standing})? seasonSpot(List<SeasonStanding> standings, Set<String> myCrewIds)`: best placed, or null
  - `HomeExtrasController({required Stream<List<Memory>> Function(String uid) memories, required Stream<List<Crew>> Function(String uid) crews, required Stream<List<SeasonStanding>> standings, required String seasonName, required Future<Team?> Function(String eventId, String uid) findTeam})` with `watch(String? uid)` (safe to call repeatedly), `Memory? memory`, `List<AlbumPhoto> album`, `seasonSpot`, `seasonName`. `Home` passes the id and name from `seasonOf(DateTime.now())`

- [ ] **Step 1: Write the failing tests**

```dart
// home_hero_test
test('a finished team sees that, not the start code', ...);       // finishedEvent set and event in the enter window → FinishedHero
test('a game in play wins over a finished one', ...);             // both → LiveHero
test('an event that is over is not "finished" any more', ...);    // isOver → next rule

// home_content_test
test('new player: no games and no XP', ...);                      // (0,0) true; (1,0) false; (0,50) false
test('memory goes first for 3 days', ...);                        // exactly 3 days true; 3 days 1 min false; null false; future date false
test('the recommended event is not repeated', ...);               // RecommendedHero(a), open [a,b] → [b]
test('at most 4 new events', ...);
test('past games: public and over, at most 4', ...);              // private and still-running left out
test('latest news skips the future', ...);                        // future date ignored; empty → null
test('season spot: the best-placed crew', ...);                   // crews at 3rd and 7th → place 3; none in the list → null

// home_extras_controller_test
test('follows the newest memory and loads its album', ...);
test('a new uid replaces the old watch; null stops', ...);
test('errors in the streams leave things empty', ...);
```

- [ ] **Step 2: Run them and watch them fail**

Run: `flutter test --timeout 60s test/features/home/home_content_test.dart test/features/home/home_extras_controller_test.dart test/features/home/home_hero_test.dart`. Expected: FAIL.

- [ ] **Step 3: Implement**

In `loadActiveEvent`, check every past event. An active team returns as today, and that wins. Otherwise remember the first team with `hasFinished` in an event not over, and set `finishedEvent` and `finishedTeam`. Clear both when none applies.

`HomeHeroSection` needs a `FinishedHero` case, so give it a temporary `SizedBox.shrink()` here. Task 6 replaces it.

`HomeExtrasController` asks for one memory with `streamMemories(uid, limit: 1)`.

- [ ] **Step 4: Run them and watch them pass**

Same command. Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/home lib/state_management/user_registered_events.dart test/features/home
git commit -m "Home's logic: finished hero, what to show and when"
```

### Task 6: Home's picture cards

**Files:**
- Create in `lib/ui/components/event/`: `event_picture.dart`, `event_grid_card.dart`
- Create in `lib/features/home/widgets/`: `finished_card.dart`, `nothing_open_banner.dart`, `events_grid_section.dart`, `home_memory_card.dart`, `home_season_card.dart`, `home_news_card.dart`, `new_player_greeting.dart`, `how_it_works_sheet.dart`
- Modify: `recommended_card.dart`, `next_game_card.dart`, `greeting_stats.dart`, `home_hero_section.dart` (all in `lib/features/home/widgets/`), `lib/dev/component_gallery.dart`, `lib/dev/home_preview.dart`, `docs/ui-and-theme.md`
- Delete: `lib/features/home/widgets/new_events_row.dart` and `lib/ui/components/event/event_mini_card.dart`, once unused
- Test: `test/features/home/home_picture_cards_test.dart`; update `test/features/home/home_screen_parts_test.dart` and `test/ui/components/home_pieces_test.dart`

**Interfaces:**
- Consumes: `AlbumPhoto`, `AlbumStrip`, `memoryThumbnail`, `FinishedHero`, `seasonSpot`'s record, `cardRouteFacts`, `gamesLabel`.
- Produces:
  - `EventPicture({String? url, required double height, Color? fill, Widget? topLeft, Widget? topRight, Widget? bottomLeft})`: `CachedNetworkImage` with cover fit, over a flat fill with a dashed route line (`DashedLine` or a small painter) when there's no picture or it fails
  - `EventGridCard({title, date, facts, imageUrl, onTap})`
  - `EventsGridSection({required String title, String? link, VoidCallback? onLink, required List<Event> events, required ValueChanged<Event> onTap})`, which draws nothing when empty
  - `FinishedCard({required Event event, required VoidCallback onOpen})`
  - `NothingOpenBanner()`
  - `HomeMemoryCard({required Memory memory, required List<AlbumPhoto> album, String? eventPicture, required bool large, required VoidCallback onOpen, required VoidCallback onAll})`
  - `HomeSeasonCard({required String seasonName, required int place, required SeasonStanding standing, required VoidCallback onOpen})`
  - `HomeNewsCard({required Stire stire, required VoidCallback onOpen, required VoidCallback onAll})`
  - `NewPlayerGreeting({required String firstName, required VoidCallback onHow})`
  - `showHowItWorksSheet(BuildContext context)`

- [ ] **Step 1: Write the failing tests**

```dart
testWidgets('no picture: the fill shows and nothing throws', ...);
testWidgets('RecommendedCard: picture, badge, name, day line, button', ...);   // finds 'Recomandat pentru tine', 'Înscrie-ți echipa'
testWidgets('NextGameCard: countdown and preparation stay', ...);              // 'Următorul tău joc', 'Pregătirea echipei Vulpile'
testWidgets('FinishedCard says when results come', ...);                       // exact copy below
testWidgets('large memory shows the strip and Vezi pozele; small shows a row', ...);
testWidgets('a memory with no photos and no event picture shows the icon', ...);
testWidgets('one game says "joc"', ...);                                       // GreetingStats(games: 1) finds 'joc'
testWidgets('every new card fits 320 px at 1.3x text with long names', ...);
```

- [ ] **Step 2: Run them and watch them fail**

Run: `flutter test --timeout 60s test/features/home/home_picture_cards_test.dart`. Expected: FAIL.

- [ ] **Step 3: Build them, as drawn on the canvas ("Picture-led" row and "Home when results are in")**

Copy:
- `FinishedCard`: pill `Ați terminat`, the event name, `Rezultatele, kilometrii și XP-ul apar când se încheie evenimentul.`, button `Vezi clasamentul`.
- `NothingOpenBanner`: `Niciun joc deschis acum`, `Jocurile noi apar aici imediat ce se deschid înscrierile.`, on `navActivePill`, with the text in `colors.accent`.
- `NewPlayerGreeting`: `Salut, {firstName}`, `Mergeți prin oraș, rezolvați indicii, descoperiți povestea.`, link `Cum funcționează`.
- `showHowItWorksSheet`, three numbered steps: `Înscrie-ți echipa` / `Din pagina jocului`; `Primești codul de start` / `În ziua jocului, de la organizator`; `Rezolvați misiunile prin oraș` / `Coduri, locuri și fotografii`.
- `HomeMemoryCard`: `SectionHeader` `Amintiri` with link `Toate`. The large form has `AlbumStrip`, name, `memoryLine`, button `Vezi pozele` (only with photos). The small form is a row with the thumbnail and a chevron.
- `HomeSeasonCard`: `SectionHeader` `Sezonul tău` with link `Clasament`; crew name; `{seasonName} · {points} p · {games} {gamesLabel}`.
- `HomeNewsCard`: `SectionHeader` `Știri` with link `Toate`.

The route facts keep `cardRouteFacts`' order ("3,2 km · 1 h 30"), even though the drawing shows the time first.

Replace the temporary `FinishedHero` case in `HomeHeroSection` with `FinishedCard`.

- [ ] **Step 4: Update the older tests for the new cards, then run them**

Run: `flutter test --timeout 60s test/features/home test/ui`. Expected: PASS, including `no_hardcoded_colors_test`.

- [ ] **Step 5: Document and commit**

Update the tables in `docs/ui-and-theme.md`.

```bash
git add lib/ui/components/event lib/features/home lib/dev docs/ui-and-theme.md test/features/home test/ui
git commit -m "Home's picture cards and new sections"
```

### Task 7: Memory page, memory list and Profil

**Files:**
- Create: `lib/features/memories/screen/memory_screen.dart`, `lib/features/memories/screen/memories_screen.dart`, `lib/features/memories/controller/memory_controller.dart`, `lib/features/memories/controller/memories_controller.dart`, `lib/features/memories/widgets/memory_album_view.dart`
- Modify: `lib/constants/routes.dart`, `lib/main.dart`, `lib/features/profile/controller/profile_controller.dart`, `lib/features/profile/widgets/memories_section.dart`, `lib/features/profile/widgets/memory_card.dart`, `lib/features/profile/logic/profile_texts.dart`, `lib/features/profile/screen/profile_screen.dart`, `docs/features.md`, `docs/screens.md`
- Test: `test/features/memories/memory_controller_test.dart`, `test/features/memories/memory_album_view_test.dart`; extend `test/features/profile/profile_logic_test.dart` and `test/features/profile/profile_controller_test.dart`

**Interfaces:**
- Consumes: `memoryAlbum`, `memoryThumbnail`, `AlbumPhoto`, `UserRepo.streamMemories(uid, limit:)`, `FullScreenImage`.
- Produces:
  - `Routes.memory = '/memory'`, taking `{'memory': Memory}`; `Routes.memories = '/memories'`, no arguments
  - `MemoryController({required Memory memory, required Future<Team?> Function(String eventId) findTeam})` with `album`, `loading`, `load()`
  - `MemoryAlbumView({required Memory memory, required List<AlbumPhoto> album, String? teamName, String? eventPicture, VoidCallback? onEvent, required ValueChanged<AlbumPhoto> onPhoto})`
  - `memoryLine(Memory memory, {int? photoCount})`: the count, when given, replaces `photoUrls.length`
  - `MemoryCard` gains `String? imageUrl` and `int? photoCount`
  - `MemoriesSection` gains `VoidCallback? onAll`
  - `ProfileController` gains `albumOf(String eventId) → List<AlbumPhoto>`

- [ ] **Step 1: Write the failing tests**

```dart
test('loads the album and stops loading, even when the team cannot be read', ...);
test('memoryLine uses the album count when given', ...);        // photoCount: 3 → 'Locul 2 · 1:48 · 3 poze'
test('profile loads an album per shown memory', ...);
test('profile opening a memory goes to the memory page', ...);
testWidgets('album view: Start and Final large, puzzles side by side, labels shown', ...);
testWidgets('album view without photos: event picture and "Nicio poză la acest joc."', ...);
testWidgets('no event link when the event is not loaded', ...);  // onEvent null → no 'Vezi pagina evenimentului'
testWidgets('memory page fits 320 px at 1.3x text', ...);
```

- [ ] **Step 2: Run them and watch them fail**

Run: `flutter test --timeout 60s test/features/memories test/features/profile`. Expected: FAIL.

- [ ] **Step 3: Implement, as drawn on the canvas ("Opening a memory")**

Copy: app bar `Amintire`; list title `Amintiri`; facts `Locul {n}` / `în clasament` and `{h:mm}` / `timp total`; section `Pozele voastre`; link `Vezi pagina evenimentului`; empty list `Aici apar jocurile tale terminate.`

The date and team line reads `{shortDay} {dayAndMonth} · Echipa {team}`, with the team part left out when the team can't be read. `MemoriesController` uses `streamMemories(uid, limit: 50)`. Add both routes to `main.dart`. Update `openMemory`, and add `Toate` on Profil's section header.

- [ ] **Step 4: Run them and watch them pass**

Same command. Expected: PASS.

- [ ] **Step 5: Document and commit**

```bash
git add lib/constants/routes.dart lib/main.dart lib/features/memories lib/features/profile docs/features.md docs/screens.md test/features/memories test/features/profile
git commit -m "Amintiri: album page and full list"
```

### Task 8: Putting Home together

**Files:**
- Modify: `lib/features/home/screen/home.dart`, `lib/features/home/controller/home_controller.dart`, `docs/screens.md`, `docs/features.md`
- Test: `test/features/home/home_layout_test.dart`

**Interfaces:**
- Consumes: everything from Tasks 5 and 6; `Routes.memory` and `Routes.memories` from Task 7.
- Produces: `HomeLayout({required HomeHero hero, required Widget greeting, required Widget? mainCard, required Widget? memoryFirst, required Widget? newEvents, required Widget? memory, required Widget? pastGames, required Widget? season, required Widget? news})` in `lib/features/home/widgets/home_layout.dart`, which orders the sections.

- [ ] **Step 1: Write the failing layout tests**

Using plain `Text` markers for each part:

```dart
testWidgets('order: greeting, memory first, card, events, memory, past, season, news', ...);
testWidgets('a part that is null leaves no gap or title', ...);
testWidgets('during a game only the live parts show', ...);
testWidgets('new player, nothing open, no news: greeting and banner, and it fits 320 px at 1.3x', ...);
testWidgets('the fullest case scrolls and fits 320 px at 1.3x', ...);
```

- [ ] **Step 2: Run them and watch them fail**

Run: `flutter test --timeout 60s test/features/home/home_layout_test.dart`. Expected: FAIL.

- [ ] **Step 3: Assemble**

`Home` creates `HomeExtrasController` alongside `HomeLiveController`, and calls `watch(user?.uid)` from `build` in a post-frame callback, as `_watchLive` does. Sections keep `FadeInSection`.

- Greeting: `isNewPlayer` picks `NewPlayerGreeting` or `GreetingStats`.
- Main card: `NothingOpenBanner` when the hero is `NoHero`.
- Memory: `memoryGoesFirst` picks the large form on top; otherwise the small form in its place.
- New events: `newEventsToShow`, with "Vezi toate" going to `navigateToEventDashboard`; tap uses `navigateToEventDetails`.
- Past games: only with `NoHero`, using `pastGamesToShow(eventList.pastEvents, now)`, no link; tap uses `navigateToEventDetails`.
- Season: `HomeController` gets `openTeamsTab()`, which selects `PlayerTab.teams`.
- News: `latestNews`; "Toate" uses `navigateToNewsTab`; tap uses `navigateToStireDetails`.
- Memory opens `Routes.memory`; "Toate" opens `Routes.memories`.
- Finished: `onOpen` uses `controller.openGame(event, team)`, whose `GameDoor` goes to the finish screen.

- [ ] **Step 4: Run all Home tests**

Run: `flutter test --timeout 60s test/features/home`. Expected: PASS.

- [ ] **Step 5: Document and commit**

Rewrite the Home entry in `docs/screens.md`, and the `home` line in `docs/features.md`.

```bash
git add lib/features/home docs/screens.md docs/features.md test/features/home
git commit -m "Acasă: picture-led, in every situation"
```

### Task 9: Check everything and merge

**Files:**
- Modify: `docs/roadmap/mockups-roadmap.md`, `CLAUDE.md` (Features map), `docs/known-issues.md` if a listed bug is fixed

- [ ] **Step 1: Point the docs at the new design**

In the roadmap's mockup table, note on line 02 that Home now follows the canvas and the spec. Add `memories` and `team_photo` to the Features map in `CLAUDE.md`.

- [ ] **Step 2: Run everything**

Run: `flutter analyze`. Expected: no new issues.
Run: `flutter test --timeout 60s --reporter expanded`, redirected to a file, then read its tail. Expected: all pass.
Run: `npm --prefix functions test`. Expected: all pass.

- [ ] **Step 3: Final review**

Get a fresh review of the whole branch against the spec and this plan's Review Focus. Fix what it finds, each fix with a test that failed first, then run Step 2 again.

- [ ] **Step 4: Commit and merge**

```bash
git add docs/roadmap/mockups-roadmap.md CLAUDE.md docs/known-issues.md
git commit -m "Docs: Home and team photos"
git switch redesign/mockups
git merge --no-ff redesign/home-team-photos -m "Merge: picture-led Acasă, team photos, memories"
```

- [ ] **Step 5: Tell Victor what is left for him**

- `firestore.rules` gains `teamPhotos`, for whenever he deploys the rules. No functions deploy.
- Try it on a phone: taking a start and final photo, a memory's page, Acasă with and without events. Nothing here has been seen on a device.
- Every event needs a good main picture now.
- Say plainly what wasn't tested. The camera itself can't run in widget tests.
