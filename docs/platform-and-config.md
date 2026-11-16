# Platform, build & configuration

## Identity
- Android `applicationId`/namespace: `ro.teamxperience.teamxperience`. iOS display name "Teamxperience". Dart package `teamxperience`, version `1.0.0+1`, `publish_to: none`. Dart SDK `^3.7.2`.
- Firebase project `teamxperience-dadc6` (`.firebaserc`, `firebase.json`, `lib/firebase_options.dart`; Android appId `1:37662081989:android:e4d1102c63c4bbbf3081ac`, iOS appId `…:ios:092d26caf00c46e33081ac`). `google-services.json` and `GoogleService-Info.plist` are committed.

## Dependencies (pubspec) by purpose
- Firebase: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `firebase_messaging`, `cloud_functions` (the team callables, through `lib/backend/functions/team_functions.dart`); `google_sign_in`.
- State: `provider`. Notifications: `flutter_local_notifications`. HTTP: `http`.
- Maps/location: `flutter_map`, `latlong2`, `geolocator`.
- UI: `lottie`, `flutter_svg`, `cached_network_image`, `flutter_cache_manager`, `flutter_colorpicker`, `cupertino_icons`.
- Utilities: `intl`, `image_picker`, `url_launcher`, `share_plus`, `shared_preferences`.
- Permissions: `permission_handler ^12.0.1` (only for the camera prompt at first sign-in; 13.x needs `compileSdk 37` and AGP 9, this project is on Flutter's `compileSdk 36` and AGP 8.11). Notifications are asked through `firebase_messaging`, location through `geolocator`.
- Dev: `flutter_test`, `flutter_lints ^5` (`analysis_options.yaml` adds `prefer_const_constructors`), `flutter_launcher_icons` (app icon, below).

## App icon
- Sources in `assets/icon/`: `app_icon.png` (1024, navy #222F62 with a white T, yellow X and teal dashed route; legacy Android mipmaps and the iOS AppIcon set, alpha removed) and `app_icon_foreground.png` (same artwork on transparent, scaled to 68% so it sits inside the adaptive icon's 66/108 safe circle; Android 8+ draws it over `ic_launcher_background` #222F62 with no extra inset). Config in `flutter_launcher_icons.yaml`; regenerate with `dart run flutter_launcher_icons`, then revert its change to `ios/Runner.xcodeproj/project.pbxproj` (v0.14.4 wrongly sets `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = AppIcon`). The launch screens are separate and stay navy.

## Android (`android/`)
- Gradle Kotlin DSL; AGP 8.11.1, Kotlin 2.2.20, google-services plugin 4.3.15; Java 11; NDK 27.0.12077973; core library desugaring enabled (required by flutter_local_notifications).
- **Release build is signed with the debug keystore** (`signingConfig = debug`) — no production signing configured.
- Manifest permissions: INTERNET, ACCESS_FINE/COARSE_LOCATION, WAKE_LOCK, VIBRATE, QUERY_ALL_PACKAGES, CAMERA (with `uses-feature android.hardware.camera required="false"`, so phones without a camera still see the app in the store). `POST_NOTIFICATIONS` comes in through the `firebase_messaging` and `flutter_local_notifications` manifests. No *background* location permission, so tracking works only while the app is in the foreground.
- CAMERA being declared changes `image_picker`: before opening the camera app it checks CAMERA and, when not granted, asks for it itself (`ImagePickerDelegate.takeImageWithCamera`); a refusal ends the pick with the error `camera_access_denied`. `ImageHelper.takePhoto` turns that into `CameraAccessDenied`, and the team photo shows "Camera nu e permisă. Pornește-o din setările telefonului." Without the declaration the camera intent needed no permission, but then the first-run camera prompt could not be shown.
- `<queries>` for WhatsApp (`com.whatsapp`, `.w4b`), mailto, sms, https, SEND — needed by `ShareService`.
- Default FCM channel meta-data = `chat_notifications` (matches `FCMService._chatChannel`).

## iOS (`ios/`)
- `Info.plist`: `NSLocationWhenInUseUsageDescription`, `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` (all Romanian; camera and photos are needed by `image_picker`). There is no `NSLocationAlways…` key on purpose: geolocator then only ever asks for location while the app is in use. Also `LSApplicationQueriesSchemes` (https, http, whatsapp, mailto, tel, sms). No push-notification capability/background modes visible; `AppDelegate.swift` is the plain Flutter one. `FCMService` initialises local notifications for Android only.
- The repo has no `ios/Podfile` (it is generated on a Mac). `permission_handler` compiles each iOS permission only when it is switched on:
  - Swift Package Manager: `permission_handler_apple` reads `Info.plist` and switches on the camera because `NSCameraUsageDescription` is there. Nothing to add.
  - CocoaPods: once `pod install` has made the Podfile, put this in its `post_install` block (the app only asks for the camera through `permission_handler`; notifications go through `firebase_messaging` and location through `geolocator`, so their macros stay off):

    ```ruby
    post_install do |installer|
      installer.pods_project.targets.each do |target|
        flutter_additional_ios_build_settings(target)
        target.build_configurations.each do |config|
          config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
            '$(inherited)',
            ## dart: PermissionGroup.camera (the first-run prompt)
            'PERMISSION_CAMERA=1',
          ]
        end
      end
    end
    ```

    Without `PERMISSION_CAMERA=1` the first-run camera prompt silently answers "denied" on iOS; the camera still asks by itself when the team photo opens it.

## Permissions at first sign-in
Android 6+ and iOS cannot grant permissions at install, so the app shows the phone's own prompts one after another the first time a signed-in screen opens on the phone (`UserShell` for players, `AdminHome` for organisers, from a post-frame call): notifications (`FirebaseMessaging.requestPermission`), location while in use (`Geolocator.requestPermission`, only if not decided yet), camera (`Permission.camera.request`). `lib/service/startup_permissions.dart` (`StartupPermissions.shared.askOnce`) runs them; it is once per install, not per account (shared_preferences flag `startup_permissions_asked`, set after the prompts so an app closed halfway asks the rest next time). No custom screen; a refusal or an error in one prompt does not stop the next, and nothing else happens. The app still asks at the moment of need as before: geolocation puzzle (geolocator), team photo camera (image_picker), Profil's notifications row. Both screens take `askPermissions` to replace it in tests. Android Auto Backup may restore the flag after a reinstall, in which case the prompts are not shown again.

## Firebase / backend config
- `firebase.json`: FlutterFire platform config + one functions codebase (`functions/`, predeploy `npm run build`).
- No Firestore rules/indexes, no Storage rules, no hosting in repo. The `query` in `TeamRepo.getUserTeamForEvent` (`array-contains`) and `UserRepo.findByEmail` rely on default single-field indexes only.
- Functions and rules tests: `npm --prefix functions run test:unit` runs the pure tests; `npm --prefix functions test` runs everything on the Firestore and Auth emulators (project `demo-teamxperience`, nothing touches the live project). It uses the Firebase CLI on your PATH; 14.11.2 with Java 17 works.
- Cloud Functions runtime Node 22 (Node 20 was retired on 2026-10-30; Node 22 stops being deployable on 2028-10-31); deps `firebase-admin ^11.11.1`, `firebase-functions ^4.3.1`, TS `^4.9`. A root `package-lock.json` also exists (unused).

## External services
- Firebase Auth (email/password, Google), Firestore, Storage, FCM.
- `router.project-osrm.org` public routing demo (walking directions; rate-limited, no SLA) — `RouteService`.
- `tile.openstreetmap.org` tiles (OSM tile usage policy requires a real User-Agent; currently placeholder package name).

## Testing
`test/widget_test.dart` is the untouched Flutter counter template; it would fail (the app has no counter and needs Firebase initialised). There are no unit/integration tests.

## Dev environment notes
- Developed on Windows 11; shell commands in this repo are run through PowerShell/Git Bash. Git warns about LF→CRLF conversion on some files (`core.autocrlf`).
- Generated/ignored: `build/`, `.dart_tool/`, `android/app/.cxx/`, `functions/lib`, `functions/node_modules`.
