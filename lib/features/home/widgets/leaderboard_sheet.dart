import 'package:flutter/material.dart';
import 'package:teamxperience/service/leaderboard.dart';
import 'package:teamxperience/ui/components/team/leaderboard_card.dart';
import 'package:teamxperience/ui/ui.dart';

import 'package:teamxperience/features/home/logic/leaderboard_rows.dart';

/// Every team of the live game, opened from "Tot".
Future<void> showLeaderboardSheet(
  BuildContext context, {
  required List<RankedTeam> ranked,
  required String ownName,
  required int missionCount,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.page,
    builder: (_) => LeaderboardSheet(ranked: ranked, ownName: ownName, missionCount: missionCount),
  );
}

/// The whole leaderboard in a sheet: a title and one card with every team.
class LeaderboardSheet extends StatelessWidget {
  const LeaderboardSheet({super.key, required this.ranked, required this.ownName, required this.missionCount});

  final List<RankedTeam> ranked;
  final String ownName;
  final int missionCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Clasament live',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, height: 1.45, color: colors.text),
              ),
              const SizedBox(height: 10),
              LeaderboardCard(rows: leaderboardRows(ranked, ownName: ownName, missionCount: missionCount)),
            ],
          ),
        ),
      ),
    );
  }
}
