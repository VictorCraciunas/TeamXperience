import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// The organiser's round "TX": navy, the X in the brand yellow.
class OrganiserAvatar extends StatelessWidget {
  const OrganiserAvatar({super.key, this.size = 32, this.fontSize = 12});

  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: 'Organizator',
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: colors.navy, shape: BoxShape.circle),
        child: Text.rich(
          TextSpan(
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700, color: colors.onNavy, height: 1),
            children: [const TextSpan(text: 'T'), TextSpan(text: 'X', style: TextStyle(color: colors.brandX))],
          ),
          textScaler: TextScaler.noScaling,
        ),
      ),
    );
  }
}
