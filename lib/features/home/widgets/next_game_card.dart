import 'package:flutter/material.dart';
import 'package:teamxperience/features/home/logic/home_texts.dart';
import 'package:teamxperience/features/home/logic/preparation_steps.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/components/event/countdown_boxes.dart';
import 'package:teamxperience/ui/components/route/checkpoint_line.dart';
import 'package:teamxperience/ui/ui.dart';

import 'game_badge.dart';
import 'navy_game_card.dart';

/// The player's next registered game, as mockup 02's first card: badge,
/// name, day line, countdown, then (once the team is known) its preparation.
class NextGameCard extends StatelessWidget {
  const NextGameCard({
    super.key,
    required this.event,
    required this.left,
    required this.now,
    this.team,
    required this.onTap,
  });

  final Event event;
  final Duration left;
  final DateTime now;
  final Team? team;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final start = event.dateEvent;
    final soft = TextStyle(fontSize: 11, height: 1.45, color: colors.onNavy.withValues(alpha: .8));
    final current = team;

    return NavyGameCard(
      fill: NavyFill.navy,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                GameBadge(label: 'Următorul tău joc', fill: colors.tickOnNavy, text: colors.onTick),
                const SizedBox(height: 8),
                Text(
                  event.name ?? '',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.45, color: colors.onNavy),
                ),
                if (start != null) Text(heroDateLine(start, event.punctDeStart), style: soft),
                const SizedBox(height: 10),
                CountdownBoxes(left: left),
              ],
            ),
          ),
          if (current != null)
            ColoredBox(
              color: colors.onNavy.withValues(alpha: .06),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Pregătirea echipei ${current.name}', style: soft),
                    const SizedBox(height: 6),
                    CheckpointLine(
                      labels: preparationLabels,
                      done: preparationTrail(event, current, now).done,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
