import 'package:geolocator/geolocator.dart';

/// One position fix: where, how accurate (metres) and when.
class WalkFix {
  const WalkFix({required this.lat, required this.lng, required this.accuracy, required this.at});

  final double lat;
  final double lng;
  final double accuracy;
  final DateTime at;
}

/// Adds up how far one phone walked from its position fixes, leaving out GPS
/// noise: a fix less accurate than 30 m is ignored, and so is a jump of more
/// than 50 m within 5 s (the last kept point stays where it was).
class WalkTracker {
  static const double worstAccuracy = 30;
  static const double jumpMetres = 50;
  static const Duration jumpWindow = Duration(seconds: 5);

  WalkFix? _last;
  double _total = 0;
  double _pending = 0;

  /// Everything counted so far.
  double get total => _total;

  /// Counts [fix]; returns the metres it added.
  double add(WalkFix fix) {
    if (fix.accuracy > worstAccuracy) return 0;
    final last = _last;
    if (last == null) {
      _last = fix;
      return 0;
    }
    final metres = Geolocator.distanceBetween(last.lat, last.lng, fix.lat, fix.lng);
    if (metres > jumpMetres && fix.at.difference(last.at) < jumpWindow) return 0;
    _last = fix;
    _total += metres;
    _pending += metres;
    return metres;
  }

  /// The metres not sent yet, once they reach [atLeast] (then cleared);
  /// otherwise 0 and they stay pending. `atLeast: 0` sends whatever is left.
  double takePending({double atLeast = 20}) {
    if (_pending <= 0 || _pending < atLeast) return 0;
    final out = _pending;
    _pending = 0;
    return out;
  }
}
