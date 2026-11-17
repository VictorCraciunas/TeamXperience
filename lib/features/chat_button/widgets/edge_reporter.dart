import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Calls [onPlaced] with its box after each frame in which it was laid out or
/// painted (so also when it only moved), once per frame.
class EdgeReporter extends SingleChildRenderObjectWidget {
  const EdgeReporter({super.key, required this.onPlaced, required super.child});

  final void Function(RenderBox box) onPlaced;

  @override
  RenderObject createRenderObject(BuildContext context) => RenderEdgeReporter(onPlaced);

  @override
  void updateRenderObject(BuildContext context, RenderEdgeReporter renderObject) {
    renderObject.onPlaced = onPlaced;
  }
}

class RenderEdgeReporter extends RenderProxyBox {
  RenderEdgeReporter(this.onPlaced);

  void Function(RenderBox box) onPlaced;
  bool _scheduled = false;

  void _schedule() {
    if (_scheduled) return;
    _scheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (attached && hasSize) onPlaced(this);
    });
  }

  @override
  void performLayout() {
    super.performLayout();
    _schedule();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    _schedule();
  }
}
