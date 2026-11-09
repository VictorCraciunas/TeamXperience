import 'package:flutter/material.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/puzzle_list/puzzle_type_info.dart';
import 'package:teamxperience/ui/theme/app_radius.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

/// One puzzle in a mission: its type, its number and what is still missing.
class PuzzleRow extends StatelessWidget {
  const PuzzleRow({
    super.key,
    required this.index,
    required this.type,
    required this.status,
    required this.done,
    required this.onTap,
    required this.onDelete,
  });

  final int index;
  final PuzzleType? type;
  final String status;
  final bool done;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final info = PuzzleTypeInfo.of(type);

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
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? colors.tick : colors.inset,
                  border: done ? null : Border.all(color: colors.border),
                ),
                child: Icon(
                  done ? Icons.check : info.icon,
                  size: 18,
                  color: done ? colors.onTick : colors.text,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Puzzle ${index + 1} · ${info.label}',
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      status,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: done ? colors.success : colors.muted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                key: const ValueKey('delete-puzzle'),
                width: 44,
                height: 44,
                child: IconButton(
                  tooltip: 'Șterge puzzle-ul',
                  icon: Icon(
                    Icons.delete_outline,
                    color: colors.muted,
                    size: 20,
                  ),
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
