import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// One line on a ticket's bottom: a teal icon, then the text.
class IconRow extends StatelessWidget {
  const IconRow({super.key, required this.icon, required this.text});

  final IconData icon;
  final InlineSpan text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.accent),
          const SizedBox(width: 10),
          Expanded(child: Text.rich(text, style: TextStyle(fontSize: 14, height: 1.45, color: colors.text))),
        ],
      ),
    );
  }
}
