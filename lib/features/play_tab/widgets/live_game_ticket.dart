import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/features/play_tab/logic/play_popup_texts.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/service/leaderboard.dart';
import 'package:teamxperience/ui/ui.dart';

import 'card_handle.dart';
import 'game_pill.dart';
import 'icon_row.dart';
import 'live_stat_box.dart';
import 'mission_bar.dart';
import 'popup_button.dart';
import 'stagger_in.dart';
import 'ticket_card.dart';

/// Playing: the mission, the missions bar, time left, the team's place and
/// "Continuă jocul" (mockup 10).
class LiveGameTicket extends StatelessWidget {
  const LiveGameTicket({
    super.key,
    required this.event,
    required this.team,
    required this.ranked,
    required this.now,
    required this.stagger,
    required this.onContinue,
    required this.onChat,
  });

  final Event event;
  final Team team;
  final List<RankedTeam> ranked;
  final DateTime now;
  final bool stagger;
  final VoidCallback onContinue;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final start = event.dateEvent;
    // The game's end, as Home's live card counts it.
    final left = start == null ? Duration.zero : start.add(event.playTime).difference(now);
    final own = ranked.where((r) => r.team.name == team.name).firstOrNull;
    final solved = lastSolved(event, team, now);
    var i = 0;
    Widget row(Widget child) => StaggerIn(index: i++, play: stagger, child: child);

    final solvedText = switch (solved) {
      null => const TextSpan(text: 'Nicio misiune rezolvată încă'),
      (title: final String title, :final ago) => TextSpan(children: [
          const TextSpan(text: 'Ultima rezolvată: '),
          TextSpan(text: title, style: const TextStyle(fontWeight: FontWeight.w600)),
          TextSpan(text: ', $ago'),
        ]),
      (title: null, :final ago) => TextSpan(text: 'Ultima misiune rezolvată $ago'),
    };

    return TicketCard(
      topFill: colors.liveCard,
      top: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHandle(color: colors.onNavy.withValues(alpha: .4)),
          row(Align(
            alignment: Alignment.centerLeft,
            child: GamePill(icon: TablerIcons.player_play, label: 'În joc', fill: colors.live, text: colors.onNavy),
          )),
          row(Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(event.name ?? '', style: TextStyle(fontSize: 21, height: 1.25, fontWeight: FontWeight.w600, color: colors.onNavy)),
          )),
          row(Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              missionTitleLine(event, team),
              style: TextStyle(fontSize: 14, height: 1.45, color: colors.onNavy.withValues(alpha: .85)),
            ),
          )),
          if (event.nrMissions > 0)
            row(Padding(
              padding: const EdgeInsets.only(top: 12),
              child: MissionBar(total: event.nrMissions, current: team.missionProgress),
            )),
          row(Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                Expanded(child: LiveStatBox(value: hoursMinutes(left), label: 'rămase')),
                if (own != null) ...[
                  const SizedBox(width: 8),
                  Expanded(child: LiveStatBox(value: 'Locul ${own.place}', label: 'din ${ranked.length} echipe')),
                ],
              ],
            ),
          )),
        ],
      ),
      bottom: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row(IconRow(icon: TablerIcons.circle_check, text: solvedText)),
          row(PopupButton(
            label: 'Continuă jocul',
            kind: PopupButtonKind.tick,
            icon: const Icon(TablerIcons.player_play),
            onPressed: onContinue,
          )),
          const SizedBox(height: 8),
          row(PopupButton(
            label: 'Scrie organizatorului',
            kind: PopupButtonKind.outline,
            icon: const Icon(TablerIcons.message_circle),
            onPressed: onChat,
          )),
        ],
      ),
    );
  }
}
