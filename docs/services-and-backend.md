# Backend, services, state & Cloud Functions

## Layers

```
screen → *Controller → service/*  → backend/repo/* → Firestore / Storage
                     ↘ state_management/* (ChangeNotifier caches, used via Provider)
```
Repos (`lib/backend/`) are thin Firestore/Storage wrappers (throw generic `Exception('Failed to ...')`, swallowing stack traces). Services (`lib/service/`) add logic and wrap errors in `EventServiceException` / `StireServiceException` (`lib/exceptions/`). Many controllers `new` their services directly (`TeamService()`, `EventService()`) instead of using Provider — services are stateless so this works, but `EventService`/`NewsService` are *also* provided in `main.dart` for `EventList`/`NewsList`.

## backend/
- `authentication/AuthenticationRepository` — FirebaseAuth email/password (`register`, `loginWithEmailAndPassword`) + Google (`signInWithGoogle`), `logout` (also signs out of Google), `authUser`. Maps Firebase error codes to English `Exception` messages.
- `repo/`
  - `event_repo` — `events` CRUD, `stopEvent`, `streamEvent`.
  - `teamRepo` — `events/{id}/teams` CRUD, streams (`getStreamTeam`, `getStreamTeamsForEvent`), `setPhotoApproval` (updates `photoApprovals.<key>` via dotted path), `updateMissionProgress/PuzzleNumber`, `startTeam/finishTeam`, `updateTeamLocation`, `addUserToTeam` (arrayUnion), `isTeamNameTaken` (returns **true on error**), `getUserTeamForEvent` (query `userIds array-contains uid`).
  - `user_repo` — `saveUser`, `findByEmail`, `addEventToUser/removeEventFromUser` (arrayUnion/Remove), `updateFCMToken`, `getRegisteredEventsFromUser` (legacy; reads fields `title`/`date` that Event docs don't have).
  - `messages_repo` — `sendMessage`, `getMessages` stream.
  - `stire_repo`, `news_category_repo` — `stire` / `categories` collections.
- `functions/team_functions.dart` — `TeamFunctions`, a thin wrapper over `FirebaseFunctions.instance.httpsCallable(name)` (package `cloud_functions`): `checkTeamName`, `createCrew`, `registerTeam`, `previewInvite`, `joinTeam`. Each returns the decoded `Map<String, dynamic>`, no logic. Errors arrive as `FirebaseFunctionsException` with `details['reason']`.
- `repo/crew_repo.dart` — `CrewRepo.streamUserCrews(uid)`: `crews` where `memberUids` array-contains `uid`, ordered by name (read-only; crews are written by functions).
- `storage/storage_images.dart` — `ImageRepo.uploadImage` / `uploadStireImage` (see `data-model.md`).
- `network/` — `NetworkAPI.sendNotification` (POST JSON to the deployed `sendNotification` function, **hardcoded Cloud Run URL**), `NotificationDTO` (`title, description, eventId?`), `NotificationDTOResponse` (`success, message`).

## service/
- `event_service/event_service.dart` — CRUD wrappers; `createEvent` generates id if empty then uploads images; `updateEvent` uploads images then `set`s the whole doc (same repo call as create); `registeredEventsFromUser(allEvents, user)` maps ids → events.
- `event_service/upload_images.dart`, `news_service/upload_news_images.dart` — local-path → Storage URL replacement.
- `team_service/team_service.dart` — pass-through to `TeamRepo` plus: `deleteTeam` (removes the event from every member's `registeredEventIds` first), and the callable-backed methods: `registerTeam(...)` → `RegisterResult`, `isTeamNameFree(eventId, name)` (`bool?`, null on a network error), `previewInvite(code)` → `InvitePreview`, `joinTeam(code)` → event ids joined, `createCrew(name)` → `(crewId, inviteCode)`, `streamUserCrews(uid)`. Codes go through `normaliseCode` first. Constructor `TeamService({TeamFunctions? functions, CrewRepo? crews})` so tests can inject fakes.
- `team_service/team_errors.dart` — `enum TeamError` (the 14 function `reason`s plus `network`, `unknown`), `TeamError.fromException(e)` (reason from `details`; `unavailable`/`deadline-exceeded` → `network`; else `unknown`), `TeamError.teamNameFrom(e)` (`details.teamName` of `alreadyInTeam`), and `teamErrorText(error, {teamName})` with the Romanian message for each.
- `team_service/invite_preview.dart` — `InvitePreview` (`crewId, crewName, captainName, members, alreadyMember, event?`), `InviteEvent` (`eventId, name, dateEvent, teamName, size, count`), `slotLine` ("1 din 4 · tu ești al 2-lea", "primul" for the first) and `isFull`. `team_service/register_result.dart` — `RegisterResult` (`teamName, crewId, inviteCode, skippedUids`).
- `news_service/news_service.dart` — `getAllStire`, `createStire` (id + upload + save), `updateStire`.
- `message_service.dart` — builds `Message` from the user's role; `sendImageMessage` for photo puzzles.
- `FCMService.dart` — static: `getFCMToken()` (asks permission), `initNotifications()` (iOS foreground presentation, Android channel `chat_notifications`, local-notification display for foreground messages). Local notifications initialised for Android only (no iOS init settings). There is **no** background/terminated handler or tap-handling.
- `LocationService.dart` — singleton; permission check, `startLocationTracking(eventId, teamName)` writes lat/lng to the team doc (distanceFilter 10 m), `stopLocationTracking()`. Started/stopped by `EventGameController`.
- `route_service.dart` — singleton; OSRM public demo (`router.project-osrm.org`, foot profile), throttled to one request / 5 s (returns `null` when throttled), `formatDistance`.
- `share_service.dart` — builds the RO registration message; share sheet / WhatsApp / email / SMS. `shareInvite(context, code:, teamName:, eventName:)` shares the invite text ("Intră în echipa … deschide TeamXperience → Echipe → Intră și scrie codul …").

## state_management/ (provider)
Registered in `main.dart`:
`UserProvider` (ChangeNotifier) → `UserRepo`, `AuthenticationRepository` (Provider) → `AuthUtil` (Provider) → `EventService`, `NewsService` → `EventList`, `NewsList` → `UserEventsProvider` (+ a second, duplicate `NewsList` registration at the end).

- `UserProvider` — `currentUser`, `firebaseUser`, `isLoggedIn`, `setUser`, `clearUser`, `addRegisteredEvent`, `updateProfile` (takes a fresh copy's XP, stats and badges for the same uid; Profil calls it).
- `EventList` — cached `events` (5-min staleness; `loadEvents({forceRefresh})`, `refresh()`), `upcomingEvents`, `liveEvents`, `pastEvents`, `createEvent/updateEvent/deleteEvent/getEventById`, `clear()` (called on logout).
- `NewsList` — same for `Stire`: `getNewsByType`, `getNewsByCategory`, `allNewsSorted`, `getLatestNews(n)`, `getNewsFromPeriod`, `createStire/updateStire/getStireById`.
- `UserEventsProvider` — listens to `UserProvider` + `EventList`; `registeredEvents`, `upcomingRegisteredEvents`, `pastRegisteredEvents`, `nextEventWithinHour`, `loadActiveEvent()` (async scan of started-and-not-finished teams — one Firestore query per past registered event on every change), `activeEvent`, `activeTeam`.

## utils/
`auth_util.dart` (role redirect), `calendar_helper.dart` (Romanian date/time formatting + date-picker helper), `color_conversion.dart` (hex ↔ Color), `image_helper.dart` (gallery picker + `eventImageCache` CacheManager), `link_util.dart` (open URLs), `component_conversion/` (`Component` → runtime widgets, see `ui-and-theme.md`).

## functions/ (Firebase Cloud Functions v2, Node 20, TypeScript, `functions/src/index.ts`)
- `testEndpoint` (HTTP) — health check.
- `sendNotification` (HTTP POST) — body `{title, description, eventId?}`; reads `users` (filtered by `registeredEventIds array-contains eventId` when given), collects non-empty `fcmToken`s, sends via FCM multicast. Responds `{success, message}`.
- `onChatMessage` (Firestore `onDocumentCreated` on `events/{eventId}/teams/{teamName}/messages/{messageId}`) — if `sender == "ADMIN"` notifies team members (tokens of `team.userIds`), otherwise notifies admin users.
- Deploy: `firebase deploy --only functions` (predeploy runs `npm run build`). `functions/lib/` and `node_modules/` are build output.

## Config & platform
- `lib/firebase_options.dart` (FlutterFire, Android + iOS), `android/app/google-services.json`, `.firebaserc`, `firebase.json`.
- Permissions/plugins used: location (geolocator), image picker (gallery), notifications (FCM + flutter_local_notifications), url_launcher, share_plus, flutter_map/latlong2, cached_network_image, flutter_svg, lottie, flutter_colorpicker, intl.
