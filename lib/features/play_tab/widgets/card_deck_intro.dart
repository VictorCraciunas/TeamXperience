import 'dart:math';

import 'package:flutter/material.dart';

import 'card_back.dart';

/// "Draw a card" (mockup 10): three card backs fly up from the key into a
/// fan, shuffle, gather, and the middle one turns away; then [onDone].
class CardDeckIntro extends StatefulWidget {
  const CardDeckIntro({super.key, required this.height, required this.onDone});

  /// The real card's height, so the backs are the same size.
  final double height;
  final VoidCallback onDone;

  /// The whole run, in ms.
  static const int length = 1240;

  @override
  State<CardDeckIntro> createState() => _CardDeckIntroState();
}

typedef _Pose = ({double x, double y, double turn, double scale, double opacity});

class _CardDeckIntroState extends State<CardDeckIntro> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: CardDeckIntro.length),
  )
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onDone();
    })
    ..forward();

  static const _overshoot = Cubic(.3, 1.35, .5, 1);
  static const _Pose _start = (x: 0, y: 160, turn: 0, scale: .12, opacity: 0);
  static const List<_Pose> _fan = [
    (x: -54, y: 14, turn: -9, scale: 1, opacity: 1),
    (x: 0, y: 0, turn: 0, scale: 1, opacity: 1),
    (x: 54, y: 14, turn: 9, scale: 1, opacity: 1),
  ];
  static const List<_Pose> _swap = [
    (x: 54, y: 14, turn: 9, scale: 1, opacity: 1),
    (x: 0, y: -16, turn: 0, scale: 1.03, opacity: 1),
    (x: -54, y: 14, turn: -9, scale: 1, opacity: 1),
  ];
  static const List<_Pose> _gather = [
    (x: 0, y: 0, turn: 0, scale: 1, opacity: 1),
    (x: 0, y: -10, turn: 0, scale: 1.03, opacity: 1),
    (x: 0, y: 0, turn: 0, scale: 1, opacity: 1),
  ];

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  static double _seg(double ms, double from, double to, Curve curve) =>
      curve.transform(((ms - from) / (to - from)).clamp(0.0, 1.0));

  static _Pose _mix(_Pose a, _Pose b, double t) => (
        x: a.x + (b.x - a.x) * t,
        y: a.y + (b.y - a.y) * t,
        turn: a.turn + (b.turn - a.turn) * t,
        scale: a.scale + (b.scale - a.scale) * t,
        opacity: (a.opacity + (b.opacity - a.opacity) * t).clamp(0.0, 1.0),
      );

  _Pose _pose(int card, double ms) {
    var p = _mix(_start, _fan[card], _seg(ms, 0, 340, _overshoot));
    if (ms >= 420) p = _mix(_fan[card], _swap[card], _seg(ms, 420, 760, _overshoot));
    if (ms >= 760) p = _mix(_swap[card], _gather[card], _seg(ms, 760, 1060, _overshoot));
    return p;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final ms = _c.value * CardDeckIntro.length;
        final last = _seg(ms, 1060, 1240, Curves.easeIn);
        return SizedBox(
          height: widget.height,
          child: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [
              for (final card in [0, 2, 1])
                Builder(builder: (context) {
                  final p = _pose(card, ms);
                  final fade = card == 1 ? 1.0 : 1 - last;
                  final turnY = card == 1 ? last * pi / 2 : 0.0;
                  return Opacity(
                    opacity: (p.opacity * fade).clamp(0.0, 1.0),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, .001)
                        ..translateByDouble(p.x, p.y, 0, 1)
                        ..rotateZ(p.turn * pi / 180)
                        ..rotateY(turnY)
                        ..scaleByDouble(p.scale, p.scale, 1, 1),
                      child: const CardBack(),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}
