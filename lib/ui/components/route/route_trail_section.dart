import 'package:flutter/material.dart';

import 'waypoint_dot.dart';

/// One section of a [RouteTrail]: its content, with a waypoint beside the top.
class RouteTrailSection extends StatelessWidget {
  const RouteTrailSection({super.key, required this.child, this.kind = WaypointKind.stop});

  final Widget child;
  final WaypointKind kind;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(padding: const EdgeInsets.fromLTRB(40, 0, 14, 18), child: child),
        Positioned(left: 14, top: 0, child: WaypointDot(kind: kind)),
      ],
    );
  }
}
