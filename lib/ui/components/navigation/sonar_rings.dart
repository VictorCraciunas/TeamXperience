import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// One ring of [SonarRings] at [t] (0 → 1 through its 2 s): it leaves the
/// circle at 80 % and fades out at 1.7 times its size, easing out.
({double scale, double opacity}) sonarRing(double t) {
  final e = Curves.easeOut.transform(t.clamp(0.0, 1.0));
  return (scale: lerpDouble(1, 1.7, e) ?? 1, opacity: lerpDouble(.8, 0, e) ?? 0);
}

/// Where each of the two rings is at [t]: the second half a beat behind.
List<double> sonarPhases(double t) => [t, (t + .5) % 1];

/// Two rings that leave a round button one after the other, every 2 s, like
/// a sonar (mockup 11): the live Joacă key.
class SonarRings extends StatefulWidget {
  const SonarRings({super.key, required this.size, required this.color});

  /// The button's diameter; the rings start at its edge.
  final double size;
  final Color color;

  @override
  State<SonarRings> createState() => _SonarRingsState();
}

class _SonarRingsState extends State<SonarRings> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => Stack(
          clipBehavior: Clip.none,
          children: [
            for (final phase in sonarPhases(_c.value))
              Builder(builder: (context) {
                final ring = sonarRing(phase);
                return Opacity(
                  opacity: ring.opacity,
                  child: Transform.scale(
                    scale: ring.scale,
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: widget.color, width: 3),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
