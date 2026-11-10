import 'package:flutter/material.dart';

import '../../theme/event_theme_scope.dart';

/// The main button of a puzzle's bar (mockup 07: "Intră în cerc", "Fă altă
/// poză"): the accent fill, a w500 label in the colour that reads on it,
/// radius 12, padding 10, an optional 15 px icon. Without [onTap] it is the
/// ink at 12 % with muted text.
class GameFilledButton extends StatelessWidget {
  const GameFilledButton({super.key, required this.label, this.icon, this.onTap});

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    final enabled = onTap != null;
    final fg = enabled ? palette.onAccent : palette.muted;
    final glyph = icon;
    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        // A finger-sized tap area around what the mockup draws.
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: DecoratedBox(
            key: const ValueKey('game-filled-button'),
            decoration: BoxDecoration(
              color: enabled ? palette.accent : palette.ink.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              // The 10 px of the mockup plus the 1.5 px border of its neighbour,
              // so both buttons of a bar are the same height.
              padding: const EdgeInsets.all(11.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (glyph != null) ...[Icon(glyph, size: 15, color: fg), const SizedBox(width: 4)],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, height: 1.45, fontWeight: FontWeight.w500, color: fg),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
