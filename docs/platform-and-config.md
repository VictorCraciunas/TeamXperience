# Platform, build & configuration

## Identity
- Android `applicationId`/namespace: `ro.teamxperience.teamxperience`. iOS display name "Teamxperience". Dart package `teamxperience`, version `1.0.0+1`, `publish_to: none`. Dart SDK `^3.7.2`.
- Firebase project `teamxperience-dadc6` (`.firebaserc`, `firebase.json`, `lib/firebase_options.dart`; Android appId `1:37662081989:android:e4d1102c63c4bbbf3081ac`, iOS appId `…:ios:092d26caf00c46e33081ac`). `google-services.json` and `GoogleService-Info.plist` are committed.

## Dependencies (pubspec) by purpose
- Firebase: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `firebase_messaging`, `cloud_functions` (the team callables, through `lib/backend/functions/team_functions.dart`); `google_sign_in`.
- State: `provider`. Notifications: `flutter_local_notifications`. HTTP: `http`.
- Maps/location: `flutter_map`, `latlong2`, `geolocator`.
- UI: `lottie`, `flutter_svg`, `cached_network_image`, `flutter_cache_manager`, `flutter_colorpicker`, `cupertino_icons`.
- Utilities: `intl`, `image_picker`, `url_launcher`, `share_plus`.
- Dev: `flutter_test`, `flutter_lints ^5` (`analysis_options.yaml` adds `prefer_const_constructors`).

## Android (`android/`)
- Gradle Kotlin DSL; AGP 8.7.0, Kotlin 2.1.0, google-services plugin 4.3.15; Java 11; NDK 27.0.12077973; core library desugaring enabled (required by flutter_local_notifications).
- **Release build is signed with the debug keystore** (`signingConfig = debug`) — no production signing configured.
- Manifest permissions: INTERNET, ACCESS_FINE/COARSE_LOCATION, WAKE_LOCK, VIBRATE, QUERY_ALL_PACKAGES. **Missing**: `POST_NOTIFICATIONS` (Android 13+ — FCM permission request may be a no-op without it), and no *background* location permission, so tracking works only while the app is in the foreground.
- `<queries>` for WhatsApp (`com.whatsapp`, `.w4b`), mailto, sms, https, SEND — needed by `ShareService`.
- Default FCM channel meta-data = `chat_notifications` (matches `FCMService._chatChannel`).

## iOS (`ios/`)
- `Info.plist`: only `NSLocationWhenInUseUsageDescription` (English text) and `LSApplicationQueriesSchemes` (https, http, whatsapp, mailto, tel, sms). **Missing** `NSPhotoLibraryUsageDescription` (needed by `image_picker` gallery → crash on iOS when picking), and no push-notification capability/background modes visible; `AppDelegate.swift` is the plain Flutter one. `FCMService` initialises local notifications for Android only.

## Firebase / backend config
- `firebase.json`: FlutterFire platform config + one functions codebase (`functions/`, predeploy `npm run build`).
- No Firestore rules/indexes, no Storage rules, no hosting in repo. The `query` in `TeamRepo.getUserTeamForEvent` (`array-contains`) and `UserRepo.findByEmail` rely on default single-field indexes only.
- Functions tests run with `npm --prefix functions run test:unit` today (it compiles, then runs `lib/test/*.test.js` with `node --test`). An emulator-backed `npm test` comes with the rules task.
- Cloud Functions runtime Node 20; deps `firebase-admin ^11.11.1`, `firebase-functions ^4.3.1`, TS `^4.9`. A root `package-lock.json` also exists (unused).

## External services
- Firebase Auth (email/password, Google), Firestore, Storage, FCM.
- `router.project-osrm.org` public routing demo (walking directions; rate-limited, no SLA) — `RouteService`.
- `tile.openstreetmap.org` tiles (OSM tile usage policy requires a real User-Agent; currently placeholder package name).
- Cloud Run URL of the `sendNotification` function hardcoded in `backend/network/NetworkAPI.dart`.

## Testing
`test/widget_test.dart` is the untouched Flutter counter template; it would fail (the app has no counter and needs Firebase initialised). There are no unit/integration tests.

## Dev environment notes
- Developed on Windows 11; shell commands in this repo are run through PowerShell/Git Bash. Git warns about LF→CRLF conversion on some files (`core.autocrlf`).
- Generated/ignored: `build/`, `.dart_tool/`, `android/app/.cxx/`, `functions/lib`, `functions/node_modules`.
