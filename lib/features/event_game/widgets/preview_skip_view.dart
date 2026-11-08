import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/game/game_filled_button.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

/// In an organiser's walk-through, instead of a puzzle that needs being
/// somewhere or uploading something: what players do here, and a way on.
class PreviewSkipView extends StatelessWidget {
  const PreviewSkipView({super.key, required this.text, required this.onSkip});

  final String text;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, height: 1.45, color: palette.ink),
          ),
          const SizedBox(height: 12),
          GameFilledButton(label: 'Sari peste', onTap: onSkip),
        ],
      ),
    );
  }
}
