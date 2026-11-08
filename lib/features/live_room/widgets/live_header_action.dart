import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// A round 32 px button in the live room's dark bar.
class LiveHeaderAction extends StatelessWidget {
  const LiveHeaderAction({super.key, required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(color: colors.onNavy.withValues(alpha: .12), shape: BoxShape.circle),
          child: SizedBox.square(dimension: 32, child: Icon(icon, size: 16, color: colors.onNavy)),
        ),
      ),
    );
  }
}
