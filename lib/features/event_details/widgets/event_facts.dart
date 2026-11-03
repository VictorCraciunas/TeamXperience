import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/event/date_fact_tile.dart';
import 'package:teamxperience/ui/components/event/difficulty_dots.dart';
import 'package:teamxperience/ui/components/event/fact_row.dart';
import 'package:teamxperience/ui/components/event/fact_tile.dart';
import 'package:teamxperience/utils/event_formats.dart';

/// Date, duration, difficulty and registered teams under the route strip.
/// A fact the event does not have is left out.
class EventFacts extends StatelessWidget {
  const EventFacts({super.key, required this.event, required this.teamsCount});

  final Event event;
  final int teamsCount;

  @override
  Widget build(BuildContext context) {
    final date = event.dateEvent;
    final minutes = event.effectiveDurationMinutes;
    final difficulty = event.effectiveDifficulty;

    return FactRow(
      date: date == null
          ? const DateFactTile(day: '–', detail: 'fără dată')
          : DateFactTile(day: '${date.day}', detail: monthAndTime(date)),
      facts: [
        if (minutes != null) FactTile(icon: TablerIcons.clock, value: formatDuration(minutes), label: 'durată'),
        if (difficulty != null)
          FactTile(
            leading: DifficultyDots(level: difficultyLevel(difficulty)),
            value: difficultyLabel(difficulty),
            label: 'dificultate',
          ),
        FactTile(icon: TablerIcons.users, value: '$teamsCount', label: 'echipe'),
      ],
    );
  }
}
