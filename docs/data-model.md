# Data model, Firestore & Storage

All models live in `lib/model/`. Pattern: plain mutable classes, `fromMap`/`fromFirestore` + `toJson`. Enums are persisted by `.name` and parsed with `Enum.values.byName(...)` (throws on unknown value — keep stored strings in sync with enum names, including the existing typos below).

## Enums (`lib/enums/`)

| Enum | Values | Notes |
|---|---|---|
| `Role` | USER, ADMIN | Stored on `users/{uid}.role` and on `Message.sender` |
| `EventType` | PUBLIC, PRIVAT | (`PRIVAT` spelled so) |
| `PuzzleType` | code, imageToUpload, geolocation, redirect, ar | `redirect` and `ar` have no dedicated game UI yet (fall through to the generic components screen) |
| `ComponentType` | text, image, button, code | file is `component-type.dart` |
| `AnimationType` | none, typewriter | text component animation |
| `MissionState` | finalizata, deblcata, blocata | `deblcata` = unlocked/current (typo is intentional in code); computed from `Team.missionProgress`, never stored |
| `MessageType` | text, image | |
| `PhotoApprovalStatus` | pending, approved, denied | |
| `StireType` | PUBLICA, PRIVATA | has `displayName` (RO) |

## Models

- **`Event`** (`event.dart`): `eventId, name, missions[], dateEvent, dateDeadlineEnrollment, dateStartEnrollment, location, description, nrMissions, type, landingImageUrl, taskBackgroundImageUrl, startCode, punctDeStart, lungimeTraseu, durata, dificultate, isStopped`, plus the draft fields `status` (`EventStatus.draft` / `published`; a document without it is published), `wizardStep` (where a draft was left), `updatedAt` (last save) and `defaults` (`EventDefaults`: `backgroundColor`, `textColor`, `accentColor`, `fontFamily`, all optional hex strings or a font name that new components start with).
  - **Drafts** may be saved with almost nothing filled in, so `Event.fromMap` tolerates a missing `type` and missing dates (`type`, `dateEvent`, `dateStartEnrollment`, `dateDeadlineEnrollment` are nullable). `EventList.events`, `upcomingEvents`, `liveEvents` and `pastEvents` exclude drafts; `EventList.draftEvents` lists them (most recently edited first) and `getEventById` still finds them. `EventService.saveDraft` / `publishEvent` do the saving; `publishEvent` refuses an incomplete event (`EventNotPublishableException` with every problem). What "complete" means lives in `service/event_service/event_completeness.dart` (`eventIssues`, `missionProblems`, `puzzleIssues`, `publishProblems`, `canPublish`): images and the puzzle hint are optional, everything the old form required is checked.
  - `hasExpired` = now > `dateEvent` + **3h**; `isOver` = `isStopped || hasExpired`. This is the single definition of "event finished" — used by `EventList.liveEvents`, `UserEventsProvider`, `EventGameController`, `EventManagementController`.
  - Missions/puzzles/components are **embedded** in the event document (no sub-collections).
  - `fromMap` casts dates as `Timestamp` and parses `type` with `byName` — a missing field throws.
