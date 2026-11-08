import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/ui.dart';

import '../logic/live_map_points.dart';
import '../logic/live_texts.dart';
import 'board_action_button.dart';
import 'team_pin.dart';

/// Opens the sheet of one team. The actions close it first.
Future<void> showTeamSheet(
  BuildContext context, {
  required Team team,
  required PinTone tone,
  required String status,
  required VoidCallback onCall,
  required VoidCallback onMessage,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.colors.panel,
    builder: (sheet) => TeamSheet(
      team: team,
      tone: tone,
      status: status,
      onCall: () {
        Navigator.pop(sheet);
        onCall();
      },
      onMessage: () {
        Navigator.pop(sheet);
        onMessage();
      },
    ),
  );
}

/// One team, from a pin or a board row: who leads it, how it stands, and the
/// ways to reach it.
class TeamSheet extends StatelessWidget {
  const TeamSheet({
    super.key,
    required this.team,
    required this.tone,
    required this.status,
    required this.onCall,
    required this.onMessage,
  });

  final Team team;
  final PinTone tone;
  final String status;
  final VoidCallback onCall;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final captain = team.captainName.trim();
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TeamPin(initial: teamInitial(team.name), tone: tone, size: 48),
            const SizedBox(height: 10),
            Text(
              team.name,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.45, fontWeight: FontWeight.w500, color: colors.text),
            ),
            Text(
              captain.isEmpty ? status : '$captain · $status',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, height: 1.45, color: colors.muted),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: BoardActionButton(
                    label: 'Sună căpitanul',
                    icon: TablerIcons.phone,
                    colour: colors.accent,
                    onTap: onCall,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: BoardActionButton(
                    label: 'Mesaj',
                    icon: TablerIcons.message_circle,
                    colour: colors.accent,
                    onTap: onMessage,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
