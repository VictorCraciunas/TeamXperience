import 'package:flutter/material.dart';
import 'package:teamxperience/features/finish/logic/finish_recap.dart';
import 'package:teamxperience/features/profile/logic/profile_texts.dart';
import 'package:teamxperience/model/user_stats.dart';
import 'package:teamxperience/ui/components/layout/outline_card.dart';
import 'package:teamxperience/ui/ui.dart';

/// Games, km, missions and podiums in four small cards (mockup 08): the value
/// at 15 w500 over an 11 px label, centred.
class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({super.key, required this.stats});

  final UserStats stats;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget tile(String value, String label) => Expanded(
          child: OutlineCard(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              children: [
                // Long numbers and labels shrink rather than break out of the card.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: TextStyle(fontSize: 15, height: 1.45, fontWeight: FontWeight.w500, color: colors.text),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(label, maxLines: 1, style: TextStyle(fontSize: 11, height: 1.45, color: colors.muted)),
                ),
              ],
            ),
          ),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          tile('${stats.games}', statLabel('games', stats.games)),
          const SizedBox(width: 6),
          tile(kmLabel(stats.distanceMeters), 'km'),
          const SizedBox(width: 6),
          tile('${stats.missions}', statLabel('missions', stats.missions)),
          const SizedBox(width: 6),
          tile('${stats.podiums}', statLabel('podiums', stats.podiums)),
        ],
      ),
    );
  }
}
