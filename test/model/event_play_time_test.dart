import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/model/event.dart';

final _start = DateTime(2026, 11, 14, 10);

Event _event({int? minutes, int window = 60, DateTime? start}) =>
    Event(eventId: 'e', dateEvent: start ?? _start, durationMinutes: minutes, enterWindowMinutes: window);

void main() {
  group('the game lasts the event\'s duration', () {
    test('its duration in minutes', () {
      expect(_event(minutes: 90).playTime, const Duration(minutes: 90));
      expect(_event(minutes: 90).endsAt, DateTime(2026, 11, 14, 11, 30));
    });

    test('without a duration, three hours as before', () {
      expect(_event().playTime, const Duration(hours: 3));
      expect(_event(minutes: 0).playTime, const Duration(hours: 3));
      expect(_event(minutes: -5).playTime, const Duration(hours: 3));
    });

    test('no date, no end', () {
      expect(Event(eventId: 'e', durationMinutes: 90).endsAt, isNull);
    });

    test('over once the duration has passed', () {
      final now = DateTime.now();
      expect(_event(minutes: 60, start: now.subtract(const Duration(minutes: 61))).isOver, isTrue);
      expect(_event(minutes: 60, start: now.subtract(const Duration(minutes: 59))).isOver, isFalse);
      expect(_event(start: now.subtract(const Duration(minutes: 61))).isOver, isFalse);
    });

    test('isOverAt reads the given clock', () {
      final e = _event(minutes: 45);
      expect(e.isOverAt(DateTime(2026, 11, 14, 10, 45)), isFalse);
      expect(e.isOverAt(DateTime(2026, 11, 14, 10, 45, 1)), isTrue);
      expect((_event(minutes: 45)..isStopped = true).isOverAt(_start), isTrue);
    });
  });

  group('the start code', () {
    test('works for the event\'s own window', () {
      expect(_event(minutes: 120, window: 60).enterWindow, const Duration(minutes: 60));
    });

    test('never past the end of the game', () {
      expect(_event(minutes: 45, window: 60).enterWindow, const Duration(minutes: 45));
    });
  });
}
