import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/events_tab/logic/event_card_texts.dart';
import 'package:teamxperience/model/event.dart';

void main() {
  test('until text counts calendar days', () {
    final now = DateTime(2026, 11, 11, 23);
    expect(untilText(now, DateTime(2026, 11, 11, 23, 30)), 'azi');
    expect(untilText(now, DateTime(2026, 11, 12, 1)), 'mâine');
    expect(untilText(now, DateTime(2026, 11, 14, 10)), 'peste 3 zile');
  });

  test('spots badge only when 5 places or fewer are left', () {
    expect(spotsBadge(null, 3), isNull);
    expect(spotsBadge(12, 6), isNull);
    expect(spotsBadge(12, 7), 'Mai sunt 5 locuri');
    expect(spotsBadge(12, 10), 'Mai sunt 2 locuri');
    expect(spotsBadge(12, 11), 'Mai e un loc');
    expect(spotsBadge(12, 12), 'Nu mai sunt locuri');
    expect(spotsBadge(12, 15), 'Nu mai sunt locuri');
  });

  test('card date and route facts', () {
    expect(cardDate(DateTime(2026, 11, 21, 10)), 'Sâm 21 nov');
    expect(cardRouteFacts(Event(eventId: 'e', routeLengthKm: 3.2, durationMinutes: 90)), '3,2 km · 1 h 30');
    expect(cardRouteFacts(Event(eventId: 'e', durationMinutes: 120)), '2 h');
    expect(cardRouteFacts(Event(eventId: 'e')), '');
  });
}
