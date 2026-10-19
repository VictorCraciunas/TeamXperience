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
| `adminHome` | `AdminHome` | – |
| `eventDetails` | `EventDetailsScreen` | `{'event': Event, 'isAdmin': bool}` |
| `registerTeam` | `RegisterTeamScreen` | `Event` |
| `registerTeamDetails` | `TeamDetailsScreen` | `{'event': Event, 'user': AppUser}` |
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
- `home` — `Consumer3<EventList, NewsList, UserEventsProvider>`: active-event card ("play"), upcoming events carousel, registered events, latest news. `HomeController` (plain class) handles logout (clears `EventList`/`NewsList`, signs out) and navigation.
- `events_dashboard/events_dashboard_user` — list/search/filter of upcoming events; `events_filter_service.dart` (`FilterService`) is shared with the admin dashboard.
- `event_details` — event info; register/"already registered" (`already_registered_card`), admin variant shows management actions.
- `register_team` — 3-step wizard (`widgets/step1..3`, `StepRegisterWidget` indicator); step 3 = mandatory agreements.
- `team_details` — view/edit own team (`TeamControllerDetails`), share registration through `ShareService` (system share, WhatsApp `wa.me`, `mailto:`, `sms:`), delete team.
- `enter_code` — compares typed code to `event.startCode`.
- `event_game` — see lifecycle in `data-model.md`. `puzzle_game_screen` branches on `PuzzleType`: `geolocation` → `GeolocationPuzzleWidget` (flutter_map + OSRM walking route via `RouteService`, solved when within circle radius of target), `imageToUpload` → `ImageUploadPuzzleWidget` (see below), everything else → admin-designed components. Code puzzles: Continue/button compares input to `puzzle.code` case-insensitively; a wrong code does nothing (no error UI).
- `calendar` — date-range picker (`DateRangeSelectionScreen`), uses `CalendarHelper`.
- `news_dashboard`, `news_details`, `filter/filter_news` — news list/search/filter (also used by admin).
- `chat` — player-side chat with admin is the same `ChatScreen` (messages via `MessageService`; admin message → push to team, user message → push to admins via Cloud Function).

### Photo-puzzle approval flow
`ImageUploadPuzzleController.pickAndUpload`: pick (gallery) → upload to Storage → `MessageService.sendImageMessage` (chat image bubble, text "Fotografie încărcată pentru aprobare") → `TeamService.setPhotoApproval(key, pending)`. Admin opens `ChatScreen`, `ChatController.pendingApprovalKey` finds the first `pending` entry in `team.photoApprovals` and Aprobă/Respinge write `approved`/`denied`. Player widget listens to `getStreamTeam` and shows `image_upload_status_banner`; `approved` enables Continue (`onSolved` → `PuzzleGameController.navigate`), `denied` allows re-upload. Widget parts in `event_game/widgets/image_upload/`: `_picker`, `_preview`, `_status_banner`, `_action_button`.

### Admin
- `admin/home` — `AdminHomeController` (ChangeNotifier) loads events+news and per-event stats (`nrTeams`, `nrPerson` via `TeamRepo.getAllTeamsForEvent`); `navigate_card`, `title_carousel` widgets.
- `admin/create_event/create_event_landing` — event form (`CreateEventController`); `mode` is `create`, `blueprint` (copy of an existing event whose puzzle data is cleared, `MissionController._clearPuzzleDataForDuplication`) or `edit`. Requires both images selected.
- `admin/create_event/create_missions_and_puzzles` — builder. Tree: `AddMissionsController` → `MissionWidget`/`MissionController` → `PuzzleWidget`/`PuzzleController` → `SavePuzzle`/`SavePuzzleController` (type, code, lat/lng, hint) and `create_components/{create_text,create_button,create_image,create_code}/` (each a widget + controller editing a `Component`; `add_component_widget` picks the kind; `common_widgets/upload_image.dart`, `widgets/color_picker_dialog.dart` shared). Save → `EventList.createEvent/updateEvent`. "Mission done" = has puzzles and every puzzle has a `type`.
- `events_dashboard/events_dashboard_admin` — upcoming/past lists with search + filter (`EventsDashboardController`, shows team/person counts).
- `event_management` — live control of one event: send notification, map, team chats, **stop event** (confirm dialog → `EventService.stopEvent` sets `isStopped`). `canStop` only after start and not already over.
- `event_see_registered_teams` — list of teams with `team_card_widget`.
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
