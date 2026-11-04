import 'package:flutter/material.dart';
import 'package:teamxperience/model/team_member.dart';
import 'package:teamxperience/ui/components/misc/avatar_stack.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

/// "Componență echipă": the members as overlapping initials with their names
/// under them.
class TeamMembersRow extends StatelessWidget {
  const TeamMembersRow({super.key, required this.title, required this.members});

  final String title;
  final List<TeamMember> members;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final names = members.map((m) => m.displayName).join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: colors.text,
          ),
        ),
        const SizedBox(height: 10),
        AvatarStack(initials: members.map((m) => m.initials).toList()),
        if (names.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            names,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 13,
              color: colors.text,
            ),
          ),
        ],
      ],
    );
  }
}
