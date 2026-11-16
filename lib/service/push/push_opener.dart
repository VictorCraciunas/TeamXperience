import 'package:flutter/widgets.dart';

import 'push_navigation.dart';

enum _Stage { starting, signedIn, signedOut }

/// Holds a tapped push until the app is ready to open it. A push that started
/// the app waits for the user to load and their home to show, so it never
/// races the start-up redirect; once signed out, a tap is dropped (it was for
/// the account that left).
class PushOpener {
  PushOpener({required void Function(Map<String, dynamic> data) go}) : _go = go;

  /// The app's navigator (MaterialApp's `navigatorKey`), which pushes open from.
  static final navigatorKey = GlobalKey<NavigatorState>();

  /// The one the app uses: FCM and the shown notifications hand it their taps.
  static final instance = PushOpener(go: (data) => openPush(navigatorKey, data));

  final void Function(Map<String, dynamic> data) _go;
  _Stage _stage = _Stage.starting;
  Map<String, dynamic>? _waiting;

  /// A tapped push's data.
  void open(Map<String, dynamic> data) {
    switch (_stage) {
      case _Stage.starting:
        _waiting = data;
      case _Stage.signedIn:
        _go(data);
      case _Stage.signedOut:
        return;
    }
  }

  /// The first screen is up: the user's home, or the start when [signedIn] is false.
  void landed({required bool signedIn}) {
    _stage = signedIn ? _Stage.signedIn : _Stage.signedOut;
    final waiting = _waiting;
    _waiting = null;
    if (signedIn && waiting != null) _go(waiting);
  }
}
