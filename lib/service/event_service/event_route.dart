import 'package:latlong2/latlong.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/mission.dart';

/// How many times [smoothLine] cuts the corners.
const int _smoothingRounds = 3;

LatLng? _pointOf(double? lat, double? lng) => lat != null && lng != null ? LatLng(lat, lng) : null;

/// Where a mission happens: its pin, else its first location puzzle.
LatLng? _missionPoint(Mission mission) {
  final pin = _pointOf(mission.latitude, mission.longitude);
  if (pin != null) return pin;
  for (final puzzle in mission.puzzles) {
    if (puzzle.type != PuzzleType.geolocation) continue;
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

LatLng _between(LatLng a, LatLng b, double t) =>
    LatLng(a.latitude + (b.latitude - a.latitude) * t, a.longitude + (b.longitude - a.longitude) * t);

/// A rounded line that follows [points] without touching the ones in the
/// middle (Chaikin's corner cutting), so it shows the way of a route and not
/// where its missions are. Both ends stay exactly where they are.
List<LatLng> smoothLine(List<LatLng> points) {
  if (points.length < 3) return points;
  var line = points;
  for (var round = 0; round < _smoothingRounds; round++) {
    line = [
      line.first,
      for (var i = 0; i < line.length - 1; i++) ...[
        _between(line[i], line[i + 1], .25),
        _between(line[i], line[i + 1], .75),
      ],
      line.last,
    ];
  }
  return line;
}
