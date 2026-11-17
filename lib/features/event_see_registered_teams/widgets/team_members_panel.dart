import 'package:flutter/material.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/ui.dart';

import '../logic/registered_teams_texts.dart';
import '../logic/team_members.dart';
import 'team_member_row.dart';

/// The inset box of an open team card: up to three members, captain first,
/// then "+ N jucători" with the captain's phone and email. Nothing when the
/// team has none of these.
class TeamMembersPanel extends StatelessWidget {
  const TeamMembersPanel({super.key, required this.team});

  final Team team;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final rows = orderedMembers(team).take(shownMembers).toList();
    final contact = contactLine(team);
    if (rows.isEmpty && contact == null) return const SizedBox.shrink();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.inset,
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, row) in rows.indexed) ...[
              if (i > 0) const SizedBox(height: AppSpacing.sm),
              TeamMemberRow(
                initials: memberInitials(row.member),
                name: row.member.displayName,
                isCaptain: row.isCaptain,
              ),
            ],
            if (contact != null) ...[
              if (rows.isNotEmpty) const SizedBox(height: AppSpacing.sm),
              SelectableText(contact, style: AppTextStyles.caption(context)),
            ],
          ],
        ),
      ),
    );
  }
}
