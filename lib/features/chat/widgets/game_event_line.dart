import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/ui.dart';

/// A solved mission between the messages, centred: a green tick and
/// "Au rezolvat misiunea 3 · 10:40".
class GameEventLine extends StatelessWidget {
  const GameEventLine({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(TablerIcons.check, size: 14, color: colors.success),
          const SizedBox(width: 6),
          Flexible(child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: colors.muted))),
        ],
      ),
    );
  }
}
