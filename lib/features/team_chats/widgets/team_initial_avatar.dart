import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// A team's first letter in a 44 circle: navy while its chat has something to
/// read, the soft teal otherwise.
class TeamInitialAvatar extends StatelessWidget {
  const TeamInitialAvatar({super.key, required this.name, required this.highlighted});

  final String name;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final trimmed = name.trim();
    final initial = trimmed.isEmpty ? 'E' : trimmed.characters.first.toUpperCase();
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: highlighted ? colors.navy : colors.iconButtonBg,
        shape: BoxShape.circle,
      ),
      child: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.3,
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: highlighted ? colors.onNavy : colors.accent,
          ),
        ),
      ),
    );
  }
}
