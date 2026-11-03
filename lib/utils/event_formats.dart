import 'package:teamxperience/enums/difficulty.dart';

/// Texts of the event page and the event form, as the mockups write them.

const _months = ['ian', 'feb', 'mar', 'apr', 'mai', 'iun', 'iul', 'aug', 'sep', 'oct', 'nov', 'dec'];
const _days = ['Luni', 'Marți', 'Miercuri', 'Joi', 'Vineri', 'Sâmbătă', 'Duminică'];

String _two(int n) => n.toString().padLeft(2, '0');

/// "4,5 km", "4 km", "12,3 km".
String formatKm(double km) {
  final rounded = (km * 10).round() / 10;
  final text = rounded == rounded.roundToDouble() ? rounded.toInt().toString() : rounded.toStringAsFixed(1);
  return '${text.replaceAll('.', ',')} km';
}

/// "2 h", "1 h 30", "45 min", "2 h 05".
String formatDuration(int minutes) {
  if (minutes < 60) return '$minutes min';
  final rest = minutes % 60;
  return rest == 0 ? '${minutes ~/ 60} h' : '${minutes ~/ 60} h ${_two(rest)}';
}

String difficultyLabel(Difficulty d) => switch (d) {
      Difficulty.easy => 'Ușoară',
      Difficulty.medium => 'Medie',
      Difficulty.hard => 'Grea',
    };

/// How many of the three dots are filled.
int difficultyLevel(Difficulty d) => d.index + 1;

/// "nov" for 11.
String shortMonth(int month) => _months[month - 1];

/// "14 nov".
String dayAndMonth(DateTime d) => '${d.day} ${shortMonth(d.month)}';

/// "nov · 10:00", under the day on the date tile.
String monthAndTime(DateTime d) => '${shortMonth(d.month)} · ${_two(d.hour)}:${_two(d.minute)}';

/// "Sâmbătă 14 nov · 10:00 · fii acolo la 9:45".
String eventDayLine(DateTime start, int arriveMinutesBefore) {
  final arrive = start.subtract(Duration(minutes: arriveMinutesBefore));
  return '${_days[start.weekday - 1]} ${dayAndMonth(start)} · ${_two(start.hour)}:${_two(start.minute)}'
      ' · fii acolo la ${arrive.hour}:${_two(arrive.minute)}';
}

/// "TX" for "TeamXperience" (two capitals of one word), "AP" for "Ana Pop".
String initialsOf(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return '';
  if (words.length > 1) return (words[0][0] + words[1][0]).toUpperCase();
  final capitals = RegExp('[A-ZĂÂÎȘȚ]').allMatches(words[0]).map((m) => m.group(0)!).toList();
  if (capitals.length >= 2) return capitals.take(2).join();
  return words[0][0].toUpperCase();
}

/// "4,5 km · 6 misiuni", or only the missions when the length is unknown.
String routeSummary(double? km, int missions) {
  final count = missions == 1 ? '1 misiune' : '$missions misiuni';
  return km == null ? count : '${formatKm(km)} · $count';
}

/// "Echipe de 2–6", or "Echipe de 4" when both ends are the same.
String teamSizeLine(int min, int max) => min == max ? 'Echipe de $min' : 'Echipe de $min–$max';
