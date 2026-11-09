import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

/// "Cum ți s-a părut?": five 22 px stars in the second accent, 10 apart;
/// filled up to [rating], with "Mulțumim!" once rated.
class RatingStars extends StatelessWidget {
  const RatingStars({super.key, this.rating, required this.onRate});

  final int? rating;
  final ValueChanged<int> onRate;

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    final given = rating ?? 0;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 1; i <= 5; i++) ...[
              if (i > 1) const SizedBox(width: 10),
              Semantics(
                button: true,
                label: '$i din 5',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onRate(i),
                  child: Icon(
                    i <= given ? TablerIcons.star_filled : TablerIcons.star,
                    size: 22,
                    color: palette.secondaryAccent,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (given > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('Mulțumim!', style: TextStyle(fontSize: 13, height: 1.45, color: palette.muted)),
          ),
      ],
    );
  }
}
