import 'package:flutter/animation.dart';
import 'package:teamxperience/enums/screen_animation.dart';

/// How a component is drawn at one moment of its entrance: how visible, how far
/// it is moved from its place, and how big.
class EntranceFrame {
  const EntranceFrame({this.opacity = 1, this.dx = 0, this.dy = 0, this.scale = 1});

  final double opacity;
  final double dx;
  final double dy;
  final double scale;

  bool get isMoved => dx != 0 || dy != 0 || scale != 1;
}

/// How far a slide starts from its place.
const double _slideDistance = 50;

/// How far a bounce starts below its place.
const double _bounceDistance = 60;

/// The frame of [mode] when the component's own progress is [progress]
/// (0 = not started, 1 = in place). At 1 every kind is in place, fully visible
/// and at full size.
EntranceFrame entranceFrame(ScreenAnimation mode, double progress) {
  final p = progress.clamp(0.0, 1.0);
  final left = 1 - p;

  return switch (mode) {
    ScreenAnimation.none => const EntranceFrame(),
    ScreenAnimation.fade => EntranceFrame(opacity: p),
    ScreenAnimation.slideFromLeft => EntranceFrame(opacity: p, dx: -_slideDistance * left),
    ScreenAnimation.slideFromRight => EntranceFrame(opacity: p, dx: _slideDistance * left),
    ScreenAnimation.slideFromBottom => EntranceFrame(opacity: p, dy: _slideDistance * left),
    ScreenAnimation.slideFromTop => EntranceFrame(opacity: p, dy: -_slideDistance * left),
    ScreenAnimation.zoom => EntranceFrame(opacity: p, scale: 0.5 + 0.5 * p),
    ScreenAnimation.bounce => EntranceFrame(
      opacity: p,
      dy: _bounceDistance * (1 - Curves.easeOutBack.transform(p)),
    ),
  };
}

/// When each component of a puzzle plays its entrance. Left alone it is what the
/// game always did: 2 seconds for all of them, one window each. With a duration
/// and a delay each component starts [delayMs] after the one before and lasts
/// [durationMs].
class EntranceTiming {
  const EntranceTiming({this.durationMs, this.delayMs});

  /// How long one component takes; null means automatic.
  final int? durationMs;

  /// How long after the one before the next component starts; null means automatic.
  final int? delayMs;

  static const _automaticTotalMs = 2000;
  static const _usualDurationMs = 600;
  static const _usualDelayMs = 250;

  bool get isAutomatic => durationMs == null && delayMs == null;

  int get _duration => durationMs ?? _usualDurationMs;
  int get _delay => delayMs ?? _usualDelayMs;

  int _totalMs(int count) {
    if (isAutomatic) return _automaticTotalMs;
    final components = count < 1 ? 1 : count;
    final total = (components - 1) * _delay + _duration;
    return total < 1 ? 1 : total;
  }

  /// How long the whole entrance of [count] components lasts.
  Duration total(int count) => Duration(milliseconds: _totalMs(count));

  /// Where, from 0 to 1 of the whole entrance, component [index] starts.
  double start(int index, int count) {
    if (count < 1) return 0;
    if (isAutomatic) return index / count;
    return (index * _delay) / _totalMs(count);
  }

  /// Where, from 0 to 1 of the whole entrance, component [index] is in place.
  double end(int index, int count) {
    if (count < 1) return 1;
    if (isAutomatic) return (index + 1) / count;
    final value = (index * _delay + _duration) / _totalMs(count);
    return value > 1 ? 1 : value;
  }
}
