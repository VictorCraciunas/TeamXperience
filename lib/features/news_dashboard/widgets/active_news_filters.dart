import 'package:flutter/material.dart';
import 'package:teamxperience/features/news_dashboard/logic/news_filters.dart';
import 'package:teamxperience/ui/components/misc/removable_chip.dart';
import 'package:teamxperience/utils/calendar_helper.dart';

/// The filters from the sheet that are on (a category, a period), each with
/// an x to remove it. Nothing when none is on.
class ActiveNewsFilters extends StatelessWidget {
  const ActiveNewsFilters({
    super.key,
    required this.query,
    required this.onClearPeriod,
    this.onClearCategory,
  });

  final NewsQuery query;
  final VoidCallback onClearPeriod;

  /// Null hides the category (the player's chips show it already).
  final VoidCallback? onClearCategory;

  @override
  Widget build(BuildContext context) {
    final clearCategory = onClearCategory;
    final category = query.category;
    final start = query.start;
    final end = query.end;
    final showCategory = clearCategory != null && category != null && query.hasCategory;
    final showPeriod = start != null && end != null;
    if (!showCategory && !showPeriod) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (showCategory) RemovableChip(label: category, onRemove: clearCategory),
            if (showPeriod)
              RemovableChip(
                label: '${CalendarHelper.formatDate(start)} - ${CalendarHelper.formatDate(end)}',
                icon: Icons.calendar_today_outlined,
                onRemove: onClearPeriod,
              ),
          ],
        ),
      ),
    );
  }
}
