import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';

/// A stop on the route, or its finish.
enum WaypointKind { stop, finish }

/// The dot that marks a stop on a route line: a navy ring for a stop, a
/// filled teal dot for the finish. 16 px across (a 10 px fill in a 3 px ring),
/// on a route and before a heading.
class WaypointDot extends StatelessWidget {
  const WaypointDot({super.key, this.kind = WaypointKind.stop, this.size = 16});

  final WaypointKind kind;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final finish = kind == WaypointKind.finish;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: finish ? colors.tick : colors.panel,
        border: Border.all(color: finish ? colors.tick : colors.navy, width: 3),
      ),
    );
  }
}
