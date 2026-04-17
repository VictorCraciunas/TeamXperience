import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

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

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? token = await _messaging.getToken();
        print('FCM Token: $token');
        return token;
      } else {
        print('User declined notification permission');
        return null;
      }
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
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

    // Initialize local notifications
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    // Listen for foreground FCM messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('=== FCM FOREGROUND MESSAGE RECEIVED ===');
      print('Data: ${message.data}');
      print('Notification: ${message.notification?.title} - ${message.notification?.body}');

      final notification = message.notification;
      final android = message.notification?.android;

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
        );
      }
    });
  }
}
