import 'package:teamxperience/model/puzzle.dart';

import 'route_texts.dart';

const _words = ['nord', 'nord-est', 'est', 'sud-est', 'sud', 'sud-vest', 'vest', 'nord-vest'];

/// The way to go from a bearing in degrees (−180 to 360, 0 = north): eight
/// sectors of 45° centred on north.
String compassWord(double bearing) {
  final degrees = ((bearing % 360) + 360) % 360;
  return _words[((degrees + 22.5) ~/ 45) % 8];
}

/// "spre nord-est · ~2 min pe jos", walking at 80 m a minute.
String walkLine(double meters, double bearing) {
  final minutes = (meters / 80).ceil().clamp(1, 1 << 20);
  return 'spre ${compassWord(bearing)} · ~$minutes min pe jos';
}

/// "140 m" (rounded to ten), "1,2 km" from 995 m, "câțiva metri" under 20 m.
String shortDistance(double meters) {
  if (meters < 20) return 'câțiva metri';
  final rounded = (meters / 10).round() * 10;
  if (rounded < 1000) return '$rounded m';
  return '${(meters / 1000).toStringAsFixed(1).replaceAll('.', ',')} km';
}

enum DistanceTrend { closer, farther }

/// Closer or farther over the last three readings, when the newest differs
/// from the oldest of them by 3 m or more.
DistanceTrend? trendOf(List<double> readings) {
  if (readings.length < 3) return null;
  final last = readings.sublist(readings.length - 3);
  final change = last.last - last.first;
  if (change <= -3) return DistanceTrend.closer;
  if (change >= 3) return DistanceTrend.farther;
  return null;
}

String? trendLabel(DistanceTrend? trend) => switch (trend) {
      DistanceTrend.closer => 'mai aproape',
      DistanceTrend.farther => 'mai departe',
      null => null,
    };

/// Where a location puzzle sends the team; null unless both coordinates are set.
GeoPoint? locationTarget(Puzzle puzzle) {
  final lat = puzzle.latitude;
  final lng = puzzle.longitude;
  if (lat == null || lng == null) return null;
  return (lat: lat, lng: lng);
}

/// Inside the circle, its edge included.
bool insideCircle(double meters, int radius) => meters <= radius;
