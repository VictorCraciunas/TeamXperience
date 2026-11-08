import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/layout/outline_card.dart';
import 'package:teamxperience/ui/ui.dart';

/// One live count ("9 în joc"): tap to open the board.
class LiveCountCard extends StatelessWidget {
  const LiveCountCard({super.key, required this.value, required this.label, this.colour, this.onTap});

  final int value;
  final String label;

  /// The number's colour; the text colour by default.
  final Color? colour;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: OutlineCard(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$value',
              style: TextStyle(fontSize: 15, height: 1.45, fontWeight: FontWeight.w500, color: colour ?? colors.text),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, height: 1.45, color: colors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
