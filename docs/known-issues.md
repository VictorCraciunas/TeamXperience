# Known issues & risks (found by reading the code, not by running it)

Verify before fixing; none of these were reproduced. Roughly ordered by impact.

## Data integrity / logic
1. **Duplicating (blueprint) an event mutates the original in memory.** `CreateEventController.createEvent` sets `event.missions = originalEvent!.missions` (same `Mission` objects that live in `EventList`), then `MissionController._clearPuzzleDataForDuplication` nulls `type/code/lat/lng/indiciu` on those shared puzzles. Until `EventList.refresh()`, the original event in the app shows cleared puzzles; saving the original afterwards would write the cleared data.
2. **Team registration overwrites an existing team with the same name** (`TeamRepo.addTeam` = `set` on doc id = team name; no `isTeamNameTaken` check in `RegisterTeamController`). Also two events can have teams with the same name only because docs are per-event.
3. **Renaming a team** (`TeamRepo.updateTeamDetails`) deletes the old doc and creates a new one: the `messages` sub-collection is orphaned and `TeamControllerDetails.saveChanges` rebuilds the `Team` without `hasFinished`, `numberOfMembers`, `photoApprovals`.
4. **Deleting an event** (`MenuWidget` → `EventList.deleteEvent`) deletes only the event doc; teams, messages, Storage images, and users' `registeredEventIds` stay behind (Firestore doesn't cascade).
5. **Enrollment window not enforced** (`dateStartEnrollment`/`dateDeadlineEnrollment` are only stored).
6. **PUBLIC/PRIVAT never restrict visibility** for events or news.
7. `EnterCodeController.navigateToGame`: no feedback on a wrong code, case-sensitive, untrimmed; `team!` crashes if the user has no team.
8. `Team.fromMap` casts `latitude`/`longitude` as `double` (throws if stored as int or missing); `Event.fromMap` casts dates as `Timestamp` and `type` via `byName` (throws on missing/unknown).
9. `UserRepo.findByEmail` returns `null` on *any* error → `AuthUtil` then leaves the user on the loader; `LandingPage` has no error state.
10. Event end is evaluated on the device clock (`Event.hasExpired`, game timer).

## Robustness / UX
- `TeamDetailsScreen` re-fetches the team on every rebuild (`FutureBuilder` future built in `build`).
- `ChatController.sendMessage` doesn't await or validate (empty messages allowed); `MessageService.sendMessage` doesn't await the repo call.
- `SignUpService.register/signInGoogle` don't await `saveUser`.
- `TeamService.updateTeamLocation` doesn't await; `LocationService` swallows all errors; tracking only while the game screen is alive and app in foreground.
- `MapScreen` plots never-started teams at (0, 0); `userAgentPackageName` is `com.example.flutter_map_test`.
- `UserEventsProvider.loadActiveEvent` runs one Firestore query per past registered event on every `UserProvider`/`EventList` notification.
- `EventList.liveEvents` / `Event.isOver` don't trigger rebuilds when the 3 h mark passes.
- Facebook sign-in buttons are non-functional placeholders.
- Errors: repos throw generic `Exception('Failed to …')` and drop the cause; some controllers show raw `e.toString()` to users.
- Stray debug `print`s remain in files this redesign did not touch (`avoid_print` lint, e.g. `AuthUtil`, `EventGameController`, `AddMissionsController`).

## Platform
- Release builds signed with the debug key; missing Android `POST_NOTIFICATIONS`; missing iOS `NSPhotoLibraryUsageDescription`; no iOS push setup visible; `assets/images/default_background.png` referenced but absent.
- `test/widget_test.dart` is the Flutter template and fails.
- Hardcoded Cloud Run URL (`NetworkAPI`), public OSRM server, placeholder OSM user agent.

## Security (client-visible)
- Admin = `users/{uid}.role == "ADMIN"`, checked only client-side at login. Without Firestore rules (none in repo) any signed-in user could write that field or any event/team data. Rules must be reviewed in the Firebase console.
- `sendNotification` HTTP function has no authentication (anyone with the URL can POST and push to all users).
- `firebase_options.dart` / `google-services.json` are public client config by design, but the project's rules decide what they can access.

## Dark mode gaps (deferred on purpose)
- Splash screen and game screens (mission list, puzzle screen, geolocation and photo-upload widgets) are not polished for dark mode: they are redesigned later (UI plan, follow-up plans). The map keeps its light OpenStreetMap tiles.

## UI polish backlog (owner, 2026-10-19)
- Evenimente tab (user events dashboard): the unselected Evenimente/Înscrieri toggle has low contrast; fix when this screen is redesigned.
