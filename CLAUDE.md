# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`teamxperience` — a Flutter (Dart SDK ^3.7.2) mobile app ("Treasure Hunt") for organising and playing team-based city treasure-hunt events. UI strings and many identifiers are Romanian (`stire` = news item, `punctDeStart`, `dificultate`, `lungimeTraseu`, `durata`, `Aprobă/Respinge`). Backend is Firebase (Auth, Firestore, Storage, FCM) plus a small Cloud Functions project in `functions/`. The README is the untouched Flutter template.

Two roles (`lib/enums/role.dart`): `USER` (players) and `ADMIN` (event organisers). Each has its own home screen and dashboards.

## Commands

```bash
flutter pub get
flutter run                      # run on device/emulator
flutter analyze                  # lint (flutter_lints + prefer_const_constructors)
flutter test                     # widget/unit tests under test/ (ui components, theme, wrappers)
flutter test test/ui/components/app_button_test.dart --plain-name "<name>"   # single test
flutter build apk
```

Cloud Functions (`functions/`, Node 20, TypeScript):

```bash
cd functions && npm run build        # tsc
npm run serve                        # build + emulator
firebase deploy --only functions
```

Firebase project id: `teamxperience-dadc6` (`firebase.json`, `lib/firebase_options.dart`, `android/app/google-services.json`).

## Code conventions (from user preferences)

- Avoid `x!` null-forcing in new code; use local-variable promotion (`final t = team; if (t != null) ...`).
- One `*Controller` per screen, next to it; screens stay thin and logic lives in the controller.
- One widget per file; split sub-widgets out instead of piling `_buildX` helpers.
- Where a widget lives: generic widgets, or ones used by two or more areas (player, admin, auth), go in `lib/ui/components/` and take their content (texts, counts, callbacks) through parameters, with no role-specific copy or logic. Widgets only one flow uses stay in `lib/features/<area>/widgets/`. Promote a feature widget into `lib/ui/` when a second area needs it. `lib/ui/` never imports from `lib/features/`.

## Detailed docs (read the relevant one before working in that area)

- [docs/data-model.md](docs/data-model.md) — enums, every model's fields, Firestore/Storage layout, event lifecycle
- [docs/features.md](docs/features.md) — route → screen → arguments table, every feature folder, photo-approval flow, duplicated code
- [docs/services-and-backend.md](docs/services-and-backend.md) — repos, services, providers, utils, Cloud Functions
- [docs/ui-and-theme.md](docs/ui-and-theme.md) — theme, colours, shared widgets, component renderer
- [docs/screens.md](docs/screens.md) — screen-by-screen behaviour, validation and user-visible strings
- [docs/platform-and-config.md](docs/platform-and-config.md) — Android/iOS config, dependencies, Firebase project, external services, tests
- [docs/known-issues.md](docs/known-issues.md) — bugs/risks found by code reading (verify before fixing)
- [docs/roadmap/mockups-roadmap.md](docs/roadmap/mockups-roadmap.md) — the mockup redesign: logic and UI roadmap, reference mockups, branch rules (step branches → `redesign/mockups`)

Keep these in sync when adding routes, models, collections or providers.

## Architecture

### Layering (`lib/`)

```
main.dart          Firebase init, FCM init, MultiProvider, MaterialApp, ALL routes
constants/         routes.dart (Routes.* string consts)
enums/             Role, EventType, PuzzleType, ComponentType, MissionState, MessageType, PhotoApprovalStatus, StireType, AnimationType
model/             Plain data classes with fromMap/fromFirestore + toJson (see "Data model")
backend/           Raw Firebase access: authentication/, repo/*_repo.dart (Firestore), storage/ (Firebase Storage), network/ (HTTP to Cloud Function)
service/           Business logic over repos: event_service/, team_service/, news_service/, message_service, FCMService, LocationService, RouteService, share_service
state_management/  ChangeNotifier providers: UserProvider, EventList, NewsList, UserEventsProvider
features/          One folder per screen/flow: controller/ + screen/ (+ widgets/, service/)
ui/                Shared UI layer: theme/ (AppColors tokens, AppTheme, radius/spacing) and components/ (buttons, inputs, navigation, event, news, feedback, misc: AppButton, AppTextField, AppDropdown, SectionCard, EventHeroCard, MyAppBar, EventCard, StireCard, MySnackBars, showAppDialog, AsyncState, ...)
utils/             AuthUtil, calendar_helper, image_helper, color_conversion, component_conversion/
```

