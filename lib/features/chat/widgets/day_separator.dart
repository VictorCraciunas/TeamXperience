import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// "Astăzi", "Ieri", "14 nov 2026", centred between the messages.
class DaySeparator extends StatelessWidget {
  final String label;

  const DaySeparator({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: colors.panel,
          border: Border.all(color: colors.insetBorder),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.muted)),
      ),
    );
  }
}
