import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// A member of an open team card: initials in a small circle, the name, and
/// "căpitan" on the captain.
class TeamMemberRow extends StatelessWidget {
  const TeamMemberRow({super.key, required this.initials, required this.name, this.isCaptain = false});

  final String initials;
  final String name;
  final bool isCaptain;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(shape: BoxShape.circle, color: colors.navActivePill),
          child: Text(
            initials,
            textScaler: TextScaler.noScaling,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.accent),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, color: colors.text),
          ),
        ),
        if (isCaptain) ...[
          const SizedBox(width: AppSpacing.sm),
          Text(
            'căpitan',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colors.accent),
          ),
        ],
      ],
    );
  }
}
