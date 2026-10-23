import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/misc/period_selection.dart';

DateTime d(int month, int day) => DateTime(2026, month, day);

void main() {
  group('PeriodSelection.tap', () {
    test('the first tap sets the start', () {
      final s = const PeriodSelection().tap(d(10, 20));
      expect(s.start, d(10, 20));
      expect(s.end, isNull);
      expect(s.isComplete, isFalse);
    });

    test('the second tap sets the end', () {
      final s = const PeriodSelection().tap(d(10, 20)).tap(d(10, 30));
      expect(s.start, d(10, 20));
      expect(s.end, d(10, 30));
      expect(s.isComplete, isTrue);
    });

    test('a second tap before the start swaps the two', () {
      final s = const PeriodSelection().tap(d(10, 20)).tap(d(10, 10));
      expect(s.start, d(10, 10));
      expect(s.end, d(10, 20));
    });

    test('a third tap starts a new selection', () {
      final s = const PeriodSelection().tap(d(10, 20)).tap(d(10, 30)).tap(d(11, 2));
      expect(s.start, d(11, 2));
      expect(s.end, isNull);
    });

    test('times of day are ignored', () {
      final s = const PeriodSelection().tap(DateTime(2026, 10, 20, 15, 30));
      expect(s.start, d(10, 20));
    });
  });

  group('PeriodSelection queries', () {
    final s = PeriodSelection(start: d(10, 20), end: d(10, 25));

    test('knows the ends and the days in between', () {
      expect(s.isStart(d(10, 20)), isTrue);
      expect(s.isEnd(d(10, 25)), isTrue);
      expect(s.isInside(d(10, 22)), isTrue);
      expect(s.isInside(d(10, 20)), isFalse);
      expect(s.isInside(d(10, 26)), isFalse);
    });

    test('a start without an end only marks the start', () {
      final half = PeriodSelection(start: d(10, 20));
      expect(half.isStart(d(10, 20)), isTrue);
      expect(half.isInside(d(10, 21)), isFalse);
    });

    test('an empty selection is not complete and marks nothing', () {
      expect(const PeriodSelection().isEmpty, isTrue);
      expect(const PeriodSelection().isStart(d(10, 20)), isFalse);
    });
  });

  group('periodPresets', () {
    final now = DateTime(2026, 10, 20, 14); // a Tuesday
    final presets = periodPresets(now);

    PeriodPreset named(String label) => presets.firstWhere((p) => p.label == label);

    test('Oricând clears the period', () {
      expect(named('Oricând').selection.isEmpty, isTrue);
    });

    test('Săptămâna asta runs from Monday to Sunday', () {
      final week = named('Săptămâna asta').selection;
      expect(week.start, d(10, 19));
      expect(week.end, d(10, 25));
    });

    test('Luna asta covers the whole month', () {
      final month = named('Luna asta').selection;
      expect(month.start, d(10, 1));
      expect(month.end, d(10, 31));
    });

    test('there is no 30 days preset', () {
      expect(presets.map((p) => p.label), ['Oricând', 'Săptămâna asta', 'Luna asta']);
    });

    test('a preset is recognised as the current selection', () {
      expect(named('Luna asta').matches(PeriodSelection(start: d(10, 1), end: d(10, 31))), isTrue);
      expect(named('Luna asta').matches(PeriodSelection(start: d(10, 2), end: d(10, 31))), isFalse);
    });
  });
}
