import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/event_status.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/service/event_service/event_service.dart';
import 'package:teamxperience/state_management/events_state_management.dart';

class _FakeEventService extends Fake implements EventService {
  _FakeEventService(this.stored, {this.failSave = false, this.failPublish = false});

  final List<Event> stored;
  final bool failSave;
  final bool failPublish;
  final deleted = <String>[];

  @override
  Future<List<Event>> getAllEvents() async => List.of(stored);

  @override
  Future<Event> saveDraft(Event event, {int? wizardStep}) async {
    if (failSave) throw Exception('offline');
    event
      ..status = EventStatus.draft
      ..updatedAt = DateTime(2026, 10, 20, 12)
      ..wizardStep = wizardStep ?? event.wizardStep;
    if (event.eventId.isEmpty) event.eventId = 'new-id';
    return event;
  }

  @override
  Future<Event> publishEvent(Event event) async {
    if (failPublish) throw Exception('incomplete');
    event
      ..status = EventStatus.published
      ..updatedAt = DateTime(2026, 10, 20, 13);
    return event;
  }

  @override
  Future<void> deleteEvent(String eventId) async => deleted.add(eventId);
}

final _future = DateTime.now().add(const Duration(days: 5));
final _past = DateTime.now().subtract(const Duration(days: 5));

Event _published(String id, DateTime day) => Event(eventId: id, name: id, dateEvent: day);

Event _draft(String id, {DateTime? edited, DateTime? day}) =>
    Event(eventId: id, name: id, status: EventStatus.draft, updatedAt: edited, dateEvent: day);

Future<EventList> _loaded(List<Event> events, {_FakeEventService? service}) async {
  final list = EventList(service ?? _FakeEventService(events));
  await list.loadEvents(forceRefresh: true);
  return list;
}

List<String> _ids(Iterable<Event> events) => events.map((e) => e.eventId).toList();

void main() {
  test('drafts never show up in what players and the admin lists see', () async {
    final list = await _loaded([
      _published('up', _future),
      _published('old', _past),
      _draft('d1', day: _future),
      _draft('d2', day: _past),
    ]);

    expect(_ids(list.events)..sort(), ['old', 'up']);
    expect(_ids(list.upcomingEvents), ['up']);
    expect(_ids(list.pastEvents), ['old']);
    expect(_ids(list.liveEvents), isEmpty);
  });

  test('drafts are listed apart, most recently edited first, never edited last', () async {
    final list = await _loaded([
      _draft('never'),
      _draft('old', edited: DateTime(2026, 10, 1)),
      _draft('new', edited: DateTime(2026, 10, 19)),
      _published('p', _future),
    ]);
    expect(_ids(list.draftEvents), ['new', 'old', 'never']);
  });

  test('a draft without a date does not break the date based lists', () async {
    final list = await _loaded([_draft('d'), _published('p', _future)]);
    expect(_ids(list.upcomingEvents), ['p']);
    expect(list.pastEvents, isEmpty);
  });

  test('a draft can still be found by id, for editing', () async {
    final list = await _loaded([_draft('d')]);
    expect(list.getEventById('d')?.isDraft, isTrue);
  });

  group('saveDraft', () {
    test('adds a new draft to the drafts', () async {
      final list = await _loaded([]);
      var notified = 0;
      list.addListener(() => notified++);

      final saved = await list.saveDraft(Event(eventId: '', name: 'Nou'), wizardStep: 1);

      expect(saved.eventId, 'new-id');
      expect(_ids(list.draftEvents), ['new-id']);
      expect(list.draftEvents.single.wizardStep, 1);
      expect(notified, greaterThan(0));
    });

    test('saving again replaces the draft instead of adding another', () async {
      final list = await _loaded([_draft('d')]);
      await list.saveDraft(list.draftEvents.single..name = 'Redenumit', wizardStep: 3);
      expect(list.draftEvents, hasLength(1));
      expect(list.draftEvents.single.name, 'Redenumit');
      expect(list.draftEvents.single.wizardStep, 3);
    });

    test('a failed save leaves the list alone and reports the error', () async {
      final list = await _loaded([], service: _FakeEventService([], failSave: true));
      await expectLater(list.saveDraft(Event(eventId: 'x')), throwsA(isA<Exception>()));
      expect(list.draftEvents, isEmpty);
    });
  });

  group('publishEvent', () {
    test('moves a draft out of the drafts and into the events', () async {
      final list = await _loaded([_draft('d', day: _future)]);
      await list.publishEvent(list.getEventById('d')!);
      expect(list.draftEvents, isEmpty);
      expect(_ids(list.events), ['d']);
      expect(_ids(list.upcomingEvents), ['d']);
    });

    test('an event that cannot be published stays a draft', () async {
      final list = await _loaded(
        [_draft('d')],
        service: _FakeEventService([_draft('d')], failPublish: true),
      );
      await expectLater(list.publishEvent(list.getEventById('d')!), throwsA(isA<Exception>()));
      expect(_ids(list.draftEvents), ['d']);
      expect(list.events, isEmpty);
    });
  });

  test('deleting a draft removes it', () async {
    final service = _FakeEventService([_draft('d'), _published('p', _future)]);
    final list = await _loaded([], service: service);
    await list.deleteEvent('d');
    expect(list.draftEvents, isEmpty);
    expect(_ids(list.events), ['p']);
    expect(service.deleted, ['d']);
  });
}
