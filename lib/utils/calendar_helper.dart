import 'package:flutter/material.dart';

class CalendarHelper{
  Future<DateTime?> selectDate(BuildContext context) async {
    // Pick the date (or null if they cancel)
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
}