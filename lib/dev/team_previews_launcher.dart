import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';
import 'package:teamxperience/ui/ui.dart';

import 'join_team_preview.dart';
import 'register_team_preview.dart';
import 'teams_preview.dart';

/// The gallery buttons that open the register, join and Echipe screens.
class TeamPreviewsLauncher extends StatelessWidget {
  const TeamPreviewsLauncher({super.key});

  void _open(BuildContext context, Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.page,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppButton(
              label: 'Înscrierea echipei',
              onPressed: () => _open(context, const RegisterTeamPreview()),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: 'Intră într-o echipă',
              onPressed: () => _open(context, const JoinTeamPreview()),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: 'Echipe',
              onPressed: () => _open(context, const TeamsPreview()),
            ),
          ],
        ),
      ),
    );
  }
}
