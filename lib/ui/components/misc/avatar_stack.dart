import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';

/// Overlapping initials circles for the members of a team: navy circles with
/// white initials, and a last pale "+N" circle when [total] is more than the
/// circles shown.
class AvatarStack extends StatelessWidget {
  const AvatarStack({super.key, required this.initials, this.total, this.size = 28});

  final List<String> initials;

  /// The number of members; the ones not in [initials] collapse into "+N".
  final int? total;
  final double size;

  static const double _overlap = 8;
  static const double _ring = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final all = total;
    final hidden = all == null ? 0 : all - initials.length;
    final count = initials.length + (hidden > 0 ? 1 : 0);
    if (count == 0) return const SizedBox.shrink();

    final step = size - _overlap;
    return SizedBox(
      width: size + step * (count - 1),
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < initials.length; i++)
            Positioned(
              left: step * i,
              child: _Circle(
                size: size,
                fill: colors.navy,
                textColor: colors.onNavy,
                label: initials[i],
              ),
            ),
          if (hidden > 0)
            Positioned(
              left: step * initials.length,
              child: _Circle(
                size: size,
                fill: colors.inset,
                textColor: colors.text,
                label: '+$hidden',
              ),
            ),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({
    required this.size,
    required this.fill,
    required this.textColor,
    required this.label,
  });

  final double size;
  final Color fill;
  final Color textColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(2),
      // The ring is drawn inside the box, so the circle is [size] across,
      // ring included.
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: Border.all(color: context.colors.panel, width: AvatarStack._ring),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          maxLines: 1,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textColor,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
