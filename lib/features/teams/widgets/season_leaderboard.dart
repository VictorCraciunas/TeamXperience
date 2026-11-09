import 'package:flutter/material.dart';
import 'package:teamxperience/model/season_standing.dart';
import 'package:teamxperience/ui/components/misc/section_header.dart';
import 'package:teamxperience/ui/components/team/leaderboard_card.dart';
import 'package:teamxperience/ui/ui.dart';

import '../logic/season_rows.dart';

/// "Clasamentul sezonului" (mockup 03): the season's top crews.
class SeasonLeaderboard extends StatelessWidget {
  const SeasonLeaderboard({
    super.key,
    required this.seasonName,
    required this.standings,
    required this.myCrewIds,
  });

  final String seasonName;
  final List<SeasonStanding> standings;
  final Set<String> myCrewIds;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: 'Clasamentul sezonului', trailing: seasonName),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: standings.isEmpty
              ? Text(
                  'Clasamentul începe după primul joc.',
                  style: TextStyle(fontSize: 14, height: 1.45, color: context.colors.muted),
                )
              : LeaderboardCard(rows: seasonRows(standings, myCrewIds)),
        ),
      ],
    );
  }
}
