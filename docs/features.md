# Features (screens, controllers, navigation)

Every folder under `lib/features/` follows `controller/` + `screen/` (+ `widgets/`, `service/`). Controllers are mostly plain classes constructed in the screen's `didChangeDependencies`/`initState` with a `BuildContext`, a few extend `ChangeNotifier`. Route registry: `lib/main.dart` + `lib/constants/routes.dart`.

## Route → screen → arguments

| Route const | Screen | `settings.arguments` |
|---|---|---|
| `redirect` | `LandingPage` (inside `Consumer<AuthUtil>`) | – |
| `splash` | `SplashScreen` | – |
| `register` | `Register` (choose Google/email) | – |
| `signup` | `RegisterScreen` (email sign-up form) | – |
| `login` | `LogInScreen` | – |
| `forgotPassword` | `ForgotPasswordScreen` | – |
| `home` | `UserShell` (tabs: `Home`, `FilterEventsUser`, `StiriDashboard`, `ProfileScreen`) | – |
| `adminHome` | `AdminShell` (tabs: `AdminHome`, `EventsDashboard`, `StiriDashboard`, `ProfileScreen`) | – |
| `eventDetails` | `EventDetailsScreen` | `{'event': Event, 'isAdmin': bool}` |
| `registerTeam` | `RegisterTeamScreen` | `Event` |
| `registerTeamDetails` | `TeamDetailsScreen` | `{'event': Event, 'user': AppUser}` |
| `joinTeam` | `JoinTeamScreen` | none |
| `teams` | `TeamsScreen` (Echipe) | none; opened from the Profil tab ("Echipele mele") and in place of `joinTeam` after joining with no known event |
| `enterCodeScreen` | `EnterCode` | `Event` |
| `eventGame` | `EventGameScreen` | `{'event': Event, 'team': Team?}` |
| `puzzleGame` | `PuzzleGameScreen` | `{'mission','background' (ImageProvider),'event','team'}`; pops with updated `Team` (or `null` on error) |
| `eventDashboard` | admin `EventsDashboard` | `List<Event>` |
| `eventDashboardUser` | `FilterEventsUser` (player dashboard) | `List<Event>` |
| `filter` | `FilterEventsScreen` | `bool isAdmin`; pops filter map `{eventType,startDate,endDate}` |
| `calendar` | `DateRangeSelectionScreen` | – |
| `createEvent` | `CreateEventPage` | `{'event': Event?, 'isBlueprint': bool}` |
| `addMissions` | `AddMissionsPage` | `{'event': Event, 'mode': 'create'|'blueprint'|'edit'}` |
| `eventManagement` | `EventManagementScreen` | `Event` |
| `eventRegisteredTeams` | `EventRegisteredTeams` | `Event?` |
| `teamConversations` | `TeamChatsScreen` | `Event` |
| `chatScreen` | `ChatScreen` | `{'eventId','team': Team}` |
| `map` | `MapScreen` | `{'eventId', 'teams': Stream<List<Team>>}` |
| `sendNotification` | `NotificationScreen` | `Event?` (null = broadcast to everyone) |
| `createNews` | `CreateStireScreen` | `{'stire': Stire?}` |
| `newsDetails` | `NewsScreen` | `{'stire','isAdmin'}` |
| `newsDashboard` | `StiriDashboard` | `List<Stire>` |
| `filterStiri` | `FilterStiriScreen` | – |
| `chooseNewsType` | `NewsCategoryManipulationScreen` | – |

## Feature folders

### Auth & entry
- `loader_page/landing_page.dart` — Lottie loader; post-frame calls `AuthUtil.checkUserAndRedirect`.
- `splash`, `log-in`, `sign-up` (+`register.dart` chooser), `forgot-password`. Services: `LogInService` / `SignUpService` call `AuthenticationRepository`, then fetch an FCM token (`FCMService.getFCMToken`) and write it to `users/{uid}.fcmToken`. Google sign-in creates the `users` doc on first login. Registered users always get `Role.USER`; **admins are made by editing `users/{uid}.role` in Firestore** (no in-app way).

