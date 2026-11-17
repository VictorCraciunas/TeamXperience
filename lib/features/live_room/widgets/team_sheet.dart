import 'package:flutter/material.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/ui.dart';

import '../logic/live_map_points.dart';
import '../logic/live_texts.dart';
import 'team_pin.dart';
import 'team_sheet_actions.dart';

/// Opens the sheet of one team. The actions close it first. [onMap] is null
/// for a team with no position yet, which greys "Hartă" out.
Future<void> showTeamSheet(
  BuildContext context, {
  required Team team,
  required PinTone tone,
  required String status,
  required VoidCallback onCall,
  required VoidCallback onMessage,
  required VoidCallback? onMap,
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
      onMap: onMap == null
          ? null
          : () {
              Navigator.pop(sheet);
              onMap();
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
    required this.onMap,
  });

  final Team team;
  final PinTone tone;
  final String status;
  final VoidCallback onCall;
  final VoidCallback onMessage;
  final VoidCallback? onMap;

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
              style: TextStyle(fontSize: 16, height: 1.45, fontWeight: FontWeight.w500, color: colors.text),
            ),
            Text(
              captain.isEmpty ? status : '$captain · $status',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, height: 1.45, color: colors.muted),
            ),
            const SizedBox(height: 14),
            TeamSheetActions(onCall: onCall, onMessage: onMessage, onMap: onMap),
          ],
        ),
      ),
    );
  }
}
