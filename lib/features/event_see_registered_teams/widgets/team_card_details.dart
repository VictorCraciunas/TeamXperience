import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/ui.dart';

import 'remove_team_button.dart';
import 'team_contact_button.dart';
import 'team_members_panel.dart';

/// What an open team card adds: the members and contact box, then "Sună",
/// "Mesaj" and the bin.
class TeamCardDetails extends StatelessWidget {
  const TeamCardDetails({
    super.key,
    required this.team,
    required this.onCall,
    required this.onMessage,
    required this.onRemove,
  });

  final Team team;

  /// Null when the team has no phone number.
  final VoidCallback? onCall;
  final VoidCallback onMessage;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TeamMembersPanel(team: team),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: TeamContactButton(icon: TablerIcons.phone, label: 'Sună', onTap: onCall)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TeamContactButton(icon: TablerIcons.message_circle, label: 'Mesaj', onTap: onMessage),
              ),
              const SizedBox(width: AppSpacing.sm),
              RemoveTeamButton(onTap: onRemove),
            ],
          ),
        ],
      ),
    );
  }
}