- **`Mission`**: `id` (stringified index, `"0"`, `"1"`…) + `puzzles[]`. The admin UI relies on `int.parse(mission.id)` being the list index.
- **`Puzzle`**: `id` (string index), `type`, `components[]`, `code` (for `code`), `latitude/longitude` (for `geolocation`), `indiciu` (hint text). `toJson` omits null optional fields.
- **`Component`**: one wide class for all component kinds. Common: `type, text, imageUrl, textColor, fontSize, fontWeight, fontFamily, textAlign, width, height`. Text: `animation, typewriterSpeed`. Button: `buttonLabel, buttonColor(+OnTap), buttonTextColor(+OnTap), borderColor, cornerRadius, enableGlow, glowColor, enableFlicker`. Code input: `codeLength, inputType ("Separated"|"Free"), capsLock ("CapsLock"|"Fără"), frameCornerRadius, inputCornerRadius, frameBackgroundColor, inputBackgroundColor, colorBorderInput, colorBorderContainer`. Colours are hex strings (`#RRGGBB` or `#AARRGGBB`), converted via `ColorConversion`.
- **`Team`**: `name` (also the Firestore doc id!), `teamMembers` (free text), `captainName/Email`, `phoneNumber`, `missionProgress` (# completed missions), `puzzleNumber` (current puzzle index inside the current mission), `userIds[]`, `hasStarted`, `hasFinished`, `latitude/longitude` (live location), `numberOfMembers`, `photoApprovals` (`Map<String, PhotoApprovalStatus>`, key = `Team.approvalKey(missionIdx, puzzleIdx)` → `"{m}_{p}"`). `fromMap` casts `latitude`/`longitude` as `double` directly (will throw if stored as int/null).
- **`AppUser`** (`user.dart`): `email, firstName, lastName, uid, role, registeredEventIds[], fcmToken`. Immutable; `UserProvider.addRegisteredEvent` rebuilds it.
- **`Message`**: `sender (Role), text, timestamp, type, imageUrl?`.
- **`Stire`** (news): `id, title, description, publicationDate, type (StireType), category (NewsCategory), buttonText, buttonLink, principalImage, secondaryImages[]`. `fromMap` accepts category as a map or a legacy plain string.
- **`NewsCategory`**: `id, name`.

## Firestore

```
users/{uid}                                  AppUser
events/{eventId}                             Event (missions→puzzles→components embedded)
events/{eventId}/teams/{teamName}            Team
events/{eventId}/teams/{teamName}/messages/{autoId}   Message  (ordered by timestamp asc)
stire/{id}                                   Stire
categories/{id}                              NewsCategory
```

- Ids for new events/news/categories come from `collection(...).doc().id` (`getNewEventId`, `getNewStireId`, `getNewCategoryId`).
- Team doc id = team name → uniqueness check is `TeamRepo.isTeamNameTaken`; renaming deletes the old doc and `set`s a new one (`TeamRepo.updateTeamDetails`). Note: renaming loses the `messages` sub-collection (Firestore doesn't move sub-collections) and `TeamControllerDetails.saveChanges` builds the new `Team` without `hasFinished`, `numberOfMembers`, `photoApprovals`.
- `users` lookup at login is by **email** (`UserRepo.findByEmail`), but docs are keyed by uid.
- Offline persistence is enabled in `main()`.
- No Firestore security rules / indexes are in the repo (`firebase.json` only configures `functions` and FlutterFire).

## Storage (`ImageRepo`, `backend/storage/storage_images.dart`)

```
events/{eventId}/landingImage.jpg
events/{eventId}/background.jpg
events/{eventId}/mission_{m}_puzzle_{p}_component_{c}.jpg      component images
events/{eventId}/team_photos/{team}_mission_{m}_puzzle_{p}_{ts}.jpg   player photo-puzzle uploads (via uploadImage with a path-like "imageType")
stiri/{newsId}/principal.jpg, secondary_{i}.jpg
```
Upload helpers (`service/event_service/upload_images.dart`, `service/news_service/upload_news_images.dart`) upload only values that are **local file paths** (not `http(s)://`), then replace the field with the download URL. This is why the create-event flow stores local file paths in `landingImageUrl` etc. until save. `ImageRepo` returns `null` on failure (errors swallowed).

## Event lifecycle (end to end)

1. Admin creates event: `create_event_screen` (form) → `add_missions_screen` (missions/puzzles/components) → `EventList.createEvent` → `EventService.createEvent` (upload images, `set` doc).
2. Registration window `dateStartEnrollment`…`dateDeadlineEnrollment`; player registers a team (`register_team`, 3 steps) → `TeamService.addTeam` (creates team doc with `userIds=[uid]`, adds eventId to `users/{uid}.registeredEventIds`, updates `UserProvider`).
3. At/after `dateEvent` (up to 1h after, per `UserEventsProvider.nextEventWithinHour`) the player enters `startCode` (`enter_code`) → `TeamService.startTeam` (`hasStarted=true`) → `Routes.eventGame`.
4. Game: missions list (`event_game_screen`) → `puzzle_game_screen` per mission. Progress writes: `puzzleNumber` per puzzle, `missionProgress`+1 and `puzzleNumber=0` when mission finishes. `LocationService` streams position into the team doc (distanceFilter 10 m).
5. End: all missions done, admin `stopEvent` (`isStopped=true`), or 3h timer → `EventGameController._triggerEventEnded` → `finishTeam` (`hasFinished=true`).
