import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

/// The profile row that opens the player's teams: an icon, "Echipele mele"
/// and an arrow.
class ProfileTeamsRow extends StatelessWidget {
  const ProfileTeamsRow({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: colors.iconButtonBg,
            child: Icon(
              TablerIcons.users_group,
              size: 18,
              color: colors.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Echipele mele',
              style: TextStyle(
                color: colors.text,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(TablerIcons.chevron_right, size: 18, color: colors.muted),
        ],
      ),
    );
  }
}
