import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/enter_code/logic/start_code_check.dart';
import 'package:teamxperience/model/event.dart';

void main() {
  final start = DateTime(2026, 11, 14, 10);
  final during = DateTime(2026, 11, 14, 10, 20);

  Event event({String? code = 'HARTI', DateTime? date, bool stopped = false, bool noDate = false}) => Event(
        eventId: 'e1',
        startCode: code,
        dateEvent: noDate ? null : (date ?? start),
        isStopped: stopped,
      );

  StartCodeResult check(String input, {Event? e, DateTime? now}) =>
      checkStartCode(input: input, event: e ?? event(), now: now ?? during);

  test('capitals and spaces do not matter', () {
    for (final input in ['harti', ' HARTI ', 'har ti', 'Harti']) {
      expect(check(input), StartCodeResult.ok, reason: input);
    }
  });

  test('a different code is wrong', () {
    expect(check('HARTA'), StartCodeResult.wrong);
  });

  test('an empty code is wrong', () {
    expect(check(''), StartCodeResult.wrong);
  });

  test('before the start it is too early', () {
    expect(check('HARTI', now: DateTime(2026, 11, 14, 9, 59)), StartCodeResult.tooEarly);
  });

  test('the last minute of the window still lets the team in', () {
    expect(check('HARTI', now: DateTime(2026, 11, 14, 11)), StartCodeResult.ok);
  });

  test('after the window it is closed', () {
    expect(check('HARTI', now: DateTime(2026, 11, 14, 11, 0, 1)), StartCodeResult.closed);
  });

  test('a stopped event is closed', () {
    expect(check('HARTI', e: event(stopped: true)), StartCodeResult.closed);
  });

  test('an event with no date is closed', () {
    expect(check('HARTI', e: event(noDate: true)), StartCodeResult.closed);
  });

  test('an event with no code accepts nothing', () {
    expect(check('', e: event(code: null)), StartCodeResult.wrong);
  });

  test('normaliseCode drops every space and lower-cases', () {
    expect(normaliseCode(' Ha r\tTI '), 'harti');
  });

  test("the window is the event's own: 31 min after the start is closed for a 30-minute event", () {
    final short = Event(eventId: 'e1', startCode: 'HARTI', dateEvent: start, enterWindowMinutes: 30);
    final late = DateTime(2026, 11, 14, 10, 31);
    expect(check('HARTI', e: short, now: late), StartCodeResult.closed);
    expect(check('HARTI', now: late), StartCodeResult.ok);
  });
}
