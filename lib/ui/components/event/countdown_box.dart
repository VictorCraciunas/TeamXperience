import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';

/// One box of [CountdownBoxes]: a value over its unit, on a navy card.
class CountdownBox extends StatelessWidget {
  const CountdownBox({super.key, required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.onNavyFaint, borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              // The tick; none when the phone asks for reduced motion.
              duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween(begin: const Offset(0, .35), end: Offset.zero).animate(animation),
                  child: child,
                ),
              ),
              child: Text(
                '$value',
                key: ValueKey(value),
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, height: 1.45, color: colors.onNavy),
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, height: 1.45, color: colors.onNavy.withValues(alpha: .8)),
            ),
          ],
        ),
      ),
    );
  }
}
