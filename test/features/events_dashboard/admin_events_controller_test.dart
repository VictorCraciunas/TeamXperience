import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/event_type.dart';
import 'package:teamxperience/features/events_dashboard/events_dashboard_admin/controller/events_dashboard_controller.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/service/event_service/event_service.dart';
import 'package:teamxperience/state_management/events_state_management.dart';

class _FakeEventService extends Fake implements EventService {
  _FakeEventService(this.events);

  final List<Event> events;

  @override
  Future<List<Event>> getAllEvents() async => events;
}

Event _event(String id, DateTime start, {EventType type = EventType.PUBLIC}) =>
    Event(eventId: id, name: 'Eveniment $id', dateEvent: start, type: type);

Future<EventList> _list(List<Event> events) async {
  final list = EventList(_FakeEventService(events));
  await list.loadEvents(forceRefresh: true);
  return list;
}

List<String> _ids(List<Event> events) => events.map((e) => e.eventId).toList()..sort();

void main() {
  final now = DateTime.now();
  final future1 = _event('f1', now.add(const Duration(days: 5)));
  final future2 = _event('f2', now.add(const Duration(days: 9)), type: EventType.PRIVAT);
  final past1 = _event('p1', now.subtract(const Duration(days: 5)));
  final past2 = _event('p2', now.subtract(const Duration(days: 9)), type: EventType.PRIVAT);

  test('without filters both groups are shown', () async {
    final list = await _list([future1, future2, past1, past2]);
    final c = EventsDashboardController();
    expect(_ids(c.getDisplayedUpcomingEvents(list)), ['f1', 'f2']);
    expect(_ids(c.getDisplayedPastEvents(list)), ['p1', 'p2']);
    expect(c.hasActiveFilters, isFalse);
  });

  test('the status filter hides the other group', () async {
    final list = await _list([future1, future2, past1, past2]);
    final c = EventsDashboardController();
    c.updateFilters({'status': EventStatusFilter.past});
    expect(c.getDisplayedUpcomingEvents(list), isEmpty);
    expect(_ids(c.getDisplayedPastEvents(list)), ['p1', 'p2']);
    expect(c.hasActiveFilters, isTrue);

    c.updateFilters({'status': EventStatusFilter.upcoming});
    expect(_ids(c.getDisplayedUpcomingEvents(list)), ['f1', 'f2']);
    expect(c.getDisplayedPastEvents(list), isEmpty);
  });

  test('type and status combine', () async {
    final list = await _list([future1, future2, past1, past2]);
    final c = EventsDashboardController();
    c.updateFilters({'eventType': EventType.PRIVAT, 'status': EventStatusFilter.past});
    expect(c.getDisplayedUpcomingEvents(list), isEmpty);
    expect(_ids(c.getDisplayedPastEvents(list)), ['p2']);
  });

  test('a period includes an event later on its last day', () async {
    final day = DateTime(now.year, now.month, now.day).add(const Duration(days: 3));
    final late = _event('late', DateTime(day.year, day.month, day.day, 18));
    final list = await _list([late, future2]);
    final c = EventsDashboardController();
    c.updateFilters({'startDate': day, 'endDate': day});
    expect(_ids(c.getDisplayedUpcomingEvents(list)), ['late']);
  });

  test('clearing the filters shows everything again', () async {
    final list = await _list([future1, past1]);
    final c = EventsDashboardController();
    c.updateFilters({'status': EventStatusFilter.past});
    c.clearFilters();
    expect(c.hasActiveFilters, isFalse);
    expect(_ids(c.getDisplayedUpcomingEvents(list)), ['f1']);
  });
}
