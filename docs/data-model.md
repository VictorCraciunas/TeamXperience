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
  - **Drafts** may be saved with almost nothing filled in, so `Event.fromMap` tolerates a missing `type` and missing dates (`type`, `dateEvent`, `dateStartEnrollment`, `dateDeadlineEnrollment` are nullable). `EventList.events`, `upcomingEvents`, `liveEvents` and `pastEvents` exclude drafts; `EventList.draftEvents` lists them (most recently edited first) and `getEventById` still finds them. `EventService.saveDraft` / `publishEvent` do the saving; `publishEvent` refuses an incomplete event (`EventNotPublishableException` with every problem). Publishing also needs the event page bits: a start pin, a finish point, route length, duration and difficulty (the number fields or the old text), and a title on every mission. What "complete" means lives in `service/event_service/event_completeness.dart` (`eventIssues`, `missionProblems`, `puzzleIssues`, `publishProblems`, `canPublish`): images and the puzzle hint are optional, everything the old form required is checked.
  - **Event page fields** (redesign step 2, all optional): `area`, `finishPoint`, `routeLengthKm` (double), `durationMinutes` (int), `difficulty` (`Difficulty` easy/medium/hard by name), `teamSizeMin`/`teamSizeMax` (default 2/6), `maxTeams` (null = no limit), `startLatitude`/`startLongitude`, `meetingPointNote`, `arriveMinutesBefore` (default 15), `whatToBring` (list of strings), `story` (long text of the event page; `description` stays the short card text), `organiserName` (blank = TeamXperience). Old events keep route, duration and difficulty as text: read them through `effectiveRouteKm`, `effectiveDurationMinutes` and `effectiveDifficulty`, which fall back to `lungimeTraseu`, `durata` and `dificultate`. `storyText` falls back to `description`; `hasStartPin` needs both coordinates.
  - **Game start fields** (redesign step 6a, optional): `introLetter`, `introSignature` (the intro letter and who signs it), `hintsPerMission` (default 1), `enterWindowMinutes` (default 60; `enterWindow` is the `Duration` every start-code check uses, replacing the old fixed hour). Organisers set them in the event form's "Începutul jocului" section or in the JSON import. Step 7a adds `finishTitle` and `finishMessage` (optional; the finish screen's texts, "Sfârșitul jocului" in the same form). (6a's `look` field was removed in step 6b: an event's game screens take their colours from its own puzzle components; an old `look` value in Firestore is ignored.)
  - `hasExpired` = now > `dateEvent` + **3h**; `isOver` = `isStopped || hasExpired`. This is the single definition of "event finished" — used by `EventList.liveEvents`, `UserEventsProvider`, `EventGameController`, `EventManagementController`.
  - Missions/puzzles/components are **embedded** in the event document (no sub-collections).
  - `fromMap` casts dates as `Timestamp` and parses `type` with `byName` — a missing field throws.
