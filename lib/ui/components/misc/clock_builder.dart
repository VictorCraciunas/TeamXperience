import 'dart:async';

import 'package:flutter/widgets.dart';

/// Rebuilds [builder] every [interval] with the current time. Used for
/// countdowns and for things that change when a time threshold passes.
class ClockBuilder extends StatefulWidget {
  const ClockBuilder({
    super.key,
    required this.builder,
    this.interval = const Duration(seconds: 1),
    this.now,
  });

  final Widget Function(BuildContext context, DateTime now) builder;
  final Duration interval;

  /// Overrides the clock (for tests).
  final DateTime Function()? now;

  @override
  State<ClockBuilder> createState() => _ClockBuilderState();
}

class _ClockBuilderState extends State<ClockBuilder> {
  Timer? _timer;

  DateTime _now() => (widget.now ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.interval, (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _now());
}
