import 'package:flutter/material.dart';

/// Fades its child in while it drifts a few pixels down into place. Give
/// sections on a page increasing [order] values and they appear one after the
/// other from the top. It plays once, when the section first appears, and not
/// again when the parent rebuilds (give each section a stable key). With
/// reduced motion on, the child is simply shown.
class FadeInSection extends StatefulWidget {
  const FadeInSection({
    super.key,
    required this.order,
    required this.child,
    this.step = const Duration(milliseconds: 90),
    this.duration = const Duration(milliseconds: 420),
    this.maxDelaySteps = 6,
    this.drift = 14,
  });

  /// Position on the page, 0 for the first section.
  final int order;
  final Widget child;

  /// Extra delay per [order] step.
  final Duration step;
  final Duration duration;

  /// Sections past this order all start together, so a long page does not wait.
  final int maxDelaySteps;

  /// How far above its final place the child starts, in logical pixels.
  final double drift;

  @override
  State<FadeInSection> createState() => _FadeInSectionState();
}

class _FadeInSectionState extends State<FadeInSection> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;
  bool _started = false;

  Duration get _delay => widget.step * widget.order.clamp(0, widget.maxDelaySteps);

  @override
  void initState() {
    super.initState();
    final total = _delay + widget.duration;
    _controller = AnimationController(vsync: this, duration: total);
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        _delay.inMicroseconds / total.inMicroseconds,
        1,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _progress,
      child: AnimatedBuilder(
        animation: _progress,
        child: widget.child,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, -widget.drift * (1 - _progress.value)),
          child: child,
        ),
      ),
    );
  }
}
