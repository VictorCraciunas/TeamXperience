import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/features/play_tab/logic/play_popup_texts.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/utils/event_formats.dart';

import 'card_handle.dart';
import 'clock_boxes.dart';
import 'icon_row.dart';
import 'popup_button.dart';
import 'stagger_in.dart';
import 'team_row.dart';
import 'ticket_card.dart';

/// Registered: the next game as a ticket with a live countdown, the team and
/// the meeting point (mockup 10).
class NextGameTicket extends StatelessWidget {
  const NextGameTicket({
    super.key,
    required this.event,
    required this.team,
    required this.now,
    required this.stagger,
    required this.onOpenEvent,
    required this.onOpenTeam,
  });

  final Event event;
  final Team? team;
  final DateTime now;
  final bool stagger;
  final VoidCallback onOpenEvent;
  final VoidCallback onOpenTeam;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final start = event.dateEvent;
    final left = clockParts(start == null ? Duration.zero : start.difference(now));
    String two(int n) => n.toString().padLeft(2, '0');
    final place = startPlace(event);
    final note = event.meetingPointNote?.trim() ?? '';
    final current = team;
    var i = 0;
    Widget row(Widget child) => StaggerIn(index: i++, play: stagger, child: child);

    return TicketCard(
      topFill: colors.navy,
      top: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHandle(color: colors.onNavy.withValues(alpha: .4)),
          row(Text('Următorul tău joc', style: TextStyle(fontSize: 12, height: 1.45, color: colors.onNavy.withValues(alpha: .8)))),
          row(Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(event.name ?? '', style: TextStyle(fontSize: 21, height: 1.25, fontWeight: FontWeight.w600, color: colors.onNavy)),
          )),
          if (start != null)
            row(Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                eventDayLine(start, event.arriveMinutesBefore),
                style: TextStyle(fontSize: 14, height: 1.45, color: colors.onNavy.withValues(alpha: .85)),
              ),
            )),
          row(Padding(
            padding: const EdgeInsets.only(top: 14),
            child: ClockBoxes(parts: [
              ('${left.days}', 'zile'),
              (two(left.hours), 'ore'),
              (two(left.minutes), 'min'),
              (two(left.seconds), 'sec'),
            ]),
          )),
        ],
      ),
      bottom: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (current != null) row(TeamRow(team: current, places: event.teamSizeMax, line: membersLine(current, event))),
          if (place != null)
            row(IconRow(
              icon: TablerIcons.map_pin,
              text: TextSpan(children: [
                const TextSpan(text: 'Start la '),
                TextSpan(text: place, style: const TextStyle(fontWeight: FontWeight.w600)),
                if (note.isNotEmpty) TextSpan(text: ', $note'),
              ]),
            )),
          row(PopupButton(label: 'Vezi evenimentul', onPressed: onOpenEvent)),
          const SizedBox(height: 8),
          row(PopupButton(label: 'Echipa mea', kind: PopupButtonKind.outline, onPressed: onOpenTeam)),
        ],
      ),
    );
  }
}
