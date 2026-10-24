import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/utils/period_utils.dart';

void main() {
  final start = DateTime(2026, 10, 1);
  final end = DateTime(2026, 10, 31); // midnight, the picker returns whole days

  test('an event on the last day of the period, later in the day, is inside', () {
    expect(isWithinPeriod(DateTime(2026, 10, 31, 14), start, end), isTrue);
    expect(isWithinPeriod(DateTime(2026, 10, 31, 23, 59), start, end), isTrue);
  });

  test('an event on the first day is inside, even early in the morning', () {
    expect(isWithinPeriod(DateTime(2026, 10, 1, 0, 5), start, end), isTrue);
  });

  test('days outside the period are outside', () {
    expect(isWithinPeriod(DateTime(2026, 9, 30, 23, 59), start, end), isFalse);
    expect(isWithinPeriod(DateTime(2026, 11, 1, 0, 0), start, end), isFalse);
  });

  test('without a full period nothing is filtered out', () {
    expect(isWithinPeriod(DateTime(2030, 1, 1), null, null), isTrue);
    expect(isWithinPeriod(DateTime(2030, 1, 1), start, null), isTrue);
  });

  test('an item without a date is kept', () {
    expect(isWithinPeriod(null, start, end), isTrue);
  });
}
