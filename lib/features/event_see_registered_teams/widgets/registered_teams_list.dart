import 'package:flutter/material.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/ui.dart';

import '../event_registered_teams_controller.dart';
import 'registered_team_card.dart';
import 'team_search_field.dart';
import 'team_stats_row.dart';

/// The loaded page: the three stats, the search and the team cards, all in
/// one scroll so nothing is squeezed on a small phone or with large text.
class RegisteredTeamsList extends StatelessWidget {
  const RegisteredTeamsList({
    super.key,
    required this.controller,
    required this.searchController,
    required this.onCall,
    required this.onMessage,
    required this.onRemove,
  });

  final EventRegisteredTeamsController controller;
  final TextEditingController searchController;
  final ValueChanged<Team> onCall;
  final ValueChanged<Team> onMessage;
  final ValueChanged<Team> onRemove;

  @override
  Widget build(BuildContext context) {
    final teams = controller.visibleTeams;
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.md,
        AppSpacing.page,
        AppSpacing.lg + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        TeamStatsRow(stats: controller.stats),
        const SizedBox(height: AppSpacing.md),
        TeamSearchField(controller: searchController, onChanged: controller.setSearch),
        const SizedBox(height: AppSpacing.md),
        if (teams.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xl),
            child: Text(
              'Nicio echipă găsită.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMuted(context),
            ),
          ),
        for (final (i, team) in teams.indexed) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm),
          RegisteredTeamCard(
            key: ValueKey(team.name),
            team: team,
            open: controller.isExpanded(team),
            onToggle: () => controller.toggle(team),
            onCall: controller.canCall(team) ? () => onCall(team) : null,
            onMessage: () => onMessage(team),
            onRemove: () => onRemove(team),
          ),
        ],
      ],
    );
  }
}
