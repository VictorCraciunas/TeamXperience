import 'package:flutter/material.dart';

import '../../../utils/calendar_helper.dart';
import '../../theme/theme_context.dart';
import 'period_selection.dart';

/// A scrolling calendar for picking a date range: round days, the two ends
/// filled, the days between tinted and today outlined. The selection is owned
/// by the caller.
class PeriodPicker extends StatelessWidget {
  const PeriodPicker({
    super.key,
    required this.selection,
    required this.onDayTap,
    required this.now,
    this.monthCount = 24,
    this.controller,
  });

  final PeriodSelection selection;
  final ValueChanged<DateTime> onDayTap;

  /// The first month shown and the day marked as today.
  final DateTime now;
  final int monthCount;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      itemCount: monthCount,
      itemBuilder: (context, index) {
        final month = DateTime(now.year, now.month + index, 1);
        return _Month(month: month, selection: selection, now: now, onDayTap: onDayTap);
      },
    );
  }
}

class _Month extends StatelessWidget {
  const _Month({
    required this.month,
    required this.selection,
    required this.now,
    required this.onDayTap,
  });

  final DateTime month;
  final PeriodSelection selection;
  final DateTime now;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    final leadingBlanks = DateTime(month.year, month.month, 1).weekday - 1;
    final today = DateTime(now.year, now.month, now.day);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 14, 4, 6),
          child: Text(
            '${CalendarHelper.romanianMonthsUpper[month.month]} ${month.year}',
            style: TextStyle(color: colors.text, fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 7,
          children: [
            for (final label in CalendarHelper.romanianDaysShort)
              Center(
                child: Text(
                  label,
                  style: TextStyle(color: colors.muted, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            for (var i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
            for (var day = 1; day <= lastDay; day++)
              _Day(
                date: DateTime(month.year, month.month, day),
                selection: selection,
                isToday: DateTime(month.year, month.month, day) == today,
                onTap: onDayTap,
              ),
          ],
        ),
      ],
    );
  }
}

class _Day extends StatelessWidget {
  const _Day({
    required this.date,
    required this.selection,
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;
  final PeriodSelection selection;
  final bool isToday;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isEdge = selection.isStart(date) || selection.isEnd(date);
    final inside = selection.isInside(date);

    return Padding(
      padding: const EdgeInsets.all(2),
      child: GestureDetector(
        key: ValueKey('period-day-${date.year}-${date.month}-${date.day}'),
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(date),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isEdge
                ? colors.tick
                : inside
                    ? colors.tick.withValues(alpha: 0.25)
                    : null,
            border: isToday && !isEdge && !inside ? Border.all(color: colors.tick) : null,
          ),
          child: Center(
            child: Text(
              '${date.day}',
              style: TextStyle(
                color: isEdge ? colors.onTick : colors.text,
                fontSize: 14,
                fontWeight: isEdge ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
