import 'package:flutter/material.dart';

/// A small dot that breathes, for what is happening now. It stands still when
/// the phone asks for reduced motion.
class PulseDot extends StatefulWidget {
  const PulseDot({super.key, required this.colour, this.size = 6});

  final Color colour;
  final double size;

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
    lowerBound: .35,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 1;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
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
      key: const ValueKey('pulse-dot'),
      opacity: _controller,
      child: DecoratedBox(
        decoration: BoxDecoration(color: widget.colour, shape: BoxShape.circle),
        child: SizedBox.square(dimension: widget.size),
      ),
    );
  }
}
