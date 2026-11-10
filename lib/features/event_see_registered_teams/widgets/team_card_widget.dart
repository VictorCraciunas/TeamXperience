import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/model/team.dart';

import 'info_row_widget.dart';

class TeamCardWidget extends StatelessWidget {
  final Team team;
  final VoidCallback? onDelete;

  const TeamCardWidget({super.key, required this.team, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final members = team.memberList.map((m) => m.displayName).join(', ');

    return Container(
      decoration: BoxDecoration(
        color: context.colors.panel,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.colors.liveCard.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: context.colors.tick,
                child: Text(
                  team.name.isNotEmpty ? team.name[0].toUpperCase() : 'T',
                  style: TextStyle(
                    color: context.colors.onTick,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  team.name,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: context.colors.text,
                  ),
                ),
              ),
              InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    color: context.colors.danger,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InfoRowWidget(
            icon: Icons.person_outline,
            label: "Căpitan",
            value: team.captainName,
          ),
          const SizedBox(height: 6),
          InfoRowWidget(
            icon: Icons.email_outlined,
            label: "Email",
            value: team.captainEmail,
          ),
          const SizedBox(height: 6),
          InfoRowWidget(
            icon: Icons.phone_outlined,
            label: "Telefon",
            value: team.phoneNumber,
          ),
          const SizedBox(height: 6),
          InfoRowWidget(
            icon: Icons.group_outlined,
            label: "Componență",
            value: members,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              "${team.userIds.length} din ${team.numberOfMembers}",
              style: TextStyle(fontSize: 14, color: context.colors.muted),
            ),
          ),
        ],
      ),
    );
  }
}
