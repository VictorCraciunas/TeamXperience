import 'package:flutter/material.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

/// The page behind the route: the event's page colour, with the organiser's
/// puzzle picture under an 85 % veil of that colour when there is one, so text
/// always sits on a known colour.
class GameBackdrop extends StatelessWidget {
  const GameBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    final image = palette.backgroundImage;
    return ColoredBox(
      color: palette.background,
      child: Stack(
        children: [
          if (image != null) ...[
            Positioned.fill(
              child: Image(image: image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox()),
            ),
            Positioned.fill(child: ColoredBox(color: palette.background.withValues(alpha: .85))),
          ],
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}
