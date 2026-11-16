import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../backend/repo/push_token_repo.dart';
import '../backend/repo/user_repo.dart';
import 'push/push_destination.dart';
import 'push/push_opener.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// How long sign-out waits for this device to come off the account.
  static const _signOutWait = Duration(seconds: 3);

  /// The white-on-transparent bell in `android/app/src/main/res/drawable`
  /// (the launcher icon is adaptive, which a notification cannot show).
  static const _smallIcon = 'ic_stat_notification';

  static const AndroidNotificationChannel _chatChannel =
      AndroidNotificationChannel(
    'chat_notifications',
    'Chat Notifications',
    description: 'Notifications for new chat messages',
    importance: Importance.high,
  );

  // Get FCM token
  static Future<String?> getFCMToken() async {
    try {
      // Request permission
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        String? token = await _messaging.getToken();
        return token;
      } else {
        debugPrint('User declined notification permission');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// This device's token, without asking for permission: null when pushes
  /// are not allowed (yet) or it cannot be read.
  static Future<String?> _tokenIfAllowed() async {
    try {
      final settings = await _messaging.getNotificationSettings();
      final status = settings.authorizationStatus;
      if (status != AuthorizationStatus.authorized && status != AuthorizationStatus.provisional) return null;
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('Could not read the push token: $e');
      return null;
    }
  }

  /// Asks for permission when needed and saves this device for [uid]
  /// (sign-in and sign-up). Never throws.
  static Future<void> saveTokenAsking(String uid) async {
    final token = await getFCMToken();
    if (token != null) await _save(uid, token);
  }

  /// At each start, without asking: saves this device for [uid] (a token that
  /// changed, or a second phone or tablet, is kept), and deletes the tokens
  /// older versions left on the user's doc. Never throws.
  static Future<void> saveTokenOnStart(String uid) async {
    try {
      await UserRepo().deleteLegacyTokens(uid);
    } catch (e) {
      debugPrint('Could not delete the old push tokens: $e');
    }
    final token = await _tokenIfAllowed();
    if (token != null) await _save(uid, token);
  }

  /// Right after the first-run prompt: a permission given there must reach
  /// the signed-in user now (the start's save found none, and no token
  /// refresh follows a grant). Never throws.
  static Future<void> saveTokenAfterPrompt() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final token = await _tokenIfAllowed();
    if (token != null) await _save(uid, token);
  }

  static Future<void> _save(String uid, String token) async {
    try {
      await PushTokenRepo().save(token, uid);
    } catch (e) {
      debugPrint('Could not save the push token: $e');
    }
  }

  /// Before signing out: this device stops getting [uid]'s pushes. Never
  /// throws, and gives up after 3 s (offline), so sign-out always goes on.
  static Future<void> forgetTokenOf(String uid) async {
    try {
      await _forget().timeout(_signOutWait);
    } catch (e) {
      debugPrint('Could not take the device off the account: $e');
    }
  }

  static Future<void> _forget() async {
    final token = await _messaging.getToken();
    if (token != null) await PushTokenRepo().delete(token);
  }

  /// After signing out: a new token for the next account, so the old one (if
  /// it was left on the account, offline) stops working. Never throws.
  static Future<void> dropDeviceToken() async {
    try {
      await _messaging.deleteToken();
    } catch (e) {
      debugPrint('Could not delete the push token: $e');
    }
  }

  /// Sets up pushes and their taps. Never throws: a part that fails is
  /// skipped, and the app starts all the same.
  static Future<void> initNotifications() async {
    try {
      // iOS shows a push itself while the app is open; a tap on it comes
      // through onMessageOpenedApp like any other.
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      debugPrint('Could not set the foreground presentation: $e');
    }

    await _initLocalNotifications();

    // A new token for this device is kept on whoever is signed in.
    _messaging.onTokenRefresh.listen((token) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) unawaited(_save(uid, token));
    });

    // A tapped push: with the app in the background (or open, on iOS), and
    // the one that started it.
    FirebaseMessaging.onMessageOpenedApp.listen((message) => PushOpener.instance.open(message.data));
    await _openLaunchingTap();

    // Android shows nothing for a push while the app is open: it is shown
    // here, with its data, so a tap opens it. iOS shows its own banner.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification == null || defaultTargetPlatform != TargetPlatform.android) return;
      unawaited(_localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _chatChannel.id,
            _chatChannel.name,
            channelDescription: _chatChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: _smallIcon,
          ),
        ),
        payload: pushPayload(message.data),
      ).catchError((Object e) => debugPrint('Could not show the push: $e')));
    });
  }

  /// The Android channel and the notifications the app shows itself; a tap
  /// on one opens what it is about. iOS asks for nothing here: the first-run
  /// prompt does.
  static Future<void> _initLocalNotifications() async {
    try {
      final androidPlugin =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(_chatChannel);

      const initSettings = InitializationSettings(
        android: AndroidInitializationSettings(_smallIcon),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );
      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) =>
            PushOpener.instance.open(pushDataFromPayload(response.payload)),
      );
    } catch (e) {
      debugPrint('Could not set up the local notifications: $e');
    }
  }

  /// The tap that started the app, if any: a push, or a notification the app
  /// showed itself. It waits in [PushOpener] until the user's home is up.
  static Future<void> _openLaunchingTap() async {
    try {
      final initial = await _messaging.getInitialMessage();
      if (initial != null) {
        PushOpener.instance.open(initial.data);
        return;
      }
      final launch = await _localNotifications.getNotificationAppLaunchDetails();
      final response = launch?.notificationResponse;
      if (launch != null && launch.didNotificationLaunchApp && response != null) {
        PushOpener.instance.open(pushDataFromPayload(response.payload));
      }
    } catch (e) {
      debugPrint('Could not read the tap that started the app: $e');
    }
  }
}