### Player
- `home` — `Consumer3<EventList, NewsList, UserEventsProvider>` with only the hero card ticking each second (`HomeHeroTicker`; the panels rebuild when the kind of hero changes, via `HomeHero.signature`). `resolveHomeHero` (`logic/home_hero.dart`) picks the hero (Live, Starting soon, Upcoming, Recommended, none), `HomeHeroSection` renders it with the shared `EventHeroCard`, then panels: `PreparationPanel` (upcoming), `HowItWorksPanel` (recommended/none), `RegistrationsPanel`, `EventsPanel`, `NewsPanel`. `HomeController` (plain class) handles navigation, team lookup and sharing.
- `events_dashboard/events_dashboard_admin` — admin Evenimente: scrolling header (tick-outlined "Creează eveniment", animated search, filter button) over `EventCard` sections (viitoare / trecute). The filter button opens `showFilterSheet` with period, event type and stare (viitoare / trecute), combined. The same header pattern is used on admin Știri (period, public or private, category).
- `events_dashboard/events_dashboard_user` — Instagram-style feed of `EventPostCard`s (`widgets/events_feed.dart`) with a Toate / Înscrise `SegmentedSwitch`, a search button and a period button that opens `showPeriodSheet` (`FeedSearchBar`) as the first, scrolling item of the feed (under the app bar; registered past events come last and dimmed); share uses `ShareService.shareText` with `eventShareText`; tapping opens event details, or team details when registered; `events_filter_service.dart` (`FilterService`) is shared with the admin dashboard.
- `event_details` — event info; register/"already registered" (`already_registered_card`), admin variant shows management actions.
- `register_team` — one screen: `RegisterForm` (+ `TeamNameField`, `RegisterInput` (now in `lib/ui/components/inputs/`, also used by `NewCrewSheet`), `FieldLabel`, `ConsentRow`) and, after a successful registration, `InviteResultSection` under it (the invite code to send on). `RegisterTeamController` is a `ChangeNotifier` (state, `blocker`, `submit`, share/copy, `close`); `logic/team_name_check.dart` (`TeamNameCheck`) debounces the name check.
- `join_team` — join a team by invite code (right phone of mockup 04). `JoinTeamBody` (pure, drawn from a `JoinState`) = `JoinIntro` + `CodeBoxesInput` + problem text + `InvitePreviewCard` + `JoinBottomBlock`. `logic/join_state.dart` holds the sealed `JoinState` (`Typing`, `Looking`, `Found`, `Problem`, `Joining`, `Joined`) and `JoinFlow` (preview / join functions injected, `confirm` ignored unless `Found`). `JoinTeamController` wires `JoinFlow` to `TeamService` and, on `Joined`, adds the events to `UserProvider` and opens the first known event's page (`eventDetails`) in place of the screen; with none it opens the Echipe screen (`Routes.teams`) in place of it. The events are added to `UserProvider` inside the join call itself, with the providers and navigator taken when the controller is made, so leaving the screen while joining does not lose the local update (it only skips the navigation). `JoinFlow` ignores `codeChanged` while `Joining`, and a preview with `alreadyMember` becomes a `Problem` ("Ești deja în echipă") instead of `Found`.
- `teams` — the Echipe screen (right phone of mockup 03): `TeamsView` (pure: `TeamsHeader` with the "Echipă nouă" chip, a `CrewCard` per crew — navy card with name, captain line, `AvatarStack` of up to 4 members and `CrewCodeRow` with share/copy icons — and the `JoinLink` card; empty text when there are no crews). `TeamsController` follows `TeamService.streamUserCrews(uid)`, has `createCrew(name)` (returns the code as shown), `openJoin()` (`Routes.joinTeam`), `openNewCrew()` (bottom sheet `NewCrewSheet`: name field + "Creează", then the `InviteCodeCard` of the new crew), `share` (`ShareService.shareCrewInvite`) and `copy`. Stats tiles and the season leaderboard are step 7.
- `team_details` — view own team (`TeamControllerDetails`; members from `Team.memberList` as an `AvatarStack` with names in `TeamMembersRow`, and the `InviteCodeCard` for the captain when the team has an `inviteCode`). Only the captain's phone can be edited (`savePhone` → `TeamService.updateTeamPhone` → `TeamRepo.updateTeamPhone`, a single-field `update`); the name and members are read-only because the old rename deleted and recreated the document (a rename through a function is a follow-up). Share registration through `ShareService` (system share, WhatsApp `wa.me`, `mailto:`, `sms:`), delete team.
- `enter_code` — compares typed code to `event.startCode`.
- `event_game` — see lifecycle in `data-model.md`. `puzzle_game_screen` branches on `PuzzleType`: `geolocation` → `GeolocationPuzzleWidget` (flutter_map + OSRM walking route via `RouteService`, solved when within circle radius of target), `imageToUpload` → `ImageUploadPuzzleWidget` (see below), everything else → admin-designed components. Code puzzles: Continue/button compares input to `puzzle.code` case-insensitively; a wrong code does nothing (no error UI).
- `calendar` — date-range picker (`DateRangeSelectionScreen`), uses `CalendarHelper`.
- `news_dashboard` (feed of `NewsPostCard`s in `widgets/news_feed.dart`, under the app bar; the search/filter row scrolls with the feed and admins get the create button in it and a small red x at the end of every post's category and date row that confirms and deletes the news; deleting removes the Firestore document only, not its Storage images). Players filter Știri by period only (bottom sheet); admins keep the full filter screen with type and category), `news_details`, `filter/filter_news` — also used by admin. Post wording helpers live in `features/feed/logic/post_text.dart`.
- `chat` — player-side chat with admin is the same `ChatScreen` (messages via `MessageService`; admin message → push to team, user message → push to admins via Cloud Function).

### Photo-puzzle approval flow
`ImageUploadPuzzleController.pickAndUpload`: pick (gallery) → upload to Storage → `MessageService.sendImageMessage` (chat image bubble, text "Fotografie încărcată pentru aprobare") → `TeamService.setPhotoApproval(key, pending)`. Admin opens `ChatScreen`, `ChatController.pendingApprovalKey` finds the first `pending` entry in `team.photoApprovals` and Aprobă/Respinge write `approved`/`denied`. Player widget listens to `getStreamTeam` and shows `image_upload_status_banner`; `approved` enables Continue (`onSolved` → `PuzzleGameController.navigate`), `denied` allows re-upload. Widget parts in `event_game/widgets/image_upload/`: `_picker`, `_preview`, `_status_banner`, `_action_button`.

### Admin
- `admin/home` — `resolveAdminHero` (`logic/admin_hero.dart`: live, starting soon within 24 h, none) drives `AdminHeroSection` (shared `EventHeroCard`), `AdminStatsPanel`, `AdminQuickActionsPanel`, `AdminUpcomingPanel`, and `AdminDraftsPanel` (unpublished events with progress, only when there are any; tap opens the draft in the event form). `AdminHomeController` (ChangeNotifier) loads events + per-event `AdminEventStats` (teams, persons, finished, in play), refreshed every 30 s, and handles navigation. Wrapped by `admin/shell/AdminShell`.
- `admin/create_event/start` — "Eveniment nou" sheet (`showCreateEventStartSheet`) opened by `openCreateEventFlow` from the admin Home quick action and the admin Evenimente + button: **De la zero**, **Din JSON** (`ImportEventPage` at `Routes.importEvent`: paste text or copy a model, `importEventFromJson` reads it with errors that name the mission/puzzle/component, saved as a draft and opened in the form; format and every allowed value in [skills/event-json/SKILL.md](skills/event-json/SKILL.md), examples in [event-examples/](event-examples/) and [event-import-sample.json](event-import-sample.json)), **Dintr-un eveniment vechi** (`OldEventPickerSheet`, newest first, disabled when there are none) and the drafts underneath. The choice is a `CreateEventStart` (`StartFromScratch`/`StartFromEvent`/`StartFromDraft`/`StartFromJson`) whose `route` and `arguments` say what to open.
- `admin/create_event/create_event_landing` — event form (`CreateEventController`); `mode` is `create`, `blueprint` (copy of an existing event whose puzzle data is cleared, `MissionController._clearPuzzleDataForDuplication`) `edit` or `draft` (resuming a saved draft). Images are optional. A dropdown sets how puzzles open (`Event.screenAnimation`: `fade` as always, or `none`; used by `componentFades`/`startEntrance` in `event_game/logic`). "Salvează ca ciornă" needs only a name (`EventList.saveDraft`); "Continuă la misiuni" validates the form.
- `admin/create_event/create_missions_and_puzzles` — `AddMissionsPage` is the mission list (back arrow + "Misiuni", one `MissionCard` per mission with puzzle count and the first thing missing, add/delete with confirmation, hold a card and drag to reorder (`moveMission`, ids are renumbered), then Creează/Actualizează/Publică and "Salvează ca ciornă"). Tapping a card opens `MissionPage`: one `PuzzleRow` per puzzle (type icon, number, what is missing), delete with confirmation, hold a row and drag to reorder (`movePuzzle`), and "Adaugă puzzle" which opens the "Ce fel de puzzle?" sheet (`PuzzleTypeSheet`: Cod, Fotografie, Locație, Link) and then `PuzzlePage` (standard app bar, then an Aspect/Reguli `SegmentedSwitch` in the body, both parts kept alive): **Aspect** (the old component builder, `PuzzleWidget`) and **Reguli** (`PuzzleRulesForm` + `PuzzleRulesController`: puzzle type (changing it clears the answer, location and hint, after a confirmation when something would be lost), answer or coordinates, hint; every change is written straight onto the puzzle, there is no save button). A puzzle is shown as finished only when `puzzleIssues` is empty. Status comes from `missionProblems`, not stored flags. Copying an old event (`blueprint`) deep-copies the missions, keeps the puzzle types and what is on each puzzle screen, and clears answers, locations and hints. Builder tree: `AddMissionsController` → `PuzzleWidget`/`PuzzleController` → `SavePuzzle`/`SavePuzzleController` (type, code, lat/lng, hint) and `create_components/{create_text,create_button,create_image,create_code}/` (each a widget + controller editing a `Component`; `add_component_widget` picks the kind; `common_widgets/upload_image.dart`, `widgets/color_picker_dialog.dart` shared). Save → `EventList.createEvent/updateEvent`, or `publishEvent` when opened with `isDraft` (refused with the list of problems via `publishFailureMessage`). "Mission done" = has puzzles and every puzzle has a `type`.
- `events_dashboard/events_dashboard_admin` — upcoming/past lists with search + filter (`EventsDashboardController`, shows team/person counts).
- `event_management` — live control of one event: send notification, map, team chats, **stop event** (confirm dialog → `EventService.stopEvent` sets `isStopped`). `canStop` only after start and not already over.
- `event_see_registered_teams` — list of teams with `team_card_widget` (the "Componență" row lists `Team.memberList` names, the count reads "{userIds} din {numberOfMembers}", the initial is `onTick` on `tick`).
- `team_chats` — teams of an event → `ChatScreen`.
- `map` — `flutter_map` with OSM tiles, a marker per team from `Stream<List<Team>>` (live lat/lng), call team (`tel:`), open chat.
- `notification` — title/description form → `NetworkAPI.sendNotification` (HTTP to Cloud Function). `event` arg scopes recipients to registrants.
- `admin/create_news` (+`create_news_service.dart`) — news form (main + secondary images, type, category, optional button text/link). `news_category_manipulation` — create/select categories.
- `ui/components/navigation/menu.dart` (`MenuWidget`) — overlay menu in `MyAppBar` dropdown: edit event (→ `createEvent`), duplicate as blueprint, "start game" (→ `eventGame`, admin preview).

## Duplicated/overlapping code worth knowing
- Event stats loading (`nrTeams`/`nrPerson`) is copy-pasted in `AdminHomeController`, `EventsDashboardController`, `EventsDashboardUserController` (the user one counts `userIds.length`, admin ones sum `numberOfMembers`).
- `SignUpService.signInGoogle` and `LogInService.logInGoogle` do nearly the same thing.
- `CreateStireService` duplicates `UploadNewsImagesHelper`/`NewsService` image upload logic.
- `FilterController`/`FilterStiriController` and the dashboard controllers each keep their own filter state.
