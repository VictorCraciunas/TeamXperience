import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/features/home/logic/live_texts.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/components/route/mission_progress_line.dart';
import 'package:teamxperience/ui/ui.dart';

import 'game_badge.dart';
import 'live_halo.dart';
import 'game_card_button.dart';
import 'navy_game_card.dart';

/// The game in progress, as mockup 02's second phone: LIVE and the time
/// left, the name, team and mission, the missions on a line, then
/// "Continuă jocul" and the chat button.
class LiveGameCard extends StatelessWidget {
  const LiveGameCard({
    super.key,
    required this.event,
    required this.team,
    required this.now,
    required this.onContinue,
    required this.onChat,
  });

  final Event event;
  final Team team;
  final DateTime now;
  final VoidCallback onContinue;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final start = event.dateEvent;
    final left = start == null ? Duration.zero : start.add(Event.maxDuration).difference(now);
    final onNavy = colors.onNavy;

    return NavyGameCard(
      fill: NavyFill.live,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                LiveHalo(color: colors.live, child: GameBadge(label: 'LIVE', fill: colors.live, text: onNavy)),
                const SizedBox(width: 6),
                // Shrinks rather than overflowing with very large text.
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            liveClock(left),
                            style: TextStyle(
                              fontFamily: 'Monospace',
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              height: 1.45,
                              color: onNavy,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'rămase',
                            style: TextStyle(fontSize: 13, height: 1.45, color: onNavy.withValues(alpha: .7)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              event.name ?? '',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, height: 1.45, color: onNavy),
            ),
            Text(
              missionLine(team, event.nrMissions),
              style: TextStyle(fontSize: 13, height: 1.45, color: onNavy.withValues(alpha: .8)),
            ),
            MissionProgressLine(total: event.nrMissions, done: team.missionProgress),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: GameCardButton(label: 'Continuă jocul', onTap: onContinue)),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 42,
                    child: Material(
                      color: onNavy.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: onChat,
                        borderRadius: BorderRadius.circular(12),
                        child: Icon(TablerIcons.message_circle, size: 18, color: onNavy),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
