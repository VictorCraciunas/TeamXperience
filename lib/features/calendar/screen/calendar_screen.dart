import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teamxperience/widgets/my_appbar.dart';

import '../../../constants/colors.dart';
import '../../../utils/calendar_helper.dart';
import '../../../widgets/my_button.dart';

class DateRangeSelectionScreen extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const DateRangeSelectionScreen({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
  });

  @override
  State<DateRangeSelectionScreen> createState() =>
      _DateRangeSelectionScreenState();
}

class _DateRangeSelectionScreenState extends State<DateRangeSelectionScreen> {
  DateTime? startDate;
  DateTime? endDate;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    startDate = widget.initialStartDate;
    endDate = widget.initialEndDate;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<DateTime> generateMonths() {
    List<DateTime> months = [];
    DateTime current = DateTime.now();

    // Generate 24 months starting from current month
    for (int i = 0; i < 24; i++) {
      months.add(DateTime(current.year, current.month + i, 1));
    }

    return months;
  }

  void onDateTap(DateTime date) {
    setState(() {
      if (startDate == null) {
        // First selection - set start date
        startDate = date;
        endDate = null;
      } else if (endDate == null) {
        // Second selection - set end date
        if (date.isBefore(startDate!)) {
          // If selected date is before start date, make it the new start date
          endDate = startDate;
          startDate = date;
        } else {
          endDate = date;
        }
      } else {
        // Both dates are selected, start new selection
        startDate = date;
        endDate = null;
      }
    });
  }

  void clearSelection() {
    setState(() {
      startDate = null;
      endDate = null;
    });
  }

  bool isDateInRange(DateTime date) {
    if (startDate == null) return false;
    if (endDate == null) return date.isAtSameMomentAs(startDate!);

    return (date.isAtSameMomentAs(startDate!) ||
        date.isAtSameMomentAs(endDate!) ||
        (date.isAfter(startDate!) && date.isBefore(endDate!)));
  }

  bool isStartDate(DateTime date) {
    return startDate != null && date.isAtSameMomentAs(startDate!);
  }

  bool isEndDate(DateTime date) {
    return endDate != null && date.isAtSameMomentAs(endDate!);
  }

  Widget buildMonthCalendar(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;

    List<Widget> dayWidgets = [];

    // Add empty spaces for days before the first day of the month
    for (int i = 1; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 40, height: 40));
    }

    // Add days of the month
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(month.year, month.month, day);
      final isInRange = isDateInRange(date);
      final isStart = isStartDate(date);
      final isEnd = isEndDate(date);
      final isToday = date.isAtSameMomentAs(DateTime.now());

      dayWidgets.add(
        GestureDetector(
          onTap: () => onDateTap(date),
          child: Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color:
                  isStart || isEnd
                      ? const Color(0xFF4DD0E1)
                      : isInRange
                      ? const Color(0xFF4DD0E1).withOpacity(0.3)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border:
                  isToday && !isInRange
                      ? Border.all(color: const Color(0xFF4DD0E1), width: 1)
                      : null,
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      isStart || isEnd ? FontWeight.bold : FontWeight.normal,
                  color:
                      isStart || isEnd
                          ? Colors.white
                          : isInRange
                          ? const Color(0xFF4DD0E1)
                          : isToday
                          ? const Color(0xFF4DD0E1)
                          : Colors.black87,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Text(
            '${CalendarHelper.romanianMonthsUpper[month.month]} ${month.year}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 7,
            children: [
              // Day headers using CalendarHelper
              ...CalendarHelper.romanianDaysShort.map(
                (day) => Center(
                  child: Text(
                    day,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              // Day widgets
              ...dayWidgets,
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  String getSelectedPeriodText() {
    if (startDate == null) return 'Selectează perioada';
    if (endDate == null) return 'Selectează data de sfârșit';

    // Use CalendarHelper for consistent formatting
    return '${CalendarHelper.formatDate(startDate)} - ${CalendarHelper.formatDate(endDate)}';
  }

  bool canSave() {
    return startDate != null && endDate != null;
  }

  bool hasSelection() {
    return startDate != null || endDate != null;
  }

  @override
  Widget build(BuildContext context) {
    final months = generateMonths();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const MyAppBar(appBarText: "Selectează Perioada"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              // Selected period display with new UI
              if (hasSelection())
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF4DD0E1),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          getSelectedPeriodText(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: clearSelection,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.close,
                            size: 20,
                            color: Color(0xFF4DD0E1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Calendar
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: months.length,
                  itemBuilder: (context, index) {
                    return buildMonthCalendar(months[index]);
                  },
                ),
              ),

              // Save button
              MyButton(
                buttonTextSize: 15,
                buttonText: 'Salvează perioada',
                textColor: Colors.white,
                buttonOnTap: () {
                  if (canSave()){
                    Navigator.pop(context, {
                      'startDate': startDate,
                      'endDate': endDate,
                    });
                  }
                },
                withBorder: false,
                gradient: MyColors.myGradient,
                radius: 30,
                leading: SvgPicture.asset(
                  'assets/images/calendar.svg',
                  height: 19,
                  width: 19,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              SizedBox(height: 10,)
            ],
          ),
        ),
      ),
    );
  }
}
