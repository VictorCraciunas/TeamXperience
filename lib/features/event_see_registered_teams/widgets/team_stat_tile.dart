import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// One of the three numbers above the list. [warning] draws it in the
/// warning colour with an amber edge ("incomplete").
class TeamStatTile extends StatelessWidget {
  const TeamStatTile({super.key, required this.value, required this.label, this.warning = false});

  final int value;
  final String label;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.panel,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: warning ? colors.amber : colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$value',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: warning ? colors.warning : colors.text,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: colors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
