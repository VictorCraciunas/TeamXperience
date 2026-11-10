import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/enums/event_status.dart';
import 'package:teamxperience/enums/event_type.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/exceptions/events_exceptions.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/puzzle.dart';
import 'package:teamxperience/service/event_service/event_status_changes.dart';

final _now = DateTime(2026, 10, 20, 12);

Event _complete() => Event(
      eventId: 'e',
      name: 'Xtreme',
      description: 'Un joc',
      location: 'Sibiu',
      punctDeStart: 'Piața Mare',
      finishPoint: 'Turnul Sfatului',
      startLatitude: 45.79,
      startLongitude: 24.15,
      dateEvent: DateTime(2026, 10, 25, 14),
      dateStartEnrollment: DateTime(2026, 10, 1),
      dateDeadlineEnrollment: DateTime(2026, 10, 24),
      type: EventType.PUBLIC,
      startCode: 'XTREME',
      lungimeTraseu: '4 km',
      durata: '2 ore',
      dificultate: 'Medie',
      status: EventStatus.draft,
      missions: [
        Mission(id: '0', title: 'Ceasul', puzzles: [
          Puzzle(
            id: 'p',
            type: PuzzleType.code,
            code: 'ceas',
            components: [Component(type: ComponentType.text, text: 't')],
          ),
        ]),
        Mission(id: '1', title: 'Poza', puzzles: [
          Puzzle(
            id: 'q',
            type: PuzzleType.imageToUpload,
            components: [Component(type: ComponentType.text, text: 't')],
          ),
        ]),
      ],
    );

void main() {
  group('asDraft', () {
    test('marks the event a draft and stamps the time', () {
      final event = Event(eventId: 'd', name: 'Început', status: EventStatus.published);
      final draft = asDraft(event, now: _now, wizardStep: 2);
      expect(draft.status, EventStatus.draft);
      expect(draft.updatedAt, _now);
      expect(draft.wizardStep, 2);
    });

    test('keeps the step when none is given', () {
      final draft = asDraft(Event(eventId: 'd', wizardStep: 3), now: _now);
      expect(draft.wizardStep, 3);
    });

    test('works on an event with nothing filled in', () {
      expect(() => asDraft(Event(eventId: 'd'), now: _now), returnsNormally);
    });
  });

  group('asPublished', () {
    test('publishes a complete event and counts its missions', () {
      final event = asPublished(_complete(), now: _now);
      expect(event.status, EventStatus.published);
      expect(event.updatedAt, _now);
      expect(event.nrMissions, 2);
    });

    test('an incomplete event is refused, with every problem listed', () {
      final event = _complete()..name = '';
      expect(
        () => asPublished(event, now: _now),
        throwsA(
          isA<EventNotPublishableException>().having(
            (e) => e.problems,
            'problems',
            contains('Lipsește numele evenimentului'),
          ),
        ),
      );
    });

    test('a refused event is left as it was', () {
      final event = _complete()
        ..name = ''
        ..updatedAt = null;
      try {
        asPublished(event, now: _now);
      } catch (_) {}
      expect(event.status, EventStatus.draft);
      expect(event.updatedAt, isNull);
    });

    test('an already published event can be saved again', () {
      final event = _complete()..status = EventStatus.published;
      expect(asPublished(event, now: _now).status, EventStatus.published);
    });
  });
}
