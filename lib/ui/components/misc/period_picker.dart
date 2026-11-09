import 'package:flutter/material.dart';

import '../../../utils/calendar_helper.dart';
import '../../theme/theme_context.dart';
import 'period_selection.dart';

/// A month calendar for picking a date range. One month is shown at a time and
/// you move between months with the arrows or by swiping sideways. Days are
/// round: the two ends are filled, the days between are tinted and today is
/// outlined. The selection is owned by the caller.
class PeriodPicker extends StatefulWidget {
  const PeriodPicker({
    super.key,
    required this.selection,
    required this.onDayTap,
    required this.now,
    this.monthCount = 24,
  });

  final PeriodSelection selection;
  final ValueChanged<DateTime> onDayTap;

  /// The first month available and the day marked as today.
  final DateTime now;
  final int monthCount;

  @override
  State<PeriodPicker> createState() => _PeriodPickerState();
}

class _PeriodPickerState extends State<PeriodPicker> {
  late final PageController _pages;
  late int _page;

  DateTime _month(int index) =>
      DateTime(widget.now.year, widget.now.month + index, 1);

  /// The page of the month that holds [date], clamped to the available months.
  int _pageOf(DateTime date) {
    final index =
        (date.year - widget.now.year) * 12 + date.month - widget.now.month;
    return index.clamp(0, widget.monthCount - 1);
  }

  @override
  void initState() {
    super.initState();
    final start = widget.selection.start;
    _page = start == null ? 0 : _pageOf(start);
    _pages = PageController(initialPage: _page);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _go(int page) {
    if (page < 0 || page >= widget.monthCount) return;
    _pages.animateToPage(
      page,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final month = _month(_page);

    return LayoutBuilder(
      builder: (context, constraints) {
        // A weekday row plus up to six weeks of square cells.
        final cell = constraints.maxWidth / 7;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: _page > 0 ? () => _go(_page - 1) : null,
                  tooltip: 'Luna anterioară',
                  icon: Icon(Icons.chevron_left, color: colors.text),
                ),
                Expanded(
                  child: Text(
                    '${CalendarHelper.romanianMonthsUpper[month.month]} ${month.year}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed:
                      _page < widget.monthCount - 1
                          ? () => _go(_page + 1)
                          : null,
                  tooltip: 'Luna următoare',
                  icon: Icon(Icons.chevron_right, color: colors.text),
                ),
              ],
            ),
            SizedBox(
              height: cell * 7,
              child: PageView.builder(
                controller: _pages,
                itemCount: widget.monthCount,
                onPageChanged: (page) => setState(() => _page = page),
                itemBuilder:
                    (context, index) => _MonthGrid(
                      month: _month(index),
                      selection: widget.selection,
                      now: widget.now,
                      onDayTap: widget.onDayTap,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
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

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      children: [
        for (final label in CalendarHelper.romanianDaysShort)
          Center(
            child: Text(
              label,
              style: TextStyle(
                color: colors.muted,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
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
            color:
                isEdge
                    ? colors.tick
                    : inside
                    ? colors.tick.withValues(alpha: 0.25)
                    : null,
            border:
                isToday && !isEdge && !inside
                    ? Border.all(color: colors.tick)
                    : null,
          ),
          child: Center(
            child: Text(
              '${date.day}',
              style: TextStyle(
                color: isEdge ? colors.onTick : colors.text,
                fontSize: 16,
                fontWeight: isEdge ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
