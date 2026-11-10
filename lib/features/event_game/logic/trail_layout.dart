import 'dart:ui';

import 'package:teamxperience/model/event.dart';

import 'route_texts.dart';

/// One stop on the route trail (mockup 06), bottom to top.
sealed class TrailStop {
  const TrailStop();
}

/// A solved mission: "1 · Scara Pasajului".
class DoneStop extends TrailStop {
  const DoneStop(this.number, this.title);

  final int number;
  final String title;

  String get label => '$number · $title';
}

/// The mission the team is on, drawn as a card.
class CurrentStop extends TrailStop {
  const CurrentStop(this.number, this.title, this.distance);

  final int number;
  final String title;

  /// "la 180 m de tine", or null when it cannot be measured.
  final String? distance;
}

/// Every mission after the current one, as one stop ("5 · 6").
class LockedStop extends TrailStop {
  const LockedStop(this.label);

  final String label;
}

/// The end of the route.
class FinishStop extends TrailStop {
  const FinishStop();
}

/// The stops for a team at [missionProgress] (missions solved).
List<TrailStop> trailStops(Event event, int missionProgress, String? distance) {
  final missions = event.missions;
  String title(int i) => missions[i].title?.trim().isNotEmpty == true ? missions[i].title?.trim() ?? '' : 'Misiunea ${i + 1}';
  final done = missionProgress.clamp(0, missions.length);
  return [
    for (var i = 0; i < done; i++) DoneStop(i + 1, title(i)),
    if (done < missions.length) CurrentStop(done + 1, title(done), distance),
    if (done + 1 < missions.length) LockedStop(lockedLabel([for (var i = done + 2; i <= missions.length; i++) i])),
    const FinishStop(),
  ];
}

const double _top = 40;

/// Where [count] stops sit, bottom to top, [spacing] apart, alternating
/// between 20 % and 68 % of [width] (the first on the left).
List<Offset> trailPoints(int count, {required double width, double spacing = 100}) => [
      for (var i = 0; i < count; i++)
        Offset(width * (i.isEven ? .2 : .68), (count - 1 - i) * spacing + _top),
    ];

/// The height a trail of [count] stops needs.
double trailHeight(int count, {double spacing = 100}) => (count - 1) * spacing + 2 * _top;

/// The cubic segments of a smooth curve through [points] (Catmull-Rom).
List<(Offset, Offset, Offset, Offset)> _segments(List<Offset> points) {
  Offset at(int i) => points[i.clamp(0, points.length - 1)];
  return [
    for (var i = 0; i < points.length - 1; i++)
      (
        at(i),
        at(i) + (at(i + 1) - at(i - 1)) / 6,
        at(i + 1) - (at(i + 2) - at(i)) / 6,
        at(i + 1),
      ),
  ];
}

Path _pathOf(Iterable<(Offset, Offset, Offset, Offset)> segments) {
  final path = Path();
  var first = true;
  for (final (start, c1, c2, end) in segments) {
    if (first) path.moveTo(start.dx, start.dy);
    first = false;
    path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
  }
  return path;
}

/// A smooth line through every point; empty for fewer than two.
Path trailPath(List<Offset> points) => _pathOf(_segments(points));

/// How far along [trailPath] the stop at [index] is, so the line can be solid
/// up to it.
double trailLengthTo(List<Offset> points, int index) {
  var length = 0.0;
  for (final segment in _segments(points).take(index)) {
    for (final metric in _pathOf([segment]).computeMetrics()) {
      length += metric.length;
    }
  }
  return length;
}
