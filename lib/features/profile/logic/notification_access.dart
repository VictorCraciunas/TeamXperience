import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';

enum NotifStatus { allowed, notAsked, refused }

/// Whether the phone lets the app show notifications, and the one action the
/// Profil row offers: ask when the question was never put, else open the
/// phone's settings page for the app (to turn them on or off; the change is
/// read when the player comes back to the app). The three calls can be
/// replaced (tests); by default they use Firebase Messaging and geolocator's
/// `openAppSettings` (which opens the app's page in the phone's settings).
class NotificationAccess {
  NotificationAccess({
    Future<NotifStatus> Function()? read,
    Future<NotifStatus> Function()? ask,
    Future<void> Function()? openSettings,
  })  : _read = read ?? _readSettings,
        _ask = ask ?? _askPermission,
        _openSettings = openSettings ?? _openAppSettings;

  final Future<NotifStatus> Function() _read;
  final Future<NotifStatus> Function() _ask;
  final Future<void> Function() _openSettings;

  static NotifStatus _of(AuthorizationStatus status) => switch (status) {
        AuthorizationStatus.authorized || AuthorizationStatus.provisional => NotifStatus.allowed,
        AuthorizationStatus.notDetermined => NotifStatus.notAsked,
        AuthorizationStatus.denied => NotifStatus.refused,
      };

  static Future<NotifStatus> _readSettings() async =>
      _of((await FirebaseMessaging.instance.getNotificationSettings()).authorizationStatus);

  static Future<NotifStatus> _askPermission() async =>
      _of((await FirebaseMessaging.instance.requestPermission()).authorizationStatus);

  static Future<void> _openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  /// The current status; refused when it cannot be read.
  Future<NotifStatus> status() async {
    try {
      return await _read();
    } catch (_) {
      return NotifStatus.refused;
    }
  }

  /// Asks when not asked yet, otherwise opens the phone's settings, and
  /// returns the status as it stands now (refused if anything throws).
  Future<NotifStatus> askOrOpenSettings() async {
    try {
      final current = await _read();
      if (current == NotifStatus.notAsked) return await _ask();
      await _openSettings();
      return current;
    } catch (_) {
      return NotifStatus.refused;
    }
  }
}
