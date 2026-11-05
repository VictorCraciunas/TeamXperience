import 'package:flutter/material.dart';
import 'package:teamxperience/features/home/logic/live_texts.dart';
import 'package:teamxperience/service/leaderboard.dart';
import 'package:teamxperience/ui/components/misc/section_header.dart';
import 'package:teamxperience/ui/components/team/leaderboard_card.dart';

import 'package:teamxperience/features/home/logic/leaderboard_rows.dart';

/// "Clasament live" on Home during a game (mockup 02): three rows around the
/// player's team and "Tot" for every team. Nothing while the player's team
/// is not among the streamed teams.
class LiveLeaderboardSection extends StatelessWidget {
  const LiveLeaderboardSection({
    super.key,
    required this.ranked,
    required this.ownName,
    required this.missionCount,
    required this.onAll,
  });

  final List<RankedTeam> ranked;
  final String ownName;
  final int missionCount;
  final VoidCallback onAll;

  @override
  Widget build(BuildContext context) {
    if (!ranked.any((r) => r.team.name == ownName)) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionHeader(title: 'Clasament live', link: 'Tot', onLink: onAll, top: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: LeaderboardCard(
            rows: leaderboardRows(
              leaderboardPreview(ranked, ownName),
              ownName: ownName,
              missionCount: missionCount,
            ),
          ),
        ),
      ],
    );
  }
}
