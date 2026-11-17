import 'package:flutter/widgets.dart';

/// What each page tells the floating chat button: how much of the bottom of
/// the screen its bar takes (the button sits above it), or that the button
/// should hide while something of the page is open. Pages report through
/// `ChatButtonClearance`, by route, so only the page on top counts.
class ChatButtonSpots extends ChangeNotifier {
  final Map<Route<dynamic>, Map<Object, _Spot>> _spots = {};

  void report(Route<dynamic> route, Object owner, {double clearance = 0, bool hide = false}) {
    final spots = _spots.putIfAbsent(route, () => {});
    final old = spots[owner];
    if (old != null && old.hide == hide && (old.clearance - clearance).abs() < 0.5) return;
    spots[owner] = _Spot(clearance, hide);
    notifyListeners();
  }

  void remove(Route<dynamic> route, Object owner) {
    final spots = _spots[route];
    if (spots == null || spots.remove(owner) == null) return;
    if (spots.isEmpty) _spots.remove(route);
    notifyListeners();
  }

  /// The tallest bar of [route] (0 for none).
  double clearanceFor(Route<dynamic>? route) {
    var most = 0.0;
    for (final spot in _spots[route]?.values ?? const <_Spot>[]) {
      if (spot.clearance > most) most = spot.clearance;
    }
    return most;
  }

  bool hiddenOn(Route<dynamic>? route) => _spots[route]?.values.any((s) => s.hide) ?? false;
}

class _Spot {
  const _Spot(this.clearance, this.hide);

  final double clearance;
  final bool hide;
}
