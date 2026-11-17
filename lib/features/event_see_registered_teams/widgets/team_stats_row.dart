import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

import '../logic/team_stats.dart';
import 'team_stat_tile.dart';

/// "12 echipe", "46 jucători", "2 incomplete" in three equal tiles; the last
/// one turns amber while some team waits for players.
class TeamStatsRow extends StatelessWidget {
  const TeamStatsRow({super.key, required this.stats});

  final TeamStats stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: TeamStatTile(value: stats.teams, label: 'echipe')),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: TeamStatTile(value: stats.players, label: 'jucători')),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: TeamStatTile(value: stats.incomplete, label: 'incomplete', warning: stats.incomplete > 0),
        ),
      ],
    );
  }
}
