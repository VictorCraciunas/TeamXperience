import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/difficulty.dart';
import 'package:teamxperience/features/events_tab/logic/event_filters.dart';
import 'package:teamxperience/model/event.dart';

final _now = DateTime(2026, 11, 7, 12);

Event _e(String id, {DateTime? date, Difficulty? difficulty, int? minutes, String? name, String? location, String? area}) => Event(
      eventId: id,
      name: name ?? id,
      location: location,
      area: area,
      dateEvent: date ?? DateTime(2026, 11, 20, 10),
      difficulty: difficulty,
      durationMinutes: minutes,
    );

List<String> _ids(List<Event> events) => [for (final e in events) e.eventId];

void main() {
  final easy = _e('easy', difficulty: Difficulty.easy, minutes: 90);
  final medium = _e('medium', difficulty: Difficulty.medium, minutes: 120);
  final hard = _e('hard', difficulty: Difficulty.hard, minutes: 180, date: DateTime(2026, 12, 5, 10));
  final bare = _e('bare');
  final all = [easy, medium, hard, bare];

  List<String> run(Set<EventFilter> filters, {String search = ''}) =>
      _ids(applyQuery(all, EventQuery(filters: filters, search: search), _now));

  test('no filters keep everything, and that is "all"', () {
    expect(run({}), ['easy', 'medium', 'hard', 'bare']);
    expect(const EventQuery().isAll, isTrue);
    expect(const EventQuery(search: 'x').isAll, isFalse);
    expect(const EventQuery(filters: {EventFilter.easy}).isAll, isFalse);
  });

  test('difficulties combine with OR, and an event without one is hidden by them', () {
    expect(run({EventFilter.easy, EventFilter.medium}), ['easy', 'medium']);
    expect(run({EventFilter.hard}), ['hard']);
  });

  test('this month keeps events in the current month and year', () {
    expect(run({EventFilter.thisMonth}), ['easy', 'medium', 'bare']);
  });

  test('under 2 h keeps 120 minutes and less, and hides events without a duration', () {
    expect(run({EventFilter.under2h}), ['easy', 'medium']);
  });

  test('different kinds of filter combine with AND', () {
    expect(run({EventFilter.thisMonth, EventFilter.under2h}), ['easy', 'medium']);
    expect(run({EventFilter.hard, EventFilter.thisMonth}), isEmpty);
  });

  test('old events read difficulty and duration from their text', () {
    final old = Event(eventId: 'old', dateEvent: DateTime(2026, 11, 20), dificultate: 'Ușoară', durata: '1h30');
    expect(_ids(applyQuery([old], const EventQuery(filters: {EventFilter.easy, EventFilter.under2h}), _now)), ['old']);
  });

  test('search matches name, location or area, ignoring case and diacritics', () {
    final events = [
      _e('a', name: 'Moștenirea Cartografului'),
      _e('b', name: 'Protocolul Cerber', location: 'Brașov'),
      _e('c', name: 'X', area: 'Orașul de Sus'),
    ];
    List<String> s(String q) => _ids(applyQuery(events, EventQuery(search: q), _now));
    expect(s('mostenirea'), ['a']);
    expect(s('BRASOV'), ['b']);
    expect(s('orasul'), ['c']);
    expect(s('  '), ['a', 'b', 'c']);
  });
}
