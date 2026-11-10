import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/event_type.dart';
import 'package:teamxperience/features/play_tab/logic/play_suggestions.dart';
import 'package:teamxperience/model/event.dart';

final _now = DateTime(2026, 11, 10, 12);

Event _e(String id, DateTime start, {EventType type = EventType.PUBLIC, DateTime? opens, DateTime? closes}) =>
    Event(eventId: id, dateEvent: start, type: type, dateStartEnrollment: opens, dateDeadlineEnrollment: closes);

void main() {
  test('openSuggestions keeps open public future events, earliest first', () {
    final later = _e('later', DateTime(2026, 11, 28));
    final sooner = _e('sooner', DateTime(2026, 11, 14));
    final all = [
      later,
      _e('past', DateTime(2026, 11, 1)),
      _e('private', DateTime(2026, 11, 20), type: EventType.PRIVAT),
      _e('registered', DateTime(2026, 11, 21)),
      _e('not-open-yet', DateTime(2026, 12, 5), opens: DateTime(2026, 11, 20)),
      _e('closed', DateTime(2026, 11, 22), closes: DateTime(2026, 11, 9)),
      sooner,
    ];
    expect(openSuggestions(all, {'registered'}, _now).map((e) => e.eventId), ['sooner', 'later']);
  });

  test('nextSuggestion never repeats the current one', () {
    for (var seed = 0; seed < 50; seed++) {
      final next = nextSuggestion(1, 4, Random(seed));
      expect(next, isNot(1));
      expect(next, inInclusiveRange(0, 3));
    }
    expect(nextSuggestion(0, 1, Random(1)), 0);
    expect(nextSuggestion(0, 0, Random(1)), 0);
  });
}
