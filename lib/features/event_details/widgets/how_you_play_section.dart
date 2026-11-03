import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/utils/event_formats.dart';

import 'play_fact_card.dart';

/// "Cum jucați": team size and the live leaderboard, side by side.
class HowYouPlaySection extends StatelessWidget {
  const HowYouPlaySection({super.key, required this.teamSizeMin, required this.teamSizeMax});

  final int teamSizeMin;
  final int teamSizeMax;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: PlayFactCard(
              icon: TablerIcons.users_group,
              title: teamSizeLine(teamSizeMin, teamSizeMax),
              text: 'Fiecare pe telefonul lui, aceleași indicii.',
            ),
          ),
          const SizedBox(width: 6),
          const Expanded(
            child: PlayFactCard(
              icon: TablerIcons.trophy,
              title: 'Clasament live',
              text: 'Toate echipele, același traseu.',
            ),
          ),
        ],
      ),
    );
  }
}
