import 'package:flutter/material.dart';

import 'dashed_line.dart';
import 'route_trail_section.dart';

/// Page sections strung on a vertical dashed route, each with its waypoint,
/// as on the event page.
class RouteTrail extends StatelessWidget {
  const RouteTrail({super.key, required this.sections});

  final List<RouteTrailSection> sections;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(left: 21, top: 0, bottom: 0, child: DashedLine(axis: Axis.vertical)),
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: sections),
      ],
    );
  }
}
