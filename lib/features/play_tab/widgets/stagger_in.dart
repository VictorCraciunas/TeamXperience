import 'package:flutter/material.dart';

/// A card row that fades in and rises 10 px, [index] × 55 ms after it is
/// built, when [play] is true (mockup 10). Shown as is otherwise.
class StaggerIn extends StatefulWidget {
  const StaggerIn({super.key, required this.index, required this.play, required this.child});

  final int index;
  final bool play;
  final Widget child;

  @override
  State<StaggerIn> createState() => _StaggerInState();
}

class _StaggerInState extends State<StaggerIn> with SingleTickerProviderStateMixin {
  late final int _delay = widget.index * 55;
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 380 + _delay),
    value: widget.play ? 0 : 1,
  );
  late final Animation<double> _t = CurvedAnimation(
    parent: _c,
    curve: Interval(_delay / (380 + _delay), 1, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    if (widget.play) _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _t,
        builder: (context, child) => Opacity(
          opacity: _t.value,
          child: Transform.translate(offset: Offset(0, 10 * (1 - _t.value)), child: child),
        ),
        child: widget.child,
      );
}
