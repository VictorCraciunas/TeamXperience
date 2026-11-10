import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// The missions as segments: solved in teal, the current one blinking amber,
/// the rest faint (mockup 10).
class MissionBar extends StatefulWidget {
  const MissionBar({super.key, required this.total, required this.current});

  final int total;

  /// The 0-based mission being played.
  final int current;

  @override
  State<MissionBar> createState() => _MissionBarState();
}

class _MissionBarState extends State<MissionBar> with SingleTickerProviderStateMixin {
  late final AnimationController _blink = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _blink
        ..stop()
        ..value = 0;
    } else if (!_blink.isAnimating) {
      _blink.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        for (var i = 0; i < widget.total; i++) ...[
          if (i > 0) const SizedBox(width: 5),
          Expanded(
            child: i == widget.current
                ? FadeTransition(
                    opacity: Tween<double>(begin: 1, end: .45).animate(_blink),
                    child: _segment(colors.amber),
                  )
                : _segment(i < widget.current ? colors.tickOnNavy : colors.onNavy.withValues(alpha: .16)),
          ),
        ],
      ],
    );
  }

  Widget _segment(Color color) => Container(
        height: 8,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      );
}