Flow: `screen -> *Controller -> service -> repo -> Firestore`. Not every feature follows it strictly (some controllers instantiate `EventService()`/`TeamService()` directly rather than reading from Provider).

### Navigation & startup

- No router package. Named routes live in `MaterialApp.routes` in `main.dart`, keyed by `Routes.*` in `lib/constants/routes.dart`. **Adding a screen = add const to `Routes` + entry in `main.dart`.**
- Route arguments are passed via `Navigator.pushNamed(..., arguments:)` and read with `ModalRoute.of(context)!.settings.arguments`. Shapes vary per route: a bare `Event`, a `List<Event>`, or a `Map` like `{'event': ..., 'mode': ..., 'isBlueprint': ...}`. Check both the pusher (usually a controller) and the receiving screen when changing them.
- Start: `Routes.redirect` -> `LandingPage(authUtil)` -> `AuthUtil.checkUserAndRedirect` loads `AppUser` by email via `UserRepo`, stores it in `UserProvider`, then `pushNamedAndRemoveUntil` to `Routes.adminHome` (ADMIN) or `Routes.home` (USER, which is now `UserShell`: a tab shell with Acasă, Evenimente, Știri and Profil built on `AppShell` + `ShellController` from `lib/ui/components/navigation/`; tabs are built on first visit and kept alive, back returns to Acasă), or `Routes.splash` if signed out. Auth is email/password + Google Sign-In (`backend/authentication/AuthenticationRepository.dart`).

### State management (provider)

Providers registered in `main.dart` (order matters — later ones read earlier ones):
- `UserProvider` — current `AppUser` + Firebase `User`. `AppUser` is immutable, so mutations (e.g. `addRegisteredEvent`) rebuild a new instance.
- `EventList` — cached list of all events with `upcomingEvents` / `liveEvents` / `pastEvents` getters; `loadEvents()` is throttled (5 min) unless `forceRefresh`. Admin-side views use this.
- `NewsList` — same pattern for news.
- `UserEventsProvider` — player-side: derives registered/upcoming/past events from `UserProvider` + `EventList`, and finds the user's *active event* (a team with `hasStarted && !hasFinished`) to drive the "play event" card on Home. Skips events where `Event.isOver` (stopped by admin or >3h after start).

Game-time screens use their own `ChangeNotifier` controllers (e.g. `EventGameController`) and Firestore streams rather than the global providers.

### Data model & Firestore layout

Models in `lib/model/`; enums are stored by `.name` and read back with `values.byName(...)`.

```
events/{eventId}                      Event (embeds missions[] -> puzzles[] -> components[] inline as maps)
events/{eventId}/teams/{teamName}     Team   (doc id = team NAME, so renaming a team = delete + set; see TeamService/team repo)
events/{eventId}/teams/{teamName}/messages/{auto}   Message (admin <-> team chat; type text|image)
users/{uid}                           AppUser (role, registeredEventIds, fcmToken)
stire/{id}                            News item (model/stire.dart); categories/{id} = NewsCategory
Storage: events/{eventId}/{imageType}.jpg, stiri/{id}/{imageType}.jpg, plus chat/puzzle photos
```

Event content hierarchy: `Event` -> `Mission` -> `Puzzle` (`PuzzleType`: code, imageToUpload, geolocation, redirect, ar) -> `Component` (`ComponentType`: text, image, button, code). `Component` is a single wide class carrying every styling option for all four kinds (colours as hex strings, fonts, glow/flicker, typewriter animation, code-input styling); `utils/component_conversion/` turns a `Component` into the matching runtime widget (`component_to_widget.dart` is the dispatcher), and `utils/color_conversion.dart` handles hex <-> `Color`.

Team progress is `missionProgress` + `puzzleNumber`; location is written continuously by `LocationService` during play and shown to admins on the map. Photo puzzles: player uploads -> posted as an image message in the team chat -> `Team.photoApprovals['{mission}_{puzzle}']` (`Team.approvalKey`) set to pending -> admin approves/denies from the chat bubble -> player's Continue button unlocks.

