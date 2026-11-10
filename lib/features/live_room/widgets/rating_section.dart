import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/components/layout/outline_card.dart';
import 'package:teamxperience/ui/components/misc/section_header.dart';
import 'package:teamxperience/ui/ui.dart';

import '../logic/live_texts.dart';
import '../logic/rating_summary.dart';
import 'rating_bar_row.dart';

/// "Părerea jucătorilor": the average of the stars given at the finish, and
/// how many gave each.
class RatingSection extends StatelessWidget {
  const RatingSection({super.key, required this.ratings});

  final RatingSummary ratings;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final average = ratings.average;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Părerea jucătorilor', top: 4),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: average == null
              ? Text('Nimeni nu a dat încă o notă.', style: TextStyle(fontSize: 14, height: 1.45, color: colors.muted))
              : OutlineCard(padding: const EdgeInsets.all(12), child: _body(context, average)),
        ),
      ],
    );
  }

  Widget _body(BuildContext context, double average) {
    final colors = context.colors;
    final summary = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Narrow and with large text the big number shrinks to fit.
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ratingAverageText(average),
                style: TextStyle(fontSize: 28, height: 1.2, fontWeight: FontWeight.w600, color: colors.text),
              ),
              const SizedBox(width: 4),
              Icon(TablerIcons.star_filled, size: 22, color: colors.amber),
            ],
          ),
        ),
        Text(ratingCountLine(ratings.count), style: TextStyle(fontSize: 13, height: 1.45, color: colors.muted)),
      ],
    );
    final breakdown = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var stars = 5; stars >= 1; stars--) RatingBarRow(stars: stars, count: ratings.of(stars), total: ratings.count),
      ],
    );
    // With very large text the breakdown goes under the average.
    if (MediaQuery.textScalerOf(context).scale(10) > 14) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [Align(alignment: Alignment.centerLeft, child: summary), const SizedBox(height: 10), breakdown],
      );
    }
    return Row(
      children: [
        Flexible(flex: 2, child: summary),
        const SizedBox(width: 16),
        Expanded(flex: 3, child: breakdown),
      ],
    );
  }
}
