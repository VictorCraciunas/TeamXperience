import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// A team's missions on the board (mockup 09 `.bar`): the solved ones in the
/// tick colour; the current one amber when the team needs a look.
class BoardSegments extends StatelessWidget {
  const BoardSegments({super.key, required this.total, required this.done, this.flagCurrent = false});

  final int total;
  final int done;
  final bool flagCurrent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          if (i > 0) const SizedBox(width: 2),
          Expanded(
            child: DecoratedBox(
              key: ValueKey('board-segment-$i'),
              decoration: BoxDecoration(
                color: i < done ? colors.tick : (flagCurrent && i == done ? colors.amber : colors.insetBorder),
                borderRadius: BorderRadius.circular(99),
              ),
              child: const SizedBox(height: 5),
            ),
          ),
        ],
      ],
    );
  }
}
