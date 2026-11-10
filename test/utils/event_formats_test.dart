import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/difficulty.dart';
import 'package:teamxperience/utils/event_formats.dart';

void main() {
  test('kilometres use a comma and at most one decimal', () {
    expect(formatKm(4.5), '4,5 km');
    expect(formatKm(4.0), '4 km');
    expect(formatKm(12.25), '12,3 km');
  });

  test('durations read as hours and minutes', () {
    expect(formatDuration(120), '2 h');
    expect(formatDuration(90), '1 h 30');
    expect(formatDuration(45), '45 min');
    expect(formatDuration(125), '2 h 05');
  });

  test('difficulty labels and levels', () {
    expect(
      [for (final d in Difficulty.values) difficultyLabel(d)],
      ['Ușoară', 'Medie', 'Grea'],
    );
    expect([for (final d in Difficulty.values) difficultyLevel(d)], [1, 2, 3]);
  });

  test('short months follow the mockup', () {
    expect(
      [for (var m = 1; m <= 12; m++) shortMonth(m)],
      [
        'ian',
        'feb',
        'mar',
        'apr',
        'mai',
        'iun',
        'iul',
        'aug',
        'sep',
        'oct',
        'nov',
        'dec',
      ],
    );
  });

  test('dates for the tiles and lines of the page', () {
    final start = DateTime(2026, 11, 14, 10);
    expect(dayAndMonth(start), '14 nov');
    expect(monthAndTime(start), 'nov · 10:00');
    expect(
      eventDayLine(start, 15),
      'Sâmbătă 14 nov · 10:00 · fii acolo la 9:45',
    );
    expect(
      eventDayLine(DateTime(2026, 11, 15, 9, 5), 20),
      'Duminică 15 nov · 09:05 · fii acolo la 8:45',
    );
  });

  test('initials of an organiser', () {
    expect(initialsOf('TeamXperience'), 'TX');
    expect(initialsOf('Ana Pop'), 'AP');
    expect(initialsOf('x'), 'X');
    expect(initialsOf('cartograful'), 'C');
    expect(initialsOf(''), '');
  });

  test('route summary on the strip', () {
    expect(routeSummary(4.5, 6), '4,5 km · 6 misiuni');
    expect(routeSummary(2, 1), '2 km · 1 misiune');
    expect(routeSummary(null, 6), '6 misiuni');
  });

  test('team size line', () {
    expect(teamSizeLine(2, 6), 'Echipe de 2–6');
    expect(teamSizeLine(4, 4), 'Echipe de 4');
  });

  test('short day names, Monday first', () {
    // 2026-11-09 is a Monday.
    final names = [
      for (var i = 0; i < 7; i++) shortDay(DateTime(2026, 11, 9 + i)),
    ];
    expect(names, ['Lun', 'Mar', 'Mie', 'Joi', 'Vin', 'Sâm', 'Dum']);
  });

  test('short date and time', () {
    expect(shortDateTime(DateTime(2026, 11, 14, 10)), 'Sâm 14 nov, 10:00');
    expect(shortDateTime(DateTime(2026, 11, 9, 9, 5)), 'Lun 9 nov, 09:05');
  });
}
