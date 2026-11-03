import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/layout/outline_card.dart';
import 'package:teamxperience/utils/event_formats.dart';

import 'logistics_row.dart';
import 'mini_route_sketch.dart';

/// "Logistică": where to meet, when to be there, until when to sign up and
/// what to bring, under a little route sketch.
class LogisticsSection extends StatelessWidget {
  const LogisticsSection({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final start = event.dateEvent;
    final deadline = event.dateDeadlineEnrollment;
    final note = event.meetingPointNote?.trim() ?? '';
    final meeting = note.isNotEmpty ? note : (event.punctDeStart ?? '');
    final rows = [
      if (meeting.isNotEmpty) LogisticsRow(icon: TablerIcons.map_pin, lead: 'Start:', text: meeting),
      if (start != null) LogisticsRow(icon: TablerIcons.calendar, text: eventDayLine(start, event.arriveMinutesBefore)),
      if (deadline != null) LogisticsRow(icon: TablerIcons.hourglass, text: 'Înscrieri până pe ${dayAndMonth(deadline)}'),
      if (event.whatToBring.isNotEmpty) LogisticsRow(icon: TablerIcons.backpack, text: event.whatToBring.join(', ')),
    ];

    return OutlineCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const MiniRouteSketch(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < rows.length; i++) ...[if (i > 0) const SizedBox(height: 6), rows[i]],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
