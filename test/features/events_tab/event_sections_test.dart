import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/events_tab/logic/event_sections.dart';
import 'package:teamxperience/model/event.dart';

final _now = DateTime(2026, 11, 7, 12);

Event _e(String id, DateTime date, {DateTime? opens, DateTime? closes, bool stopped = false}) => Event(
      eventId: id,
      dateEvent: date,
      dateStartEnrollment: opens,
      dateDeadlineEnrollment: closes,
      isStopped: stopped,
    );

List<String> _ids(List<Event> events) => [for (final e in events) e.eventId];

void main() {
  final later = _e('later', DateTime(2026, 11, 28, 10), opens: DateTime(2026, 11, 1), closes: DateTime(2026, 11, 26));
  final sooner = _e('sooner', DateTime(2026, 11, 14, 10), opens: DateTime(2026, 11, 1), closes: DateTime(2026, 11, 12));
  final notYet = _e('notYet', DateTime(2026, 12, 20, 10), opens: DateTime(2026, 12, 1), closes: DateTime(2026, 12, 18));
  final closed = _e('closed', DateTime(2026, 11, 9, 10), opens: DateTime(2026, 10, 1), closes: DateTime(2026, 11, 5));
  final over = _e('over', DateTime(2026, 11, 1, 10));
  final stopped = _e('stopped', DateTime(2026, 11, 30, 10), stopped: true);

  test('registered events come first, soonest first, even while enrolment is open', () {
    final s = sectionEvents([later, sooner, notYet], {'later', 'sooner'}, _now);
    expect(_ids(s.registered), ['sooner', 'later']);
    expect(s.open, isEmpty);
  });

  test('open and soon hold the events the player is not in', () {
    final s = sectionEvents([later, notYet, sooner], {}, _now);
    expect(_ids(s.open), ['sooner', 'later']);
    expect(_ids(s.soon), ['notYet']);
  });

  test('over events and closed events the player is not in are not shown', () {
    final s = sectionEvents([closed, over, stopped, later], {'over'}, _now);
    expect(_ids(s.registered), isEmpty);
    expect(_ids(s.open), ['later']);
    expect(s.soon, isEmpty);
  });

  test('a registered event whose enrolment has closed still shows under registered', () {
    final s = sectionEvents([closed], {'closed'}, _now);
    expect(_ids(s.registered), ['closed']);
  });
}
