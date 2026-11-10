import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// One stat on the live ticket: "1 h 12 min" over "rămase".
class LiveStatBox extends StatelessWidget {
  const LiveStatBox({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.onNavyFaint, borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 16, height: 1.35, fontWeight: FontWeight.w600, color: colors.onNavy)),
            Text(label, style: TextStyle(fontSize: 12, height: 1.45, color: colors.onNavy.withValues(alpha: .75))),
          ],
        ),
      ),
    );
  }
}
