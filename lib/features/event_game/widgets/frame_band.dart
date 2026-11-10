import 'package:flutter/material.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

/// Puts the game frame's own pieces (header, attempts, bottom bar) on the
/// event's page colour at 85 % when the puzzle is drawn on a picture, so their
/// text is always on a colour the palette was checked against. The organiser's
/// content stays on the picture as built.
class FrameBand extends StatelessWidget {
  const FrameBand({super.key, required this.onPicture, required this.child});

  final bool onPicture;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!onPicture) return child;
    return ColoredBox(
      key: const ValueKey('frame-band'),
      color: context.eventPalette.background.withValues(alpha: .85),
      child: child,
    );
  }
}
