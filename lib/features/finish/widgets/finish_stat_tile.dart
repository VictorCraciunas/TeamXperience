import 'package:flutter/material.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

/// One figure of the finish recap ("2 / din 12 echipe"): the value at 20 w500
/// over its label, in a surface card.
class FinishStatTile extends StatelessWidget {
  const FinishStatTile({super.key, required this.value, required this.label, this.accent = false, this.mono = false});

  final String value;
  final String label;

  /// The value in the accent colour (the place).
  final bool accent;

  /// The value in the monospace font (the time).
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(color: palette.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        // The mockup's 8 / 0, plus the 1 px border drawn inside.
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
        child: Column(
          children: [
            Text(
              value,
              maxLines: 1,
              style: TextStyle(
                fontSize: 20,
                height: 1.45,
                fontWeight: FontWeight.w500,
                fontFamily: mono ? 'Monospace' : null,
                color: accent ? palette.accent : palette.ink,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, height: 1.45, color: palette.ink.withValues(alpha: .8)),
            ),
          ],
        ),
      ),
    );
  }
}
