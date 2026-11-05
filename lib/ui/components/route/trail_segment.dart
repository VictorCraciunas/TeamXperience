import 'package:flutter/material.dart';

import 'dashed_line.dart';

/// The 2 px line between two stops of a small progress line: solid for the
/// part already walked, dashed for the rest. Put it in an [Expanded].
class TrailSegment extends StatelessWidget {
  const TrailSegment({super.key, required this.solid, required this.color});

  final bool solid;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2,
      child: solid ? ColoredBox(color: color) : DashedLine(color: color),
    );
  }
}