- **`Mission`**: `id` (stringified index, `"0"`, `"1"`…) + `puzzles[]`. The admin UI relies on `int.parse(mission.id)` being the list index. Also `title`, `teaser` and `isTeaserPublic` (default false): public missions with a title are shown on the event page, the rest count as secret. Copies made when missions move or are deleted use `withId`, which keeps them. Optional `latitude`/`longitude` (step 6b): where the mission is, for "la 180 m de tine" on the route (falls back to the mission's first location puzzle); set on the mission page ("Locul misiunii") or in the JSON.
- **`Puzzle`**: `id` (string index), `type`, `components[]`, `code` (for `code`), `latitude/longitude` (for `geolocation`), `indiciu` (hint text), and for code puzzles (step 6b, optional) `maxAttempts` (1–20; null = unlimited, anything below 1 reads as null) and `wrongAnswerMessage` (null = "Nu e corect. Mai încearcă."); for location puzzles (step 6c) `radiusMeters` (int, default 20, 10–200; anything else reads as 20; written only when not 20). `toJson` omits null optional fields.
- **`Component`**: one wide class for all component kinds. Common: `type, text, imageUrl, textColor, fontSize, fontWeight, fontFamily, textAlign, width, height`. Text: `animation, typewriterSpeed`. Button: `buttonLabel, buttonColor(+OnTap), buttonTextColor(+OnTap), borderColor, cornerRadius, enableGlow, glowColor, enableFlicker`. Code input: `codeLength, inputType ("Separated"|"Free"), capsLock ("CapsLock"|"Fără"), frameCornerRadius, inputCornerRadius, frameBackgroundColor, inputBackgroundColor, colorBorderInput, colorBorderContainer`. Colours are hex strings (`#RRGGBB` or `#AARRGGBB`), converted via `ColorConversion`.
- **`Team`**: `name` (also the Firestore doc id!), `teamMembers` (free text), `captainName/Email`, `phoneNumber`, `missionProgress` (# completed missions), `puzzleNumber` (current puzzle index inside the current mission), `userIds[]`, `hasStarted`, `hasFinished`, `latitude/longitude` (live location), `numberOfMembers`, `photoApprovals` (`Map<String, PhotoApprovalStatus>`, key = `Team.approvalKey(missionIdx, puzzleIdx)` → `"{m}_{p}"`). `fromMap` reads `latitude`/`longitude` as numbers and falls back to 0 when missing.
  - **Crew fields** (redesign step 3, all optional): `crewId`, `captainUid`, `members` (`List<TeamMember>`, default empty), `inviteCode` (stored without the dash, upper-case, e.g. `VLP482`; `displayCode` gives `VLP-482`), `photoConsent` (default false). `memberList` is `members`, or for old teams the comma-separated names in `teamMembers` (trimmed, empty pieces skipped, uid empty, initials = first letters of the first two words, upper-case). The functions also write `nameKey` and `rulesAcceptedAt` on the team doc; the app does not model them. `toJson` omits null `crewId`/`captainUid`/`inviteCode`.
  - **Live fields** (redesign step 5, optional): `presence` (`Map<uid, DateTime>`, last seen playing; the game screen writes `presence.{uid}` = server time every 60 s through `TeamService.markPresent`) and `missionCompletedAt` (`Map<int, DateTime>`, mission index → when it was solved; `PuzzleGameController` writes `missionCompletedAt.{index}` with the progress update). Pending server timestamps (null in a local snapshot) and anything that is not a Timestamp are skipped when read. `lastMissionAt` is the latest. Neither is written by `toJson`.
  - **Finish and walk** (step 7a): `finishedAt` (server time, set once by `TeamService.finishTeam(..., completed: true)` in a transaction when the last mission is solved; an event that ends first marks `hasFinished` without it) and `walked` (`Map<uid, double>` metres, each phone adding its own walk with `FieldValue.increment` through `addWalked`); `distanceMeters` is the longest walk. Neither is written by `toJson`. Ratings go to `events/{eventId}/feedback/{uid}` `{rating 1–5, teamName, at}` (`saveRating`).
  - **Photo approvals** (step 6c): each `photoApprovals.{mission}_{puzzle}_{try}` value is now a map `{status, reason?, url?, at}` (`at` = server time of the last change), written by `TeamService.setPhotoApproval(..., {reason, url})`; old plain status strings are still read. `Team.photoApprovals` stays `Map<String, PhotoApprovalStatus>`; `Team.photoDetails` (`Map<String, PhotoDetail>`, `lib/model/photo_detail.dart`) has the rest. `toJson` writes the map form without `at`.
  - **`unreadByAdmin`** (redesign step 8, optional): `{text, at}`, the team's latest message the organiser has not read, read as `Team.unreadText` and `Team.unreadAt`. Written right after the player's text message, as its own write, deleted when the organiser opens or leaves the chat; never by `toJson`. `Message.announcement: true` marks the organiser's "Anunț".
  - **Puzzle counters** (redesign step 6b, optional), keyed by `Team.puzzleKey(mission, puzzle)` = `"3_0"`: `attempts` (`Map<String,int>`, wrong answers, written with `FieldValue.increment` by `TeamService.addWrongAttempt` so teammates' phones add up), `lockedUntil` (`Map<String,DateTime>`, set by `lockPuzzle`, which also resets that puzzle's attempts to 0) and `hintsUsed` (`Map<String,bool>`, `markHintUsed`). Unreadable values are skipped; none is written by `toJson`.
  - **`startedAt`** (step 6a, optional): when the first member entered the start code (server time), the game's clock. `TeamRepo.startTeam` writes `hasStarted: true` as a plain update (kept offline and sent later), then a transaction writes `startedAt` only when the doc has none. Read like the live fields (pending → null); not written by `toJson`.
- **`TeamMember`** (`team_member.dart`): `uid`, `displayName`, `initials`. `TeamMember.fromName` builds one from a plain name (old teams).
- **`Crew`** (`crew.dart`): `id` (doc id), `name`, `captainUid`, `memberUids[]`, `members` (`List<TeamMember>`), `inviteCode` (no dash). `displayCode` gives `VLP-482`; `captain` is the member whose `uid` is `captainUid`. Written by Cloud Functions only. Invite-code helpers (`normaliseCode`, `isWellFormedCode`, `displayCode`) are in `lib/utils/invite_code.dart`, twins of `functions/src/teams/codes.ts`.
- **`AppUser`** (`user.dart`): `email, firstName, lastName, uid, role, registeredEventIds[], fcmToken`, plus (step 5, optional, default 0) `xp`, `stats` (`UserStats{games, distanceMeters, missions, podiums}`, `user_stats.dart`) and (step 7b) `badges` (`List<String>`, the ids of `badge_catalog.dart`), written by the end-of-event function (7c, parked with 3b) and not by `toJson`; unreadable values read as zero or are skipped. Immutable; `copyWith` (used by `UserProvider.addRegisteredEvent` and `updateProfile`, which takes a fresh copy's `xp`, `stats` and `badges` for the same uid) keeps every other field. `UserRepo.streamUser(uid)` follows the document live.
- **`Memory`** (`memory.dart`, step 7b): one finished game in `users/{uid}/memories/{eventId}`: `eventName`, `date`, `place` (int), `totalTime` (whole minutes), `photoUrls[]`; `UserRepo.streamMemories(uid, limit: 3)` gives the newest first. Written by 7c.
- **`Message`**: `sender (Role), text, timestamp, type, imageUrl?`.
- **`Stire`** (news): `id, title, description, publicationDate, type (StireType), category (NewsCategory), buttonText, buttonLink, principalImage, secondaryImages[]`. `fromMap` accepts category as a map or a legacy plain string.
- **`NewsCategory`**: `id, name`.

## Firestore

```
users/{uid}                                  AppUser
users/{uid}/memories/{eventId}               Memory (written by 7c; `date` is required: the query orders by it)
events/{eventId}                             Event (missions→puzzles→components embedded)
events/{eventId}/teams/{teamName}            Team (+ crewId, captainUid, members, inviteCode, photoConsent, presence, missionCompletedAt, attempts, lockedUntil, hintsUsed; server-only nameKey, rulesAcceptedAt)
events/{eventId}/teams/{teamName}/messages/{autoId}   Message  (ordered by timestamp asc)
crews/{crewId}                               Crew (written by Cloud Functions)
inviteCodes/{code}                           { crewId }  (code without dash, e.g. VLP482)
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
2. Registration window `dateStartEnrollment`…`dateDeadlineEnrollment`; player registers a team (`register_team`, one screen) → `TeamService.registerTeam` (the `registerTeam` callable creates the team doc with `userIds=[uid]` and an invite code, and adds the eventId to `users/{uid}.registeredEventIds`; the app then updates `UserProvider`).
3. At/after `dateEvent` (up to 1h after, per `UserEventsProvider.nextEventWithinHour`) the player enters `startCode` (`enter_code`) → `TeamService.startTeam` (`hasStarted=true`) → `Routes.eventGame`.
4. Game: missions list (`event_game_screen`) → `puzzle_game_screen` per mission. Progress writes: `puzzleNumber` per puzzle, `missionProgress`+1 and `puzzleNumber=0` when mission finishes. `LocationService` streams position into the team doc (distanceFilter 10 m).
5. End: all missions done, admin `stopEvent` (`isStopped=true`), or 3h timer → `EventGameController._triggerEventEnded` → `finishTeam` (`hasFinished=true`).
