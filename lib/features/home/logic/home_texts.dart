import 'package:teamxperience/utils/event_formats.dart';

/// "Sâm 14 nov · 10:00 · Piața Mare"; [place] is the event's start point.
String heroDateLine(DateTime start, String? place) {
  final time = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
  final where = place?.trim() ?? '';
  return [
    '${shortDay(start)} ${dayAndMonth(start)}',
    time,
    if (where.isNotEmpty) where,
  ].join(' · ');
}

/// A player's level and how far they are through it (0 to 1).
class PlayerLevel {
  const PlayerLevel(this.name, this.progress);

  final String name;
  final double progress;
}

const List<(String, int)> _levels = [
  ('Începător', 0),
  ('Explorator', 500),
  ('Cartograf', 1000),
  ('Legendă', 2500),
];

/// The level for [xp]: Începător 0, Explorator 500, Cartograf 1000,
/// Legendă 2500; Legendă is always full.
PlayerLevel levelFor(int xp) {
  final points = xp < 0 ? 0 : xp;
  for (var i = _levels.length - 1; i >= 0; i--) {
    final (name, from) = _levels[i];
    if (points < from) continue;
    if (i == _levels.length - 1) return PlayerLevel(name, 1);
    final to = _levels[i + 1].$2;
    return PlayerLevel(name, (points - from) / (to - from));
  }
  return PlayerLevel(_levels.first.$1, 0);
}

/// Everything about a player's level for the Profil tab: its name, the next
/// one and two ways of saying how far along: [progress] through the current
/// level (Home's bar) and [share] of the next level's XP (Profil's bar, which
/// agrees with "640 / 1000 XP"). Both stay between 0 and 1.
class LevelInfo {
  const LevelInfo({
    required this.name,
    required this.xp,
    required this.nextAt,
    required this.nextName,
    required this.progress,
    required this.share,
  });

  final String name;

  /// The XP, never below 0.
  final int xp;

  /// The XP the next level starts at; null at the top.
  final int? nextAt;
  final String? nextName;
  final double progress;
  final double share;
}

/// The level for [xp] with its next step (Legendă has none and is full).
LevelInfo levelInfo(int xp) {
  final points = xp < 0 ? 0 : xp;
  final level = levelFor(points);
  for (var i = 0; i < _levels.length; i++) {
    if (_levels[i].$1 != level.name) continue;
    if (i == _levels.length - 1) {
      return LevelInfo(name: level.name, xp: points, nextAt: null, nextName: null, progress: 1, share: 1);
    }
    final (nextName, nextAt) = _levels[i + 1];
    return LevelInfo(
      name: level.name,
      xp: points,
      nextAt: nextAt,
      nextName: nextName,
      progress: level.progress,
      share: points / nextAt,
    );
  }
  return LevelInfo(name: level.name, xp: points, nextAt: null, nextName: null, progress: 1, share: 1);
}

/// "12,4 km" for 12400 metres.
String kmStat(double meters) => formatKm(meters / 1000);
