import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';

/// Difficulty as filled and empty dots ("●●○" for 2 of 3).
class DifficultyDots extends StatelessWidget {
  const DifficultyDots({super.key, required this.level, this.max = 3});

  final int level;
  final int max;

  @override
  Widget build(BuildContext context) {
    final filled = level.clamp(0, max);
    return Text(
      '●' * filled + '○' * (max - filled),
      style: TextStyle(fontSize: 13, letterSpacing: 2, color: context.colors.accent, height: 1.45),
    );
  }
}
