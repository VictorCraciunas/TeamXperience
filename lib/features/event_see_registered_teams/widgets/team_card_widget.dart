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
    return Container(
      decoration: BoxDecoration(
        color: context.colors.panel,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
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
                backgroundColor: context.colors.accent,
                child: Text(
                  team.name.isNotEmpty ? team.name[0].toUpperCase() : 'T',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  team.name,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: context.colors.text,
                  ),
                ),
              ),
              InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, color: Colors.red, size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InfoRowWidget(icon: Icons.person_outline, label: "Căpitan", value: team.captainName),
          const SizedBox(height: 6),
          InfoRowWidget(icon: Icons.email_outlined, label: "Email", value: team.captainEmail),
          const SizedBox(height: 6),
          InfoRowWidget(icon: Icons.phone_outlined, label: "Telefon", value: team.phoneNumber),
          const SizedBox(height: 6),
          InfoRowWidget(icon: Icons.group_outlined, label: "Componență", value: team.teamMembers),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              "${team.numberOfMembers} membri",
              style: TextStyle(
                fontSize: 12,
                color: context.colors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
