import 'package:geolocator/geolocator.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/features/home/logic/live_texts.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/service/leaderboard.dart';

typedef GeoPoint = ({double lat, double lng});

/// "Vulpile · locul 2 din 12".
String placeLine(String team, int place, int teams) => '$team · locul $place din $teams';

/// The team called [name]'s place among [teams] (ranked as on Home), with
/// how many teams there are; null when it is not among them.
({int place, int teams})? placeOf(List<Team> teams, String name, int missionCount) {
  for (final ranked in rankTeams(teams, missionCount: missionCount)) {
    if (ranked.team.name == name) return (place: ranked.place, teams: teams.length);
  }
  return null;
}

/// How long the team has been playing: from its own start, else the event's
/// start; "0:42:18", never negative.
String playedClock(DateTime? startedAt, DateTime? eventStart, DateTime now) {
  final start = startedAt ?? eventStart;
  if (start == null) return liveClock(Duration.zero);
  return liveClock(now.difference(start));
}

/// How long until the game closes ([Event.playTime] after the start).
String leftClock(Event event, DateTime now) {
  final start = event.dateEvent;
  if (start == null) return liveClock(Duration.zero);
  return liveClock(start.add(event.playTime).difference(now));
}

/// The time left in an organiser's walk-through, counted from when it began:
/// the event's own date means nothing there.
String previewLeftClock(Event event, DateTime? startedAt, DateTime now) {
  if (startedAt == null) return liveClock(event.playTime);
  return liveClock(startedAt.add(event.playTime).difference(now));
}

/// Where a mission is: its own place, else its first location puzzle with
/// both coordinates; null when neither.
GeoPoint? missionPoint(Mission mission) {
  final lat = mission.latitude;
  final lng = mission.longitude;
  if (lat != null && lng != null) return (lat: lat, lng: lng);
  for (final puzzle in mission.puzzles) {
    final pLat = puzzle.latitude;
    final pLng = puzzle.longitude;
    if (puzzle.type == PuzzleType.geolocation && pLat != null && pLng != null) return (lat: pLat, lng: pLng);
  }
  return null;
}

/// "la 180 m de tine" (rounded to ten), "la 1,2 km de tine", or "chiar aici"
/// under 20 m.
String distanceText(double meters) {
  if (meters < 20) return 'chiar aici';
  final rounded = (meters / 10).round() * 10;
  if (rounded < 1000) return 'la $rounded m de tine';
  return 'la ${(meters / 1000).toStringAsFixed(1).replaceAll('.', ',')} km de tine';
}

/// The distance line from the team's last position to a mission; null when
/// either is unknown. A team that has no position yet is stored at (0, 0).
String? distanceLine(GeoPoint? from, GeoPoint? to) {
  if (from == null || to == null) return null;
  if (from.lat == 0 && from.lng == 0) return null;
  return distanceText(Geolocator.distanceBetween(from.lat, from.lng, to.lat, to.lng));
}

/// The locked missions as one label: "5 · 6", "5 · 6 · 7", "5–8".
String lockedLabel(List<int> numbers) {
  if (numbers.isEmpty) return '';
  if (numbers.length > 3) return '${numbers.first}–${numbers.last}';
  return numbers.join(' · ');
}
