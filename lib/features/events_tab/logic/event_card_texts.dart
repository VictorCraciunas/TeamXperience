import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/utils/event_formats.dart';

/// "azi", "mâine", "peste 3 zile", counting calendar days.
String untilText(DateTime now, DateTime start) {
  final days = DateTime.utc(start.year, start.month, start.day)
      .difference(DateTime.utc(now.year, now.month, now.day))
      .inDays;
  if (days <= 0) return 'azi';
  if (days == 1) return 'mâine';
  return 'peste $days zile';
}

/// The amber badge on an event card, only when five places or fewer are left.
String? spotsBadge(int? maxTeams, int teamsCount) {
  if (maxTeams == null) return null;
  final left = maxTeams - teamsCount;
  if (left > 5) return null;
  if (left <= 0) return 'Nu mai sunt locuri';
  if (left == 1) return 'Mai e un loc';
  return 'Mai sunt $left locuri';
}

/// "Sâm 21 nov".
String cardDate(DateTime d) => '${shortDay(d)} ${dayAndMonth(d)}';

/// "3,2 km · 1 h 30", with only the parts the event has.
String cardRouteFacts(Event e) {
  final km = e.effectiveRouteKm;
  final minutes = e.effectiveDurationMinutes;
  return [
    if (km != null) formatKm(km),
    if (minutes != null) formatDuration(minutes),
  ].join(' · ');
}
