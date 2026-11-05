import 'package:flutter/material.dart';

/// A round stop on a small progress line: a [size] circle, filled with
/// [fill] or drawn as a 2 px [ring] inside that size, with an optional
/// centred [child] (a check, a number).
class TrailDot extends StatelessWidget {
  const TrailDot({super.key, required this.size, this.fill, this.ring, this.child});

  final double size;
  final Color? fill;
  final Color? ring;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final edge = ring;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fill,
        border: edge == null ? null : Border.all(color: edge, width: 2),
      ),
      child: child,
    );
  }
}
