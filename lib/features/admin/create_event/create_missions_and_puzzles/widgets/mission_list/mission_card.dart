import 'package:flutter/material.dart';
import 'package:teamxperience/ui/theme/app_radius.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

/// One mission in the list: its number, how many puzzles it has and whether it
/// is ready. [status] is the first thing still missing, or that it is done.
class MissionCard extends StatelessWidget {
  const MissionCard({
    super.key,
    required this.index,
    required this.puzzleCount,
    required this.status,
    required this.done,
    required this.onTap,
    required this.onDelete,
  });

  final int index;
  final int puzzleCount;
  final String status;
  final bool done;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final puzzles = puzzleCount == 1 ? '1 puzzle' : '$puzzleCount puzzle-uri';

    return Material(
      color: colors.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: colors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
          child: Row(
            children: [
              _NumberBadge(number: index + 1, done: done),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Misiunea ${index + 1}',
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$puzzles · $status',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: done ? colors.success : colors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                key: const ValueKey('delete-mission'),
                width: 44,
                height: 44,
                child: IconButton(
                  tooltip: 'Șterge misiunea',
                  icon: Icon(Icons.delete_outline, color: colors.muted, size: 20),
                  onPressed: onDelete,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  const _NumberBadge({required this.number, required this.done});

  final int number;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? colors.tick : colors.inset,
        border: done ? null : Border.all(color: colors.border),
      ),
      child:
          done
              ? Icon(Icons.check, size: 18, color: colors.onTick)
              : Text(
                '$number',
                style: TextStyle(
                  color: colors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
    );
  }
}
