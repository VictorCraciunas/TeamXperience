import 'package:flutter/material.dart';

import '../../theme/app_radius.dart';
import '../../theme/theme_context.dart';

/// The mockups' `.card`: a panel with a 1 px border and the card radius.
/// [padding] is the CSS padding; the border adds 1 px to it, as in CSS, and
/// children are clipped to the rounded corners.
class OutlineCard extends StatelessWidget {
  const OutlineCard({super.key, this.padding = EdgeInsets.zero, required this.child});

  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(AppRadius.card);
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.panel, border: Border.all(color: colors.border), borderRadius: radius),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card - 1),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
