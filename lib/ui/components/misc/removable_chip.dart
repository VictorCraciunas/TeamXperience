import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';

/// A small pill showing an active filter or search with a close icon.
class RemovableChip extends StatelessWidget {
  const RemovableChip({super.key, required this.label, required this.onRemove, this.icon});

  final String label;
  final VoidCallback onRemove;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final leading = icon;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.tick, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              Icon(leading, size: 14, color: colors.text),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: colors.text, fontSize: 12)),
            ),
            IconButton(
              onPressed: onRemove,
              tooltip: 'Elimină',
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.close, size: 16, color: colors.text),
            ),
          ],
        ),
      ),
    );
  }
}
