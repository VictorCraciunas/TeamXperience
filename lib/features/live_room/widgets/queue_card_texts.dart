import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// The two lines on a queue card; takes the room left in its row.
class QueueCardTexts extends StatelessWidget {
  const QueueCardTexts({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, height: 1.45, fontWeight: FontWeight.w500, color: colors.text),
          ),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, height: 1.45, color: colors.muted),
          ),
        ],
      ),
    );
  }
}
