import 'dart:math' as math;

import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

/// True when the team solved every mission of an event that has missions.
bool routeCompleted(Event event, Team team) {
  final total = event.missions.length;
  return total > 0 && team.missionProgress >= total;
}

String? _clean(String? text) {
  final value = text?.trim() ?? '';
  return value.isEmpty ? null : value;
}

/// The finish screen's title and line: the organiser's for a complete route,
/// else the defaults; a partial result (the event ended first) says so.
({String title, String message}) finishTexts(Event event, Team team) {
  final total = event.missions.length;
  if (!routeCompleted(event, team)) {
    final solved = math.min(team.missionProgress, total);
    return (title: 'Jocul s-a încheiat', message: '${team.name} a rezolvat $solved din $total misiuni.');
  }
  return (
    title: _clean(event.finishTitle) ?? 'Ați terminat traseul!',
    message: _clean(event.finishMessage)?.replaceAll('{team}', team.name) ??
        '${team.name} a rezolvat toate cele $total misiuni.',
  );
}

/// "din 12 echipe", "din 1 echipă".
String placeLabel(int teams) => teams == 1 ? 'din 1 echipă' : 'din $teams echipe';

/// How long the team played: from its start (else the event's) to its
/// finish; a partial result runs to [now], but never past the game's end.
Duration playedTime(Event event, Team team, DateTime now) {
  final start = team.startedAt ?? event.dateEvent;
  if (start == null) return Duration.zero;
  // A complete route ends at its finish, or at its last mission when the
  // finish time was never written (offline, app closed).
  final finish = team.finishedAt ?? team.lastMissionAt;
  if (finish != null && routeCompleted(event, team)) return finish.difference(start);
  final close = (event.dateEvent ?? start).add(event.playTime);
  final end = now.isBefore(close) ? now : close;
  return end.difference(start);
}

/// "1:48"; "0:00" for nothing or less.
String hoursMinutes(Duration d) {
  if (d.isNegative) return '0:00';
  return '${d.inHours}:${d.inMinutes.remainder(60).toString().padLeft(2, '0')}';
}

/// "4,7".
String kmLabel(double meters) => (meters / 1000).toStringAsFixed(1).replaceAll('.', ',');

/// The quickest solved mission (1-based) and its minutes: each mission from
/// the one before it, the first from the team's start. Null when no mission
/// can be measured.
({int mission, int minutes})? fastestMission(Team team) {
  ({int mission, int minutes})? best;
  Duration? bestTime;
  final done = team.missionCompletedAt;
  for (final index in done.keys.toList()..sort()) {
    final end = done[index];
    final begin = index == 0 ? team.startedAt : done[index - 1];
    if (end == null || begin == null) continue;
    final took = end.difference(begin);
    if (took.isNegative) continue;
    final current = bestTime;
    if (current == null || took < current) {
      bestTime = took;
      best = (mission: index + 1, minutes: math.max(1, (took.inSeconds / 60).round()));
    }
  }
  return best;
}

/// "Cea mai rapidă: misiunea 2 (6 min)".
String fastestLine(({int mission, int minutes}) fastest) =>
    'Cea mai rapidă: misiunea ${fastest.mission} (${fastest.minutes} min)';

/// "2 indicii", "1 indiciu", "fără indicii".
String hintsLabel(Team team) {
  final used = team.hintsUsed.values.where((v) => v).length;
  if (used == 0) return 'fără indicii';
  if (used == 1) return '1 indiciu';
  return '$used indicii';
}

/// The team's approved photos that have a picture, one per puzzle, in
/// mission and puzzle order.
List<String> approvedPhotos(Team team) => [for (final photo in approvedPuzzlePhotos(team)) photo.url];

/// The same photos with the (zero-based) mission each belongs to.
List<({int mission, String url})> approvedPuzzlePhotos(Team team) {
  final best = <(int, int), (int, String)>{};
  team.photoDetails.forEach((key, detail) {
    final url = detail.url;
    if (detail.status != PhotoApprovalStatus.approved || url == null) return;
    final parts = key.split('_');
    if (parts.length != 3) return;
    final mission = int.tryParse(parts[0]);
    final puzzle = int.tryParse(parts[1]);
    final attempt = int.tryParse(parts[2]);
    if (mission == null || puzzle == null || attempt == null) return;
    final current = best[(mission, puzzle)];
    if (current == null || attempt > current.$1) best[(mission, puzzle)] = (attempt, url);
  });
  final order = best.keys.toList()..sort((a, b) => a.$1 != b.$1 ? a.$1.compareTo(b.$1) : a.$2.compareTo(b.$2));
  return [for (final k in order) (mission: k.$1, url: best[k]?.$2 ?? '')];
}

/// What "Distribuie" shares.
String shareLine(Event event, Team team, ({int place, int teams})? place, Duration time, double meters) {
  final where = place == null ? '' : ' pe locul ${place.place} din ${place.teams},';
  return '${team.name} a terminat „${event.name ?? ''}”$where în ${hoursMinutes(time)} '
      'și ${kmLabel(meters)} km. #TeamXperience';
}
