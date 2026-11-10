import 'package:flutter/material.dart';
import 'package:teamxperience/features/enter_code/logic/start_texts.dart';
import 'package:teamxperience/ui/components/misc/avatar_stack.dart';
import 'package:teamxperience/ui/ui.dart';

/// Who of the team is at the start, as mockup 05: "Echipa Vulpile", the
/// members here side by side with dashed places for the rest, and
/// "3 din 4 sunt aici".
class TeamHereCard extends StatelessWidget {
  const TeamHereCard({super.key, required this.teamName, required this.hereInitials, required this.size});

  final String teamName;
  final List<String> hereInitials;

  /// The team's size; places beyond the members here are dashed.
  final int size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final soft = TextStyle(fontSize: 13, height: 1.45, color: colors.onNavy.withValues(alpha: .8));
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.onNavy.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Echipa $teamName', style: soft),
            const SizedBox(height: 6),
            Row(
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: AvatarStack(initials: hereInitials, total: size, size: 30, onDark: true, gap: 6),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(hereLine(hereInitials.length, size), style: soft)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
