import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/ui.dart';

/// One line of the breakdown: "5 ★", a bar as long as its share, the count.
class RatingBarRow extends StatelessWidget {
  const RatingBarRow({super.key, required this.stars, required this.count, required this.total});

  final int stars;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final share = total == 0 ? 0.0 : count / total;
    final label = TextStyle(fontSize: 12, height: 1.45, color: colors.muted);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 10),
            child: Text('$stars', style: label, textAlign: TextAlign.right, maxLines: 1, softWrap: false),
          ),
          const SizedBox(width: 2),
          Icon(TablerIcons.star_filled, size: 11, color: colors.amber),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: SizedBox(
                height: 6,
                child: Stack(
                  children: [
                    Positioned.fill(child: ColoredBox(color: colors.inset)),
                    FractionallySizedBox(
                      widthFactor: share,
                      heightFactor: 1,
                      child: ColoredBox(color: colors.amber),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 26),
            child: Text('$count', style: label, textAlign: TextAlign.right, maxLines: 1, softWrap: false),
          ),
        ],
      ),
    );
  }
}
