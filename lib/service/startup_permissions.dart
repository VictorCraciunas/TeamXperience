import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'FCMService.dart';

/// The phone's own permission prompts, shown one after another the first
/// time a signed-in screen opens on this phone (the player's shell or the
/// organiser's home): notifications, then location while the app is in use
/// (never in the background), then the camera. Once per install, not per
/// account: the flag lives in shared_preferences. A refusal changes nothing
/// here; the game still asks again at the moment of need (geolocation puzzle,
/// camera for the team photo, Profil's notifications row).
///
/// The flag store and the requesters can be passed in (tests); [shared] uses
/// the phone's.
class StartupPermissions {
  StartupPermissions({
    required Future<bool> Function() alreadyAsked,
    required Future<void> Function() markAsked,
    required List<Future<void> Function()> asks,
  })  : _alreadyAsked = alreadyAsked,
        _markAsked = markAsked,
        _asks = asks;

  /// The one the screens use: the phone's prompts and flag.
  static final StartupPermissions shared = StartupPermissions(
    alreadyAsked: _readFlag,
    markAsked: _writeFlag,
    asks: [_askNotifications, _askLocation, _askCamera],
  );

  static const String flagKey = 'startup_permissions_asked';

  final Future<bool> Function() _alreadyAsked;
  final Future<void> Function() _markAsked;
  final List<Future<void> Function()> _asks;

  Future<void>? _running;

  /// Shows the prompts unless this phone already went through them. Never
  /// throws. A call while they are showing waits for the same run.
  Future<void> askOnce() => _running ??= _run();

  Future<void> _run() async {
    try {
      if (await _alreadyAsked()) return;
    } catch (_) {
      // Unreadable flag: better no prompts than prompts on every start.
      return;
    }
    for (final ask in _asks) {
      try {
        await ask();
      } catch (_) {
        // A prompt that fails (or one already showing) does not stop the next.
      }
    }
    // Set after the prompts, so an app closed halfway asks the rest next time.
    try {
      await _markAsked();
    } catch (_) {}
  }

  static Future<bool> _readFlag() async =>
      (await SharedPreferences.getInstance()).getBool(flagKey) ?? false;

  static Future<void> _writeFlag() async {
    await (await SharedPreferences.getInstance()).setBool(flagKey, true);
  }

  /// Shows nothing when the phone already has an answer. A yes here is saved
  /// for the signed-in user at once, not waited on.
  static Future<void> _askNotifications() async {
    await FirebaseMessaging.instance.requestPermission();
    unawaited(FCMService.saveTokenAfterPrompt());
  }

  /// While in use only: the manifest and Info.plist declare no background
  /// location, so geolocator never asks for it.
  static Future<void> _askLocation() async {
    if (await Geolocator.checkPermission() == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
  }

  static Future<void> _askCamera() async {
    await Permission.camera.request();
  }
}
