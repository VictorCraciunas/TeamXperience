import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// A round pin for one end of the route on the event page's map.
class RouteEndPin extends StatelessWidget {
  const RouteEndPin({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: context.colors.panel, width: 2),
      ),
    );
  }
}
