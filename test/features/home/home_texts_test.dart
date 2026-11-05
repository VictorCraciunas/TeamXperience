import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/home/logic/home_texts.dart';

void main() {
  group('heroDateLine', () {
    final start = DateTime(2026, 11, 14, 10);

    test('day, time and the start point', () {
      expect(heroDateLine(start, 'Piața Mare'), 'Sâm 14 nov · 10:00 · Piața Mare');
    });

    test('without a place', () {
      expect(heroDateLine(start, null), 'Sâm 14 nov · 10:00');
      expect(heroDateLine(start, '  '), 'Sâm 14 nov · 10:00');
    });
  });

  group('levelFor', () {
    test('Începător from 0', () {
      final level = levelFor(0);
      expect((level.name, level.progress), ('Începător', 0.0));
    });

    test('Explorator at 800 is 60 % of the way to Cartograf', () {
      final level = levelFor(800);
      expect(level.name, 'Explorator');
      expect(level.progress, closeTo(0.6, 1e-9));
    });

    test('Cartograf from 1000', () {
      final level = levelFor(1000);
      expect((level.name, level.progress), ('Cartograf', 0.0));
    });

    test('Legendă is full', () {
      final level = levelFor(3000);
      expect((level.name, level.progress), ('Legendă', 1.0));
    });

    test('negative xp counts as 0', () {
      expect(levelFor(-5).name, 'Începător');
    });
  });

  test('kmStat', () {
    expect(kmStat(12400), '12,4 km');
    expect(kmStat(0), '0 km');
  });
}
