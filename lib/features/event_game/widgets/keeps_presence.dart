import 'dart:async';

import 'package:flutter/widgets.dart';

/// While the game screen is open, marks the player as present after the
/// first frame and then every [every], so the live Home can show who is
/// playing. A failed write is ignored; the next tick tries again.
class KeepsPresence extends StatefulWidget {
  const KeepsPresence({
    super.key,
    required this.markPresent,
    required this.child,
    this.every = const Duration(seconds: 60),
  });

  final Future<void> Function() markPresent;
  final Widget child;
  final Duration every;

  @override
  State<KeepsPresence> createState() => _KeepsPresenceState();
}

class _KeepsPresenceState extends State<KeepsPresence> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mark();
      _timer = Timer.periodic(widget.every, (_) => _mark());
    });
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
