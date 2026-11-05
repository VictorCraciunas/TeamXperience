import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';

/// One team on a leaderboard.
class LeaderboardRow {
  const LeaderboardRow({required this.place, required this.name, required this.score, this.own = false});

  final int place;

  /// As shown, e.g. "Vulpile · voi" for the player's team.
  final String name;
  final String score;

  /// The player's own team, highlighted.
  final bool own;
}

/// A [LeaderboardRow] drawn as in mockup 02: place, name, score, padding
/// 8/12, the own row filled with the active pill colour.
class LeaderboardRowView extends StatelessWidget {
  const LeaderboardRowView({super.key, required this.row, required this.divider});

  final LeaderboardRow row;

  /// A 1 px line under the row (every row but the last).
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const base = TextStyle(fontSize: 12, height: 1.45);
    return Container(
      key: ValueKey('leader-row-${row.place}'),
      color: row.own ? colors.navActivePill : null,
      foregroundDecoration: divider
          ? BoxDecoration(border: Border(bottom: BorderSide(color: colors.insetBorder)))
          : null,
      padding: EdgeInsets.fromLTRB(12, 8, 12, divider ? 9 : 8),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            child: Text('${row.place}', style: base.copyWith(fontWeight: FontWeight.w500, color: colors.text)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              row.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: base.copyWith(color: colors.text, fontWeight: row.own ? FontWeight.w500 : FontWeight.w400),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            row.score,
            style: row.own
                ? base.copyWith(color: colors.accent, fontWeight: FontWeight.w500)
                : base.copyWith(color: colors.muted),
          ),
        ],
      ),
    );
  }
}
