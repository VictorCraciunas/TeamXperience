import 'dart:async';

import 'package:flutter/widgets.dart';

/// While a game screen is open, marks the player as present as soon as it
/// can and then every [every], so the team can see who is here. A failed
/// write is ignored; the next tick tries again.
class KeepsPresence extends StatefulWidget {
  const KeepsPresence({
    super.key,
    required this.markPresent,
    required this.child,
    this.every = const Duration(seconds: 60),
    this.ready = true,
  });

  final Future<void> Function() markPresent;
  final Widget child;
  final Duration every;

  /// False while there is nothing to mark yet (the team is still being
  /// looked up); the first mark comes the moment it turns true.
  final bool ready;

  @override
  State<KeepsPresence> createState() => _KeepsPresenceState();
}

class _KeepsPresenceState extends State<KeepsPresence> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.ready) _start();
    });
  }

  @override
  void didUpdateWidget(KeepsPresence oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ready && _timer == null) _start();
  }

  void _start() {
    _mark();
    _timer = Timer.periodic(widget.every, (_) => _mark());
  }

  Future<void> _mark() async {
    try {
      await widget.markPresent();
    } catch (_) {
      // Offline or refused: the next tick tries again.
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
