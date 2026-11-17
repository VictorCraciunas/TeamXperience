import 'package:flutter/material.dart';
import 'package:teamxperience/ui/theme/app_radius.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

/// The red count on "Conversații": how many teams wrote and were not read.
class EventMenuBadge extends StatelessWidget {
  const EventMenuBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: '$count necitite',
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.live,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          count > 99 ? '99+' : '$count',
          style: TextStyle(color: colors.onNavy, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
