import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// Which dark fill a Home game card uses.
enum NavyFill {
  /// Navy, before a game (mockup 02's next-game card).
  navy,

  /// The darker live colour, during a game.
  live,
}

/// The dark card at the top of Home: radius 22, navy or the live colour,
/// clipped, tappable when [onTap] is set.
class NavyGameCard extends StatelessWidget {
  const NavyGameCard({super.key, required this.fill, required this.child, this.onTap});

  final NavyFill fill;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(22);
    final card = DecoratedBox(
      key: const ValueKey('game-card'),
      decoration: BoxDecoration(
        color: fill == NavyFill.live ? colors.liveCard : colors.navy,
        borderRadius: radius,
      ),
      child: ClipRRect(borderRadius: radius, child: child),
    );
    final tap = onTap;
    if (tap == null) return card;
    return GestureDetector(onTap: tap, behavior: HitTestBehavior.opaque, child: card);
  }
}
