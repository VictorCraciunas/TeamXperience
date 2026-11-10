import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/game/game_filled_button.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

/// In an organiser's walk-through, instead of a puzzle that needs being
/// somewhere or uploading something: what players do here, and a way on.
class PreviewSkipView extends StatelessWidget {
  const PreviewSkipView({super.key, required this.text, required this.onSkip, this.header});

  final String text;
  final VoidCallback onSkip;

  /// The organiser's content above; it scrolls, so the button stays on the
  /// screen however long it is.
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    final top = header;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (top != null) top,
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, height: 1.45, color: palette.ink),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: GameFilledButton(label: 'Sari peste', onTap: onSkip),
        ),
      ],
    );
  }
}
