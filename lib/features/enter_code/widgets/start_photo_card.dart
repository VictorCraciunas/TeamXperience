import 'package:flutter/material.dart';
import 'package:teamxperience/features/team_photo/widgets/team_photo_prompt.dart';
import 'package:teamxperience/ui/ui.dart';

/// The optional team photo on the navy start-code screen, taken before the
/// clock runs.
class StartPhotoCard extends StatelessWidget {
  const StartPhotoCard({super.key, this.photoUrl, required this.busy, this.error, required this.onTake});

  final String? photoUrl;
  final bool busy;
  final String? error;
  final VoidCallback onTake;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TeamPhotoPrompt(
      photoUrl: photoUrl,
      title: 'Poza echipei',
      line: 'Opțional. O găsiți la Amintiri.',
      busy: busy,
      error: error,
      onTake: onTake,
      fill: colors.onNavy.withValues(alpha: .08),
      textColor: colors.onNavy,
      softColor: colors.onNavy.withValues(alpha: .8),
      errorColor: colors.dangerTextOnNavy,
      buttonFill: colors.tickOnNavy,
      buttonText: colors.onTick,
    );
  }
}
