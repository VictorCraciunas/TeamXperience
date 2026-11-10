import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/layout/outline_card.dart';
import 'package:teamxperience/ui/ui.dart';

/// A small fact about a past game ("Locul 2", "în clasament").
class MemoryFactCard extends StatelessWidget {
  const MemoryFactCard({super.key, required this.value, required this.label, this.accent = false});

  final String value;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return OutlineCard(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.45, color: accent ? colors.accent : colors.text),
          ),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, height: 1.45, color: colors.muted)),
        ],
      ),
    );
  }
}
