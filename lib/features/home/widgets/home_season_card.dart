import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/features/teams/logic/season_rows.dart';
import 'package:teamxperience/model/season_standing.dart';
import 'package:teamxperience/ui/components/layout/outline_card.dart';
import 'package:teamxperience/ui/components/misc/section_header.dart';
import 'package:teamxperience/ui/ui.dart';

/// "Sezonul tău" on Home: the player's crew and its place this season.
class HomeSeasonCard extends StatelessWidget {
  const HomeSeasonCard({
    super.key,
    required this.seasonName,
    required this.place,
    required this.standing,
    required this.onOpen,
  });

  final String seasonName;
  final int place;
  final SeasonStanding standing;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionHeader(title: 'Sezonul tău', link: 'Clasament', onLink: onOpen, top: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onOpen,
            child: OutlineCard(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(color: colors.navActivePill, shape: BoxShape.circle),
                    child: SizedBox.square(
                      dimension: 40,
                      child: Center(
                        child: Text(
                          '$place',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, height: 1.45, color: colors.text),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          standing.crewName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14, height: 1.45, fontWeight: FontWeight.w500, color: colors.text),
                        ),
                        Text(
                          '$seasonName · ${standing.points} p · ${standing.games} ${gamesLabel(standing.games)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, height: 1.45, color: colors.muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(TablerIcons.chevron_right, size: 16, color: colors.muted),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
