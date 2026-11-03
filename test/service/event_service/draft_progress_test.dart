import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/enums/event_status.dart';
import 'package:teamxperience/enums/event_type.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/puzzle.dart';
import 'package:teamxperience/service/event_service/event_completeness.dart';

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
      ],
    );

void main() {
  group('draftProgress', () {
    test('an empty draft is at the start', () {
      expect(draftProgress(Event(eventId: 'd', status: EventStatus.draft)), 0);
    });

    test('a complete one is at the end', () {
      expect(draftProgress(_complete()), 1);
    });

    test('more filled in means further along, never outside 0 to 1', () {
      final one = Event(eventId: 'd', name: 'Doar numele', status: EventStatus.draft);
      final more = Event(
        eventId: 'd',
        name: 'Doar numele',
        location: 'Sibiu',
        description: 'Descriere',
        status: EventStatus.draft,
      );
      expect(draftProgress(one), greaterThan(0));
      expect(draftProgress(more), greaterThan(draftProgress(one)));
      expect(draftProgress(more), lessThan(1));
    });

    test('a broken mission holds it back from the end', () {
      final event = _complete()..missions.first.puzzles.first.code = '';
      final progress = draftProgress(event);
      expect(progress, lessThan(1));
      expect(progress, greaterThan(0.9));
    });
  });

  group('draftSummary', () {
    test('says what to do first', () {
      final draft = Event(eventId: 'd', status: EventStatus.draft);
      expect(draftSummary(draft), EventIssue.noName.label);
    });

    test('points at the first missing detail, not the last', () {
      final draft = Event(eventId: 'd', name: 'Nume', status: EventStatus.draft);
      expect(draftSummary(draft), EventIssue.noDescription.label);
    });

    test('mentions how many more things are missing', () {
      final draft = Event(eventId: 'd', status: EventStatus.draft);
      expect(draftSummary(draft, withCount: true), contains('încă'));
    });

    test('a complete draft is ready to publish', () {
      expect(draftSummary(_complete()), 'Gata de publicat');
    });
  });
}
