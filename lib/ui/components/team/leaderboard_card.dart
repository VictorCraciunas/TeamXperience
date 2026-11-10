import 'package:flutter/material.dart';

import '../layout/outline_card.dart';
import 'leaderboard_row.dart';

export 'leaderboard_row.dart' show LeaderboardRow;

/// A leaderboard in a `.card` with no padding, as mockup 02's "Clasament
/// live": one row per team, 1 px lines between them.
class LeaderboardCard extends StatelessWidget {
  const LeaderboardCard({super.key, required this.rows});

  final List<LeaderboardRow> rows;

  @override
  Widget build(BuildContext context) {
    return OutlineCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < rows.length; i++) LeaderboardRowView(row: rows[i], divider: i < rows.length - 1),
        ],
      ),
    );
  }
}
