import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// A team's initial in a 44 px circle: navy while its card is open, soft
/// teal while closed.
class TeamAvatar extends StatelessWidget {
  const TeamAvatar({super.key, required this.initial, required this.open});

  final String initial;
  final bool open;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: open ? colors.navy : colors.iconButtonBg,
      ),
      child: Text(
        initial,
        textScaler: TextScaler.noScaling,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: open ? colors.onNavy : colors.accent,
        ),
      ),
    );
  }
}
