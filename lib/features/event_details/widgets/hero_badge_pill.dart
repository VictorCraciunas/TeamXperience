import 'package:flutter/material.dart';
import 'package:teamxperience/features/event_details/logic/hero_badge.dart';
import 'package:teamxperience/ui/ui.dart';

/// The pill above the event name: amber while sign-up is open or soon, red
/// when live, faint when closed.
class HeroBadgePill extends StatelessWidget {
  const HeroBadgePill({super.key, required this.badge});

  final HeroBadge badge;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (fill, ink) = switch (badge.kind) {
      HeroBadgeKind.open || HeroBadgeKind.soon => (colors.soon, colors.onTick),
      HeroBadgeKind.live => (colors.live, colors.onNavy),
      HeroBadgeKind.closed => (colors.onNavyFaint, colors.onNavy),
    };
    return DecoratedBox(
      decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
        child: Text(
          badge.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.45, color: ink),
        ),
      ),
    );
  }
}
