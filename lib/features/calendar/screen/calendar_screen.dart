import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';
import 'package:teamxperience/ui/components/misc/period_picker.dart';
import 'package:teamxperience/ui/components/misc/period_selection.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/utils/calendar_helper.dart';

/// Full-screen date range picker (used by the admin filter screens). It shares
/// the calendar with the period bottom sheet.
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
  late PeriodSelection _selection = PeriodSelection(
    start: widget.initialStartDate,
    end: widget.initialEndDate,
  );

  String get _selectedPeriodText {
    final start = _selection.start;
    final end = _selection.end;
    if (start == null) return 'Selectează perioada';
    if (end == null) return 'Selectează data de sfârșit';
    return '${CalendarHelper.formatDate(start)} - ${CalendarHelper.formatDate(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.page,
      appBar: const MyAppBar(appBarText: "Selectează Perioada"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            children: [
              if (!_selection.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.tick, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedPeriodText,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: colors.text,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed:
                            () => setState(
                              () => _selection = const PeriodSelection(),
                            ),
                        tooltip: 'Șterge perioada',
                        icon: Icon(Icons.close, size: 20, color: colors.text),
                      ),
                    ],
                  ),
                ),
              PeriodPicker(
                selection: _selection,
                now: DateTime.now(),
                onDayTap:
                    (date) => setState(() => _selection = _selection.tap(date)),
              ),
              const Spacer(),
              AppButton(
                label: 'Salvează perioada',
                leading: const Icon(Icons.calendar_today_outlined),
                backgroundColor: colors.tick,
                foregroundColor: colors.onTick,
                onPressed:
                    _selection.isComplete
                        ? () => Navigator.pop(context, {
                          'startDate': _selection.start,
                          'endDate': _selection.end,
                        })
                        : null,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
