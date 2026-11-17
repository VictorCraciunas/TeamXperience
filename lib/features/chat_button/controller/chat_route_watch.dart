import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../logic/chat_button_shown.dart';

/// Knows the route on top of the app's navigator, for the floating chat
/// button: the chat counts as read while it is on top, and the button hides
/// on some pages. Registered in `MaterialApp.navigatorObservers`.
class ChatRouteWatch extends NavigatorObserver with ChangeNotifier {
  /// The one MaterialApp uses.
  static final shared = ChatRouteWatch();

  final List<Route<dynamic>> _stack = [];
  bool _scheduled = false;

  Route<dynamic>? get topRoute => _stack.isEmpty ? null : _stack.last;

  TopRoute? get top {
    final route = topRoute;
    if (route == null) return null;
    return TopRoute(name: route.settings.name, isPage: route is PageRoute, arguments: route.settings.arguments);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.add(route);
    _changed();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.remove(route);
    _changed();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.remove(route);
    _changed();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final at = oldRoute == null ? -1 : _stack.indexOf(oldRoute);
    if (newRoute == null) {
      if (at >= 0) _stack.removeAt(at);
    } else if (at >= 0) {
      _stack[at] = newRoute;
    } else {
      _stack.add(newRoute);
    }
    _changed();
  }

  /// The navigator calls these while it builds: listeners hear after the
  /// frame, once per frame.
  void _changed() {
    if (_scheduled) return;
    _scheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      notifyListeners();
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }
}
