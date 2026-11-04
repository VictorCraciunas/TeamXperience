import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../theme/app_colors.dart';
import '../../theme/theme_context.dart';
import 'dashed_border.dart';

/// Overlapping initials circles for the members of a team, as in mockup 04:
/// filled members cycle through navy, amber, accent and tick (on a navy card:
/// teal, amber, white and pale teal), and the places still open up to [total] are dashed empty circles.
class AvatarStack extends StatelessWidget {
  const AvatarStack({
    super.key,
    required this.initials,
    this.total,
    this.size = 30,
    this.onDark = false,
    this.highlightNext = false,
  });

  final List<String> initials;

  /// The number of places; those beyond [initials] are drawn empty.
  final int? total;
  final double size;

  /// For use on a navy card: the ring is navy, empty places light up in
  /// `onNavyMuted` and the circles overlap by 6 instead of 8.
  final bool onDark;

  /// Marks the first empty place with a plus: the player who is joining.
  final bool highlightNext;

  static const double _ring = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final places = total ?? initials.length;
    final count = places > initials.length ? places : initials.length;
    if (count == 0) return const SizedBox.shrink();

    final step = size - (onDark ? 6 : 8);
    final ring = onDark ? colors.navy : colors.panel;
    final cycle = _cycle(colors);

    return SizedBox(
      width: size + step * (count - 1),
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < count; i++)
            Positioned(
              left: step * i,
              child:
                  i < initials.length
                      ? _Circle(
                        size: size,
                        ring: ring,
                        fill: cycle[i % cycle.length].fill,
                        textColor: cycle[i % cycle.length].text,
                        label: initials[i],
                      )
                      : _EmptyPlace(
                        size: size,
                        next: highlightNext && i == initials.length,
                        outline: onDark ? colors.onNavyMuted : colors.border,
                      ),
            ),
        ],
      ),
    );
  }

  List<({Color fill, Color text})> _cycle(AppColors colors) {
    if (onDark) {
      // Navy circles would vanish into the navy ring. As in mockup 03 these
      // are teal, amber, white and pale teal in light; built from `onNavy`
      // so they stay light, and `onTick` stays readable on them, in dark.
      return [
        (fill: colors.tickOnNavy, text: colors.onTick),
        (fill: colors.soon, text: colors.onTick),
        (fill: colors.onNavy, text: colors.onTick),
        (
          fill: Color.alphaBlend(
            colors.tickOnNavy.withValues(alpha: 0.2),
            colors.onNavy,
          ),
          text: colors.onTick,
        ),
      ];
    }
    return [
      (fill: colors.navy, text: colors.onNavy),
      (fill: colors.soon, text: colors.onTick),
      (fill: colors.accent, text: colors.onNavy),
      (fill: colors.tick, text: colors.onTick),
    ];
  }
}

class _Circle extends StatelessWidget {
  const _Circle({
    required this.size,
    required this.ring,
    required this.fill,
    required this.textColor,
    required this.label,
  });

  final double size;
  final Color ring;
  final Color fill;
  final Color textColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(AvatarStack._ring),
      // The ring is drawn inside the box, so the circle is [size] across,
      // ring included.
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: Border.all(color: ring, width: AvatarStack._ring),
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

class _EmptyPlace extends StatelessWidget {
  const _EmptyPlace({required this.size, required this.next, required this.outline});

  final double size;
  final bool next;
  final Color outline;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DashedBorder(
      circle: true,
      width: AvatarStack._ring,
      color: next ? colors.tick : outline,
      fill: next ? colors.panel : null,
      child: SizedBox(
        width: size,
        height: size,
        child: next ? Icon(TablerIcons.plus, size: 13, color: colors.accent) : null,
      ),
    );
  }
}
