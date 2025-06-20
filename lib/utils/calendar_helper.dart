import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarHelper{
  Future<DateTime?> selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context:  context,
      initialDate: DateTime.now(),
      firstDate:   DateTime.now(),
      lastDate:    DateTime(2100),
    );

    if (pickedDate == null) {
      // user tapped “Cancel” on the date picker
      return null;
    }

    // Now pick a time (or null if they cancel)
    final pickedTime = await showTimePicker(
      context:context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) {
      // user tapped “Cancel” on the time picker
      return null;
    }

    // Both non-null ⇒ build and return the combined DateTime
    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }

  static const Map<int, String> _romanianDays = {
    1: 'Luni',
    2: 'Marți',
    3: 'Miercuri',
    4: 'Joi',
    5: 'Vineri',
    6: 'Sâmbătă',
    7: 'Duminică',
  };

  // Romanian month names
  static const Map<int, String> _romanianMonths = {
    1: 'ianuarie',
    2: 'februarie',
    3: 'martie',
    4: 'aprilie',
    5: 'mai',
    6: 'iunie',
    7: 'iulie',
    8: 'august',
    9: 'septembrie',
    10: 'octombrie',
    11: 'noiembrie',
    12: 'decembrie',
  };

  /// Formats a DateTime to Romanian format: "Sâmbătă, 7 iunie"
  static String formatEventDate(DateTime? dateTime) {
    if (dateTime == null) return "Data nu este disponibilă";

    final dayName = _romanianDays[dateTime.weekday] ?? '';
    final day = dateTime.day;
    final monthName = _romanianMonths[dateTime.month] ?? '';

    return "$dayName, $day $monthName";
  }

  /// Formats a DateTime to time format: "ora 11:00"
  static String formatEventTime(DateTime? dateTime) {
    if (dateTime == null) return "Ora nu este disponibilă";

    final formatter = DateFormat('HH:mm');
    final timeString = formatter.format(dateTime);

    return "ora $timeString";
  }

  /// Returns both date and time formatted
  static Map<String, String> formatEventDateTime(DateTime? dateTime) {
    return {
      'date': formatEventDate(dateTime),
      'time': formatEventTime(dateTime),
    };
  }


}