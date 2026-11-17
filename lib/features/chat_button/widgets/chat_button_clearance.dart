import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../controller/chat_button_spots.dart';
import 'chat_button_scope.dart';
import 'edge_reporter.dart';

enum _Mode { bar, above, hide }

/// Tells the floating chat button where this page's controls are, so it never
/// covers them. Wrap a page's bottom bar in [ChatButtonClearance.bar]; the
/// button then sits above the bar's top edge while the page is on top.
/// Outside the app's chat button layer it does nothing.
class ChatButtonClearance extends StatefulWidget {
  /// [child] is a bar along the bottom of the page.
  const ChatButtonClearance.bar({super.key, required this.child})
      : _mode = _Mode.bar,
        overlap = 0;

  /// The button sits above [child]'s bottom edge, lowered by [overlap] (the
  /// player shell's pages end where the raised Joacă circle starts, which is
  /// above the bar's top edge on the right).
  const ChatButtonClearance.above({super.key, required this.child, this.overlap = 0}) : _mode = _Mode.above;

  /// The button hides while [child] is shown (the Joacă pop-up).
  const ChatButtonClearance.hide({super.key, required this.child})
      : _mode = _Mode.hide,
        overlap = 0;

  final Widget child;
  final double overlap;
  final _Mode _mode;

  @override
  State<ChatButtonClearance> createState() => _ChatButtonClearanceState();
}

class _ChatButtonClearanceState extends State<ChatButtonClearance> {
  ChatButtonSpots? _spots;
  Route<dynamic>? _route;
  double _screenHeight = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final spots = ChatButtonScope.maybeOf(context);
    final route = ModalRoute.of(context);
    if (spots == _spots && route == _route) return;
    _forget();
    _spots = spots;
    _route = route;
    if (widget._mode == _Mode.hide) _later(() => _report(hide: true));
  }

  /// Spots are read by the layer above the navigator, which must not be
  /// marked to rebuild while the pages build or unmount.
  void _later(VoidCallback action) {
    SchedulerBinding.instance.addPostFrameCallback((_) => action());
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  void _report({double clearance = 0, bool hide = false}) {
    final spots = _spots;
    final route = _route;
    if (!mounted || spots == null || route == null) return;
    spots.report(route, this, clearance: clearance, hide: hide);
  }

  void _forget() {
    final spots = _spots;
    final route = _route;
    if (spots == null || route == null) return;
    _later(() => spots.remove(route, this));
  }

  void _placed(RenderBox box) {
    if (!mounted) return;
    final scaffold = Scaffold.maybeOf(context)?.context.findRenderObject();
    final reference = scaffold is RenderBox && scaffold.attached && scaffold.hasSize ? scaffold : null;
    final height = reference?.size.height ?? _screenHeight;
    final top = box.localToGlobal(Offset.zero, ancestor: reference).dy;
    final edge = widget._mode == _Mode.bar ? top : top + box.size.height;
    _report(clearance: math.max(0, height - edge - widget.overlap));
  }

  @override
  void dispose() {
    _forget();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _screenHeight = MediaQuery.sizeOf(context).height;
    if (widget._mode == _Mode.hide || _spots == null) return widget.child;
    return EdgeReporter(onPlaced: _placed, child: widget.child);
  }
}
