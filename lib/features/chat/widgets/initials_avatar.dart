import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// A player's (or team's) round initials, teal on the light teal.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.initials, this.size = 32, this.fontSize = 12});

  final String initials;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: colors.navActivePill, shape: BoxShape.circle),
        child: Text(
          initials,
          maxLines: 1,
          textScaler: TextScaler.noScaling,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600, color: colors.accent, height: 1),
        ),
      ),
    );
  }
}
