import 'package:teamxperience/features/live_room/logic/live_texts.dart' show teamInitial;
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/ui.dart';

import '../logic/registered_teams_texts.dart';
import 'team_avatar.dart';
import 'team_card_details.dart';

/// A registered team: its initial, name and summary line, folding open on a
/// tap to its members, the captain's contact, "Sună", "Mesaj" and the bin.
class RegisteredTeamCard extends StatelessWidget {
  const RegisteredTeamCard({
    super.key,
    required this.team,
    required this.open,
    required this.onToggle,
    required this.onCall,
    required this.onMessage,
    required this.onRemove,
  });

  final Team team;
  final bool open;
  final VoidCallback onToggle;

  /// Null when the team has no phone number.
  final VoidCallback? onCall;
  final VoidCallback onMessage;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final summary = teamSummary(team, expanded: open);
    final radius = BorderRadius.circular(16);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.panel,
        borderRadius: radius,
        border: Border.all(color: open ? colors.tick : colors.border),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: onToggle,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      TeamAvatar(initial: teamInitial(team.name), open: open),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(team.name, style: AppTextStyles.title(context)),
                            Text(
                              summary.text,
                              style: AppTextStyles.caption(context).copyWith(
                                color: summary.warning ? colors.warning : colors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Icon(
                        open ? TablerIcons.chevron_up : TablerIcons.chevron_down,
                        size: 20,
                        color: colors.muted,
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: open
                    ? TeamCardDetails(team: team, onCall: onCall, onMessage: onMessage, onRemove: onRemove)
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
