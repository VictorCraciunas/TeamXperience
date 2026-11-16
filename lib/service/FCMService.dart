import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../backend/repo/user_repo.dart';
import 'push/push_destination.dart';
import 'push/push_opener.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// How long sign-out waits on each push-token step before going on anyway.
  static const _signOutStep = Duration(seconds: 3);

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

  /// Asks for permission when needed and adds this device's token to [uid]
  /// (sign-in and sign-up). Never throws.
  static Future<void> saveTokenAsking(String uid) async {
    final token = await getFCMToken();
    if (token != null) await _save(uid, token);
  }

  /// Adds this device's token to [uid] at each start, without asking: a
  /// token that changed, or a second phone or tablet, is kept. Never throws.
  static Future<void> saveTokenOnStart(String uid) async {
    final token = await _tokenIfAllowed();
    if (token != null) await _save(uid, token);
  }

  static Future<void> _save(String uid, String token) async {
    try {
      await UserRepo().addFcmToken(uid, token);
    } catch (e) {
      debugPrint('Could not save the push token: $e');
    }
  }

  /// Before signing out: takes this device's token off [uid]. Never throws,
  /// and gives up after a few seconds (offline), so sign-out always goes on.
  static Future<void> forgetTokenOf(String uid) async {
    try {
      final token = await _messaging.getToken().timeout(_signOutStep);
      if (token == null) return;
      await UserRepo().removeFcmToken(uid, token).timeout(_signOutStep);
    } catch (e) {
      debugPrint('Could not take the push token off the account: $e');
    }
  }

  /// After signing out: a new token for the next account, so the old one (if
  /// it was left on the account, offline) stops working. Never throws.
  static Future<void> dropDeviceToken() async {
    try {
      await _messaging.deleteToken().timeout(_signOutStep);
    } catch (e) {
      debugPrint('Could not delete the push token: $e');
    }
  }

  // Initialize local notifications and FCM foreground listener
  static Future<void> initNotifications() async {
    // Allow foreground notifications on iOS (Android handles differently)
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Create the Android notification channel
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_chatChannel);

    // Initialize local notifications; a tap on one opens what it is about.
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) =>
          PushOpener.instance.open(pushDataFromPayload(response.payload)),
    );

    // A new token for this device is kept on whoever is signed in.
    _messaging.onTokenRefresh.listen((token) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) unawaited(_save(uid, token));
    });

    // A tapped push: with the app in the background, and the one that started it.
    FirebaseMessaging.onMessageOpenedApp.listen((message) => PushOpener.instance.open(message.data));
    await _openLaunchingTap();

    // Listen for foreground FCM messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;

      // On Android, foreground messages with notification payload need to be shown manually
      if (notification != null) {
        _localNotifications.show(
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
              icon: '@mipmap/ic_launcher',
            ),
          ),
          payload: pushPayload(message.data),
        );
      }
    });
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
