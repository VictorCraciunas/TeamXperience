import 'package:flutter/widgets.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/utils/event_formats.dart';

/// "Sibiu, 14 noiembrie"; just the day without a city, nothing without a date.
String introDateLine(Event event) {
  final start = event.dateEvent;
  if (start == null) return '';
  final day = '${start.day} ${longMonth(start.month)}';
  final city = event.location?.trim() ?? '';
  return city.isEmpty ? day : '$city, $day';
}

/// The chips under the letter: missions, duration and hints ("6 misiuni",
/// "2 ore", "1 indiciu / misiune"). Missions and duration are left out when
/// unknown.
List<(IconData, String)> introFacts(Event event) {
  final missions = event.nrMissions;
  final minutes = event.effectiveDurationMinutes;
  final hints = event.hintsPerMission;
  return [
    if (missions > 0) (TablerIcons.map_pin, missions == 1 ? '1 misiune' : '$missions misiuni'),
    if (minutes != null && minutes > 0) (TablerIcons.hourglass, _duration(minutes)),
    (
      TablerIcons.bulb,
      switch (hints) {
        <= 0 => 'Fără indicii',
        1 => '1 indiciu / misiune',
        _ => '$hints indicii / misiune',
      },
    ),
  ];
}

/// "2 ore", "1 oră", "1 h 30", "45 min".
String _duration(int minutes) {
  if (minutes % 60 != 0) return formatDuration(minutes);
  final hours = minutes ~/ 60;
  return hours == 1 ? '1 oră' : '$hours ore';
}
