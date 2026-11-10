import 'package:flutter/material.dart';

/// A number that rolls up into place when it changes, as the mockup's
/// countdown digits do.
class RollingNumber extends StatelessWidget {
  const RollingNumber({super.key, required this.value, required this.style});

  final String value;
  final TextStyle style;

  static const _overshoot = Cubic(.3, 1.4, .6, 1);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedSwitcher(
        duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 300),
        switchInCurve: _overshoot,
        // Only the new number shows; the old one does not fade out under it.
        layoutBuilder: (current, previous) => Stack(alignment: Alignment.center, children: [if (current != null) current]),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, .7), end: Offset.zero).animate(animation),
            child: child,
          ),
        ),
        child: Text(value, key: ValueKey(value), style: style),
      ),
    );
  }
}
