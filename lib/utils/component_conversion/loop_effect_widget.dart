import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:teamxperience/enums/loop_effect.dart';

/// How a component is drawn at one moment of a loop effect.
class LoopFrame {
  const LoopFrame({this.opacity = 1, this.dx = 0, this.dy = 0, this.scale = 1});

  final double opacity;
  final double dx;
  final double dy;
  final double scale;

  bool get isMoved => dx != 0 || dy != 0 || scale != 1;
}

/// A value that goes through [keys] (pairs of a place from 0 to 1 and a value),
/// in straight lines between them.
double _through(double at, List<(double, double)> keys) {
  for (var i = 1; i < keys.length; i++) {
    final (end, endValue) = keys[i];
    final (start, startValue) = keys[i - 1];
    if (at <= end) {
      final span = end - start;
      return span == 0 ? endValue : startValue + (endValue - startValue) * ((at - start) / span);
    }
  }
  return keys.last.$2;
}

/// The frame of [effect] at [round], where 0 is the start of a round and 1 its
/// end. Every effect is in place at the start and the end, so rounds follow
/// each other without a jump.
LoopFrame loopFrame(LoopEffect effect, double round) {
  final t = round - round.floorToDouble();
  final wave = 0.5 - 0.5 * math.cos(2 * math.pi * t);

  switch (effect) {
    case LoopEffect.pulse:
      return LoopFrame(scale: 1 + 0.07 * wave);
    case LoopEffect.float:
      return LoopFrame(dy: -7 * wave);
    case LoopEffect.shake:
      if (t >= 0.25) return const LoopFrame();
      return LoopFrame(
        dx: _through(t / 0.25, const [(0, 0), (0.2, -8), (0.4, 8), (0.6, -5), (0.8, 5), (1, 0)]),
      );
    case LoopEffect.flicker:
      return LoopFrame(opacity: _through(t, const [(0, 1), (0.3, 0.35), (0.45, 1), (0.7, 0.5), (1, 1)]));
    case LoopEffect.glitch:
      if (t >= 0.92 && t < 0.95) return const LoopFrame(dx: -4, dy: 1);
      if (t >= 0.95 && t < 0.98) return const LoopFrame(dx: 4, dy: -1);
      return const LoopFrame();
  }
}

/// Plays [effect] on [child] round after round. The movement is only drawn, the
/// layout never changes. With no effect, or when the phone has animations
/// switched off, the child stands still.
class LoopEffectWidget extends StatefulWidget {
  const LoopEffectWidget({super.key, required this.effect, required this.child});

  final LoopEffect? effect;
  final Widget child;

  @override
  State<LoopEffectWidget> createState() => _LoopEffectWidgetState();
}

class _LoopEffectWidgetState extends State<LoopEffectWidget> with TickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _create();
  }

  @override
  void didUpdateWidget(LoopEffectWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.effect != widget.effect) {
      _controller?.dispose();
      _controller = null;
      _create();
      _sync();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  bool get _animationsOff => MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  /// The controller is made here and started in [_sync], because the settings of
  /// the phone can only be read once the widget is in the tree.
  void _create() {
    final effect = widget.effect;
    if (effect != null) _controller = AnimationController(vsync: this, duration: effect.cycle);
  }

  /// Plays the effect, or stops it when the phone has animations switched off.
  void _sync() {
    final controller = _controller;
    if (controller == null) return;

    if (_animationsOff) {
      controller.stop();
    } else if (!controller.isAnimating) {
      controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effect = widget.effect;
    final controller = _controller;
    if (effect == null || controller == null || _animationsOff) return widget.child;

    return AnimatedBuilder(
      animation: controller,
      child: widget.child,
      builder: (context, child) {
        final frame = loopFrame(effect, controller.value);
        Widget result = child!;
        if (frame.isMoved) {
          result = Transform(
            alignment: Alignment.center,
            transform: Matrix4.translationValues(frame.dx, frame.dy, 0)..scaleByDouble(frame.scale, frame.scale, 1, 1),
            child: result,
          );
        }
        if (frame.opacity != 1) result = Opacity(opacity: frame.opacity, child: result);
        return result;
      },
    );
  }
}
