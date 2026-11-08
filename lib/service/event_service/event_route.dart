import 'package:latlong2/latlong.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/mission.dart';

/// How many pieces each leg of a smoothed line is cut into.
const int _piecesPerLeg = 8;

LatLng? _pointOf(double? lat, double? lng) => lat != null && lng != null ? LatLng(lat, lng) : null;

/// Where a mission happens: its pin, else its first location puzzle.
LatLng? _missionPoint(Mission mission) {
  final pin = _pointOf(mission.latitude, mission.longitude);
  if (pin != null) return pin;
  for (final puzzle in mission.puzzles) {
    final point = _pointOf(puzzle.latitude, puzzle.longitude);
    if (point != null) return point;
  }
  return null;
}

/// The route: the start, the missions that have a place, the finish.
List<LatLng> routePoints(Event event) => [
      _pointOf(event.startLatitude, event.startLongitude),
      for (final mission in event.missions) _missionPoint(mission),
      _pointOf(event.finishLatitude, event.finishLongitude),
    ].nonNulls.toList();

/// A curve through [points] (Catmull-Rom), so a bend does not show exactly
/// where a mission is the way a sharp corner would. It passes through every
/// point and ends exactly on the last one.
List<LatLng> smoothLine(List<LatLng> points) {
  if (points.length < 3) return points;
  LatLng at(int i) => points[i.clamp(0, points.length - 1)];
  double curve(double a, double b, double c, double d, double t) =>
      0.5 * (2 * b + (c - a) * t + (2 * a - 5 * b + 4 * c - d) * t * t + (3 * b - a - 3 * c + d) * t * t * t);
  return [
    for (var leg = 0; leg < points.length - 1; leg++) ...[
      points[leg],
      for (var piece = 1; piece < _piecesPerLeg; piece++)
        LatLng(
          curve(at(leg - 1).latitude, at(leg).latitude, at(leg + 1).latitude, at(leg + 2).latitude, piece / _piecesPerLeg),
          curve(at(leg - 1).longitude, at(leg).longitude, at(leg + 1).longitude, at(leg + 2).longitude, piece / _piecesPerLeg),
        ),
    ],
    points.last,
  ];
}
