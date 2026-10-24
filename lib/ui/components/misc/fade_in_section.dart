import 'package:flutter/material.dart';

/// Fades its child in while it drifts a few pixels down into place. Give
/// sections on a page increasing [order] values and they appear one after the
/// other from the top. It plays once, when the section first appears, and not
/// again when the parent rebuilds (give each section a stable key). With
/// reduced motion on, the child is simply shown. If the page is still sliding
/// in, it waits for that to finish first.
class FadeInSection extends StatefulWidget {
  const FadeInSection({
    super.key,
    required this.order,
    required this.child,
    this.step = const Duration(milliseconds: 110),
    this.duration = const Duration(milliseconds: 520),
    this.maxDelaySteps = 6,
    this.drift = 22,
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
  Animation<double>? _transition;

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
      return;
    }

    // Start only once the page has finished sliding in, otherwise most of the
    // fade happens before anyone can see it. The route reports its animation
    // as completed while the page is still being built, so look one frame later.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final transition = ModalRoute.of(context)?.animation;
      if (transition == null || transition.status == AnimationStatus.completed) {
        _controller.forward();
        return;
      }
      _transition = transition;
      transition.addStatusListener(_onTransitionStatus);
    });
  }

  void _onTransitionStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _transition?.removeStatusListener(_onTransitionStatus);
    _transition = null;
    if (mounted) _controller.forward();
  }

  @override
  void dispose() {
    _transition?.removeStatusListener(_onTransitionStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _progress,
      child: AnimatedBuilder(
        animation: _progress,
        // Its own layer, so the moving, fading section does not repaint its neighbours.
        child: RepaintBoundary(child: widget.child),
        builder: (context, child) => Transform.translate(
          offset: Offset(0, -widget.drift * (1 - _progress.value)),
          child: child,
        ),
      ),
    );
  }
}