Event lifecycle: players register for events (`registeredEventIds`), enter the event's `startCode` (`features/enter_code`) up to ~1h after start, then play via `features/event_game` (mission list `event_game_screen` -> `puzzle_game_screen`). An event ends when admin sets `isStopped` or 3h after `dateEvent` (`Event.hasExpired`); `EventGameController` watches both via a timer and `EventService.streamEvent`.

### Features map (`lib/features/`)

- **Auth:** `splash`, `loader_page`, `log-in`, `sign-up`, `forgot-password`
- **Player:** `home`, `events_dashboard/events_dashboard_user`, `event_details`, `register_team`, `team_details`, `enter_code`, `event_game`, `calendar`, `map`, `news_dashboard`, `news_details`, `filter/*`
- **Admin:** `admin/home`, `admin/create_event` (landing form + `create_missions_and_puzzles` builder with per-component `create_*` editors and controllers), `admin/create_news`, `events_dashboard/events_dashboard_admin`, `event_management` (live control: stop event, etc.), `event_see_registered_teams`, `team_chats` (list of team conversations), `chat`, `news_category_manipulation`, `notification` (send push)
- Directories named `common_widgets`, `widgets/` hold per-feature sub-widgets; `event_game/widgets/image_upload/` is the split photo-puzzle upload flow driven by `ImageUploadPuzzleController`.

### Notifications

- `service/FCMService.dart`: permission + token, foreground handler that shows a local notification on the `chat_notifications` Android channel. Token is saved on the user doc.
- `functions/src/index.ts` (v2 functions): `sendNotification` (HTTP POST `{title, description, eventId?}` -> FCM to all users, or only those with `eventId` in `registeredEventIds`), `onChatMessage` (Firestore trigger on `events/{eventId}/teams/{teamName}/messages/{id}`: admin message -> notify team members via `userIds`; user message -> notify admins), `testEndpoint`.
- The app calls `sendNotification` via a **hardcoded Cloud Run URL** in `backend/network/NetworkAPI.dart`; update it if the function is redeployed to a different project/region.

### Theme

Theme lives in `lib/ui/theme/`: `AppColors` (a `ThemeExtension` with light and dark tokens: page, panel, border, inset, text, muted, accent, tick, onTick (text on tick fills), navy, ...), `AppTheme.light/dark` (Material 3, Poppins, scaffold = page colour, canvas = panel colour), `AppRadius`, `AppSpacing`, and `context.colors` to read the tokens. `themeMode` comes from `ThemeController` (saved choice: Sistem / Luminos / Întunecat, default Luminos). Screens and shared widgets read colours from `context.colors`; there is no `MyColors` any more. Text styles come from `AppTextStyles` (also registered as the `TextTheme`), spacing from `AppSpacing` (`AppSpacing.page` = 16 side padding), and feedback colours from `AppColors.success/warning/danger` (+ `*Soft`). `test/ui/no_hardcoded_colors_test.dart` stops `lib/features` from gaining literal colours (allow-list in `test/ui/colour_allowlist.txt`). Inside an event's own screens colours come from `context.eventPalette` (`EventPalette`, set with `EventThemeScope`; falls back to the app colours). Fonts: `Poppins` (weights 300–800) and `Monospace` (SpaceMono) in `assets/fonts/`; icons for the redesign from `flutter_tabler_icons`. `flutter run -t lib/dev/gallery_main.dart` opens a Firebase-free gallery of the redesign components to compare with `docs/roadmap/mockups/`. Lottie loader at `assets/loader/loader.json`; images in `assets/images/`.

## Gotchas

- `firebase_options.dart` and `google-services.json` are committed; Firestore offline persistence is enabled in `main()`.
- Several files have stray debug `print(...)`s and commented-out code (e.g. `AuthUtil`, `Event.toString`); not a signal of intended behaviour.
- Mixed file naming (`AuthenticationRepository.dart`, `FCMService.dart` vs snake_case; `component-type.dart`, `log-in/` with hyphens) — follow the neighbouring files when adding to an existing folder, snake_case for new ones.
- Windows dev machine; `build/`, `android/app/.cxx/` are generated — ignore when searching.
