import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/features/play_tab/logic/play_popup_texts.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/ui.dart';

import 'card_handle.dart';
import 'clock_boxes.dart';
import 'game_pill.dart';
import 'icon_row.dart';
import 'popup_button.dart';
import 'stagger_in.dart';
import 'team_row.dart';
import 'ticket_card.dart';

/// Start window: the same ticket, counting down the time left to enter, with
/// the start-code button (mockup 10).
class StartCodeTicket extends StatelessWidget {
  const StartCodeTicket({
    super.key,
    required this.event,
    required this.team,
    required this.now,
    required this.stagger,
    required this.onEnterCode,
  });

  final Event event;
  final Team? team;
  final DateTime now;
  final bool stagger;
  final VoidCallback onEnterCode;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final start = event.dateEvent;
    final left = start == null ? Duration.zero : start.add(event.enterWindow).difference(now);
    final total = left.isNegative ? Duration.zero : left;
    String two(int n) => n.toString().padLeft(2, '0');
    final place = startPlace(event);
    final current = team;
    var i = 0;
    Widget row(Widget child) => StaggerIn(index: i++, play: stagger, child: child);

    return TicketCard(
      topFill: colors.navy,
      top: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHandle(color: colors.onNavy.withValues(alpha: .4)),
          row(Align(
            alignment: Alignment.centerLeft,
            child: GamePill(icon: TablerIcons.clock, label: 'A început', fill: colors.soon, text: colors.onTick),
          )),
          row(Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(event.name ?? '', style: TextStyle(fontSize: 21, height: 1.25, fontWeight: FontWeight.w600, color: colors.onNavy)),
          )),
          row(Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              'Mai ai timp să intri în joc',
              style: TextStyle(fontSize: 14, height: 1.45, color: colors.onNavy.withValues(alpha: .85)),
            ),
          )),
          row(Padding(
            padding: const EdgeInsets.only(top: 14),
            child: ClockBoxes(parts: [
              (two(total.inMinutes), 'min'),
              (two(total.inSeconds.remainder(60)), 'sec'),
            ]),
          )),
        ],
      ),
      bottom: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (current != null) row(TeamRow(team: current, places: event.teamSizeMax, line: hereLine(current, event, now))),
          if (place != null)
            row(IconRow(
              icon: TablerIcons.message_circle,
              text: TextSpan(children: [
                const TextSpan(text: 'Codul îl primești de la organizator la '),
                TextSpan(text: place, style: const TextStyle(fontWeight: FontWeight.w600)),
              ]),
            )),
          row(PopupButton(
            label: 'Introdu codul de start',
            kind: PopupButtonKind.tick,
            icon: const Icon(TablerIcons.key),
            onPressed: onEnterCode,
          )),
        ],
      ),
    );
  }
}
