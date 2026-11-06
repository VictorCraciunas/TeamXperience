import 'package:flutter/material.dart';

import '../../theme/event_theme_scope.dart';

/// The round buttons of a game header (mockup 06 `.rb`): a 32 px circle in
/// the event's ink at 10 % with a 16 px icon.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({super.key, required this.icon, required this.onTap, this.label});

  final IconData icon;
  final VoidCallback onTap;

  /// What a screen reader says ("Închide").
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
          key: const ValueKey('round-icon-button'),
          decoration: BoxDecoration(color: palette.ink.withValues(alpha: .1), shape: BoxShape.circle),
          child: SizedBox.square(
            dimension: 32,
            child: Center(child: Icon(icon, size: 16, color: palette.ink)),
          ),
        ),
      ),
    );
  }
}
