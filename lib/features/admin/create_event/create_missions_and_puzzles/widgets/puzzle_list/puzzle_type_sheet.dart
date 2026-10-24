import 'package:flutter/material.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/puzzle_list/puzzle_type_info.dart';
import 'package:teamxperience/ui/theme/app_radius.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

/// "Ce fel de puzzle?": the choice shown when adding a puzzle. Resolves to the
/// chosen type, or null when closed without choosing.
Future<PuzzleType?> showPuzzleTypeSheet(BuildContext context) {
  return showModalBottomSheet<PuzzleType>(
    context: context,
    builder: (_) => const PuzzleTypeSheet(),
  );
}

class PuzzleTypeSheet extends StatelessWidget {
  const PuzzleTypeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ce fel de puzzle?',
              style: TextStyle(
                color: colors.text,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            for (final type in PuzzleTypeInfo.choices) ...[
              _Choice(type: type),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({required this.type});

  final PuzzleType type;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final info = PuzzleTypeInfo.of(type);

    return Material(
      color: colors.inset,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: colors.insetBorder),
      ),
      child: InkWell(
        key: ValueKey('choice-${type.name}'),
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () => Navigator.of(context).pop(type),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(info.icon, color: colors.text),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.label,
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      info.description,
                      style: TextStyle(color: colors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
