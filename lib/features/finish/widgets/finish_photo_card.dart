import 'package:flutter/material.dart';
import 'package:teamxperience/features/team_photo/widgets/team_photo_prompt.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

/// The optional final team photo on the finish screen, in the event's colours.
class FinishPhotoCard extends StatelessWidget {
  const FinishPhotoCard({super.key, this.photoUrl, required this.busy, this.error, required this.onTake});

  final String? photoUrl;
  final bool busy;
  final String? error;
  final VoidCallback onTake;

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    return TeamPhotoPrompt(
      photoUrl: photoUrl,
      title: photoUrl == null ? 'O poză de final?' : 'Poza de final',
      line: 'Opțional. Rămâne la Amintiri.',
      busy: busy,
      error: error,
      onTake: onTake,
      fill: palette.accent,
      textColor: palette.onAccent,
      softColor: palette.onAccent,
      errorColor: palette.onAccent,
      buttonFill: palette.onAccent,
      buttonText: palette.accent,
    );
  }
}
