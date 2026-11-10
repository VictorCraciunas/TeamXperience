import 'package:flutter/material.dart';
import 'package:teamxperience/features/home/logic/home_texts.dart';
import 'package:teamxperience/features/teams/logic/season_rows.dart';
import 'package:teamxperience/ui/components/layout/mini_stat_card.dart';
import 'package:teamxperience/ui/ui.dart';

/// "Salut, Victor" and the player's games, distance and level (mockup 02).
class GreetingStats extends StatelessWidget {
  const GreetingStats({
    super.key,
    required this.firstName,
    required this.games,
    required this.distanceMeters,
    required this.xp,
  });

  final String firstName;
  final int games;
  final double distanceMeters;
  final int xp;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final level = levelFor(xp);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Salut, $firstName',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, height: 1.45, color: colors.text),
          ),
          const SizedBox(height: 8),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 10, child: MiniStatCard(value: '$games', label: gamesLabel(games))),
                const SizedBox(width: 6),
                Expanded(flex: 10, child: MiniStatCard(value: kmStat(distanceMeters), label: 'pe jos')),
                const SizedBox(width: 6),
                Expanded(flex: 13, child: MiniStatCard(value: level.name, progress: level.progress, accent: true)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
