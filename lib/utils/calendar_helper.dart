import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarHelper {
  Future<DateTime?> selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) {
      // user tapped "Cancel" on the date picker
      return null;
    }

    // Now pick a time (or null if they cancel)
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) {
      // user tapped "Cancel" on the time picker
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

  // Romanian month names (full)
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

  // Romanian month abbreviations
  static const Map<int, String> _romanianMonthsShort = {
    1: 'ian',
    2: 'feb',
    3: 'mar',
    4: 'apr',
    5: 'mai',
    6: 'iun',
    7: 'iul',
    8: 'aug',
    9: 'sep',
    10: 'oct',
    11: 'noi',
    12: 'dec',
  };

  /// Formats a DateTime to Romanian format: "Sâmbătă, 7 iunie"
  static String formatEventDate(DateTime? dateTime) {
    if (dateTime == null) return "Data nu este disponibilă";

    final dayName = _romanianDays[dateTime.weekday] ?? '';
    final day = dateTime.day;
    final monthName = _romanianMonths[dateTime.month] ?? '';

    return "$dayName, $day $monthName";
  }
  static Map<String, String> formatEventCardDate(DateTime? dateTime) {
    if (dateTime == null) {
      return {'month': 'Ianuarie', 'day': '01'};
    }

    final month = _romanianMonths[dateTime.month] ?? 'Ianuarie';
    final day = dateTime.day.toString().padLeft(2, '0');

    return {'month': month, 'day': day};
  }

  /// Alternative: Get just the month name for event cards
  static String getEventCardMonth(DateTime? dateTime) {
    if (dateTime == null) return 'Ianuarie';
    return _romanianMonths[dateTime.month] ?? 'Ianuarie';
  }

  /// Alternative: Get just the day for event cards
  static String getEventCardDay(DateTime? dateTime) {
    if (dateTime == null) return '01';
    return dateTime.day.toString().padLeft(2, '0');
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

  /// Formats a DateTime to format: "dd MMM yyyy" with Romanian month abbreviations
  /// Example: "07 iun 2024"
  static String formatDate(DateTime? date) {
    if (date == null) return 'No date';

    final day = date.day.toString().padLeft(2, '0');
    final monthAbbr = _romanianMonthsShort[date.month] ?? 'unknown';
    final year = date.year.toString();

    return '$day $monthAbbr $year';
  }

  /// Alternative format with shorter day format: "7 iun 2024" (without leading zero)
  static String formatDateShort(DateTime? date) {
    if (date == null) return 'No date';

    final day = date.day.toString();
    final monthAbbr = _romanianMonthsShort[date.month] ?? 'unknown';
    final year = date.year.toString();

    return '$day $monthAbbr $year';
  }



  // Romanian day abbreviations for calendar headers
  static const List<String> romanianDaysShort = [
    'Lu', 'Ma', 'Mi', 'Jo', 'Vi', 'Sâ', 'Du'
  ];

  // Romanian month names (uppercase for calendar headers)
  static const Map<int, String> romanianMonthsUpper = {
    1: 'IANUARIE', 2: 'FEBRUARIE', 3: 'MARTIE', 4: 'APRILIE',
    5: 'MAI', 6: 'IUNIE', 7: 'IULIE', 8: 'AUGUST',
    9: 'SEPTEMBRIE', 10: 'OCTOMBRIE', 11: 'NOIEMBRIE', 12: 'DECEMBRIE',
  };
}