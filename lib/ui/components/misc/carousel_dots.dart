import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';

/// A row of dots under a carousel: one per item, the current one larger and in
/// the accent colour.
class CarouselDots extends StatelessWidget {
  const CarouselDots({super.key, required this.count, required this.current});

  final int count;
  final int current;

  static const double _dot = 7;
  static const double _currentDot = 9;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: '${current + 1} din $count',
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            AnimatedContainer(
              key: i == current ? const ValueKey('dot-current') : null,
              duration: const Duration(milliseconds: 200),
              width: i == current ? _currentDot : _dot,
              height: i == current ? _currentDot : _dot,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == current ? colors.accent : colors.muted.withValues(alpha: .35),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
