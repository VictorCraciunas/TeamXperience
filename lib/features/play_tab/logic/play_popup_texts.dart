import 'package:teamxperience/features/home/logic/live_texts.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/utils/event_formats.dart';

/// The boxes of a countdown.
typedef ClockParts = ({int days, int hours, int minutes, int seconds});

/// [left] in days, hours, minutes and seconds; all 0 once it has passed.
ClockParts clockParts(Duration left) {
  final t = left.isNegative ? Duration.zero : left;
  return (
    days: t.inDays,
    hours: t.inHours.remainder(24),
    minutes: t.inMinutes.remainder(60),
    seconds: t.inSeconds.remainder(60),
  );
}

/// "3 din 4 membri".
String membersLine(Team team, Event event) => '${team.memberList.length} din ${event.teamSizeMax} membri';

/// "3 din 4 sunt aici": the members seen in the last two minutes.
String hereLine(Team team, Event event, DateTime now) =>
    '${activeMembers(team, now).length} din ${event.teamSizeMax} sunt aici';

/// Where the game starts ("Piața Mare"), or null when the event has none.
String? startPlace(Event event) {
  final place = event.punctDeStart?.trim();
  return place == null || place.isEmpty ? null : place;
}

String? _missionTitle(Event event, int index) {
  if (index < 0 || index >= event.missions.length) return null;
  final title = event.missions[index].title?.trim();
  return title == null || title.isEmpty ? null : title;
}

/// "Misiunea 4 din 6 · Fântâna cu lei", without the name when the mission
/// has none.
String missionTitleLine(Event event, Team team) {
  final total = event.nrMissions;
  final current = total <= 0 ? team.missionProgress + 1 : (team.missionProgress + 1).clamp(1, total);
  final head = total <= 0 ? 'Misiunea $current' : 'Misiunea $current din $total';
  final title = _missionTitle(event, current - 1);
  return title == null ? head : '$head · $title';
}

/// "1 h 12 min", or "12 min" under an hour; never negative.
String hoursMinutes(Duration left) {
  final t = left.isNegative ? Duration.zero : left;
  final minutes = t.inMinutes.remainder(60);
  return t.inHours == 0 ? '$minutes min' : '${t.inHours} h $minutes min';
}

/// The last mission the team solved and how long ago ("acum 6 min"), or null
/// before the first one. The title is null when the mission has no name.
({String? title, String ago})? lastSolved(Event event, Team team, DateTime now) {
  MapEntry<int, DateTime>? last;
  for (final entry in team.missionCompletedAt.entries) {
    final current = last;
    if (current == null || entry.value.isAfter(current.value)) last = entry;
  }
  final found = last;
  if (found == null) return null;
  final ago = now.difference(found.value);
  final when = switch (ago.inMinutes) {
    < 1 => 'câteva secunde',
    < 60 => '${ago.inMinutes} min',
    _ => '${ago.inHours} h',
  };
  return (title: _missionTitle(event, found.key), ago: 'acum $when');
}

/// "Sâm 14 nov · 11:00".
String suggestionWhen(DateTime d) =>
    '${shortDay(d)} ${dayAndMonth(d)} · ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
