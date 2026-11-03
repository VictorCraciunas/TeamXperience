import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';

/// A stop on the route, or its finish.
enum WaypointKind { stop, finish }

/// The 16 px dot that marks a stop on a route line: a navy ring for a stop,
/// a filled teal dot for the finish.
class WaypointDot extends StatelessWidget {
  const WaypointDot({super.key, this.kind = WaypointKind.stop});

  final WaypointKind kind;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final finish = kind == WaypointKind.finish;
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: finish ? colors.tick : colors.panel,
        border: Border.all(color: finish ? colors.tick : colors.navy, width: 3),
      ),
    );
  }
}
