import 'package:flutter/material.dart';

/// Gives [child] all the width there is, so text inside it can really be
/// aligned to the left or the right. Where the width is not limited (inside a
/// horizontal scroll, for example) the child keeps its own width.
class FullWidth extends StatelessWidget {
  const FullWidth({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth) return child;
        return SizedBox(width: constraints.maxWidth, child: child);
      },
    );
  }
}
