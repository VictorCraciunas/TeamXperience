import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/event_details/logic/enrolment_window.dart';
import 'package:teamxperience/model/event.dart';

void main() {
  final start = DateTime(2026, 11, 14, 10);
  Event event({int window = 60}) => Event(eventId: 'e1', dateEvent: start, enterWindowMinutes: window);

  test('the enter window follows the event', () {
    final at = DateTime(2026, 11, 14, 10, 31);
    expect(inEnterWindow(event(window: 30), at), isFalse);
    expect(inEnterWindow(event(), at), isTrue);
  });

  test('minutes left count down from the event\'s window', () {
    final at = DateTime(2026, 11, 14, 10, 18);
    expect(enterMinutesLeft(event(), at), 42);
    expect(enterMinutesLeft(event(window: 30), at), 12);
  });
}
