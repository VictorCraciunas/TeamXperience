import 'package:flutter/material.dart';

import '../../theme/event_theme_scope.dart';

/// A square button of the puzzle bar (the chat): 42 px, the accent fill,
/// radius 12, a 18 px icon in the colour that reads on the accent.
class GameIconButton extends StatelessWidget {
  const GameIconButton({super.key, required this.icon, required this.onTap, this.label});

  final IconData icon;
  final VoidCallback onTap;

  /// What a screen reader says ("Chat cu organizatorul").
  final String? label;

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          key: const ValueKey('game-icon-button'),
          decoration: BoxDecoration(color: palette.accent, borderRadius: BorderRadius.circular(12)),
          child: SizedBox.square(
            dimension: 42,
            child: Center(child: Icon(icon, size: 18, color: palette.onAccent)),
          ),
        ),
      ),
    );
  }
}
