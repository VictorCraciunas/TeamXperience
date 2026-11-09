import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// One number on a crew's navy card (mockup 03): "3 jocuri".
class CrewStatTile extends StatelessWidget {
  const CrewStatTile({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.onNavy.withValues(alpha: .1), borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, height: 1.45, fontWeight: FontWeight.w500, color: colors.onNavy),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, height: 1.45, color: colors.onNavy.withValues(alpha: .8)),
            ),
          ],
        ),
      ),
    );
  }
}
