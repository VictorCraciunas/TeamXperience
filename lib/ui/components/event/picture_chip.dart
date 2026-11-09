import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';

/// A small dark pill on an event's picture ("3,2 km · 1 h 30").
class PictureChip extends StatelessWidget {
  const PictureChip({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.liveCard, borderRadius: BorderRadius.circular(99)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11, height: 1.45, color: colors.onNavy),
        ),
      ),
    );
  }
}
