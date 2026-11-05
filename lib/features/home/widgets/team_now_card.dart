import 'package:flutter/material.dart';
import 'package:teamxperience/features/home/logic/live_texts.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/components/layout/outline_card.dart';
import 'package:teamxperience/ui/components/misc/avatar_stack.dart';
import 'package:teamxperience/ui/components/misc/section_header.dart';
import 'package:teamxperience/ui/ui.dart';

/// "Echipa ta" on Home during a game (mockup 02): the members playing now,
/// how many, and when the last mission was solved.
class TeamNowCard extends StatelessWidget {
  const TeamNowCard({super.key, required this.team, required this.now});

  final Team team;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final active = activeMembers(team, now);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SectionHeader(title: 'Echipa ta', top: 16),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          child: OutlineCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                if (active.isNotEmpty) ...[
                  AvatarStack(initials: [for (final m in active) m.initials], size: 28),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        activeLine(active.length),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.45, color: colors.text),
                      ),
                      Text(
                        lastMissionLine(team.lastMissionAt, now),
                        style: TextStyle(fontSize: 11, height: 1.45, color: colors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
