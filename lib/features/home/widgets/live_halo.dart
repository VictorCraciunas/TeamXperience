import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// The halo at [t] (0 → 1 through its 1.8 s): it leaves the pill at 90 %
/// and fades out 1.45 times as wide and 1.9 times as tall, easing out.
({double scaleX, double scaleY, double opacity}) liveHalo(double t) {
  final e = Curves.easeOut.transform(t.clamp(0.0, 1.0));
  return (
    scaleX: lerpDouble(1, 1.45, e) ?? 1,
    scaleY: lerpDouble(1, 1.9, e) ?? 1,
    opacity: lerpDouble(.9, 0, e) ?? 0,
  );
}

/// A soft wave that leaves the LIVE pill on Home's live card, every 1.8 s
/// (mockup 11). Still when the phone asks for less motion.
class LiveHalo extends StatefulWidget {
  const LiveHalo({super.key, required this.color, required this.child});

  final Color color;

  /// The pill.
  final Widget child;

  @override
  State<LiveHalo> createState() => _LiveHaloState();
}

class _LiveHaloState extends State<LiveHalo> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              key: const ValueKey('live-halo-ring'),
              animation: _c,
              builder: (context, _) {
                final h = liveHalo(_c.value);
                return Opacity(
                  opacity: h.opacity,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.diagonal3Values(h.scaleX, h.scaleY, 1),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: widget.color, width: 2),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}
