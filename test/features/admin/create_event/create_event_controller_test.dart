import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/event_status.dart';
import 'package:teamxperience/enums/event_type.dart';
import 'package:teamxperience/features/admin/create_event/create_event_landing/controller/create_event_controller.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/event_defaults.dart';
import 'package:teamxperience/model/mission.dart';

final _day = DateTime(2026, 10, 25, 14);
final _opens = DateTime(2026, 10, 1);
final _closes = DateTime(2026, 10, 24);

Event _draft() => Event(
      eventId: 'd1',
      name: 'Treasure Hunt Brașov',
      status: EventStatus.draft,
      wizardStep: 1,
      missions: [Mission(id: '0')],
    );

void main() {
  group('opening the form', () {
    test('an event with no name does not crash it', () {
      final c = CreateEventController(Event(eventId: 'x', status: EventStatus.draft));
      expect(c.nameController.text, '');
    });

    test('a draft fills in what it has and leaves the rest empty', () {
      final c = CreateEventController(_draft());
      expect(c.nameController.text, 'Treasure Hunt Brașov');
      expect(c.locationController.text, '');
      expect(c.selectedType, isNull);
      expect(c.dateEvent, isNull);
      expect(c.dateEventController.text, '');
    });

    test('defaults are loaded into the look fields', () {
      final event = _draft()
        ..defaults = const EventDefaults(
          backgroundColor: '#050805',
          accentColor: '#33FF66',
          fontFamily: 'Monospace',
        );
      final c = CreateEventController(event);
      expect(c.backgroundColor, '#050805');
      expect(c.accentColor, '#33FF66');
      expect(c.fontFamily, 'Monospace');
    });
  });

  group('buildNewEvent', () {
    test('an empty form builds an event without crashing', () {
      final event = CreateEventController(null).buildNewEvent();
      expect(event.eventId, '');
      expect(event.name, '');
      expect(event.type, isNull);
      expect(event.dateEvent, isNull);
      expect(event.landingImageUrl, isNull);
      expect(event.taskBackgroundImageUrl, isNull);
      expect(event.defaults, isNull);
    });

    test('takes the text, dates, type and look from the form', () {
      final c = CreateEventController(null)
        ..nameController.text = '  Xtreme  '
        ..locationController.text = 'Sibiu'
        ..descriptionController.text = 'Un joc'
        ..punctDeStartController.text = 'Piața Mare'
        ..startCodeController.text = 'XTREME'
        ..lungimeController.text = '4 km'
        ..durataController.text = '2 ore'
        ..dificultateController.text = 'Medie'
        ..selectedType = EventType.PRIVAT
        ..dateEvent = _day
        ..dateStartEnrollement = _opens
        ..deadlineEnrollment = _closes
        ..landingImageFile = File('/tmp/cover.jpg')
        ..accentColor = '#2AA5A9'
        ..fontFamily = 'Poppins';

      final event = c.buildNewEvent();

      expect(event.name, 'Xtreme', reason: 'trimmed');
      expect(event.location, 'Sibiu');
      expect(event.type, EventType.PRIVAT);
      expect(event.dateEvent, _day);
      expect(event.dateStartEnrollment, _opens);
      expect(event.dateDeadlineEnrollment, _closes);
      expect(event.landingImageUrl, '/tmp/cover.jpg');
      expect(event.taskBackgroundImageUrl, isNull);
      expect(event.defaults?.accentColor, '#2AA5A9');
      expect(event.defaults?.fontFamily, 'Poppins');
      expect(event.defaults?.backgroundColor, isNull);
    });

    test('starts with one empty mission, or reuses the missions of the one it was copied from', () {
      expect(CreateEventController(null).buildNewEvent().missions, hasLength(1));

      final source = Event(eventId: 's', name: 'Vechi', missions: [Mission(id: '0'), Mission(id: '1')]);
      final copy = CreateEventController(source).buildNewEvent();
      expect(copy.missions, hasLength(2));
      expect(copy.nrMissions, 2);
      expect(copy.eventId, '');
    });
  });

  group('applyToOriginal', () {
    test('updates the existing event and keeps what the form does not touch', () {
      final original = _draft()
        ..isStopped = false
        ..landingImageUrl = 'https://example.com/cover.jpg';
      final c = CreateEventController(original)
        ..nameController.text = 'Redenumit'
        ..locationController.text = 'Brașov';

      final event = c.applyToOriginal();

      expect(identical(event, original), isTrue);
      expect(event.eventId, 'd1');
      expect(event.name, 'Redenumit');
      expect(event.location, 'Brașov');
      expect(event.status, EventStatus.draft);
      expect(event.missions, hasLength(1));
      expect(event.landingImageUrl, 'https://example.com/cover.jpg');
    });

    test('works with a half filled form', () {
      final c = CreateEventController(_draft());
      expect(() => c.applyToOriginal(), returnsNormally);
    });
  });

  group('saving a draft', () {
    test('needs a name, so the card on the Home has a title', () {
      expect(CreateEventController(null).canSaveDraft, isFalse);
      final c = CreateEventController(null)..nameController.text = '   ';
      expect(c.canSaveDraft, isFalse);
      c.nameController.text = 'Ceva';
      expect(c.canSaveDraft, isTrue);
    });
  });

  group('enrollmentProblem', () {
    test('is fine when the dates are in order, or not all set yet', () {
      final c = CreateEventController(null);
      expect(c.enrollmentProblem(), isNull);
      c
        ..dateEvent = _day
        ..dateStartEnrollement = _opens
        ..deadlineEnrollment = _closes;
      expect(c.enrollmentProblem(), isNull);
    });

    test('says when enrolment closes after the event', () {
      final c = CreateEventController(null)
        ..dateEvent = _day
        ..dateStartEnrollement = _opens
        ..deadlineEnrollment = DateTime(2026, 10, 26);
      expect(c.enrollmentProblem(), 'Înscrierile trebuie să se închidă înainte de eveniment');
    });

    test('says when enrolment opens after it closes', () {
      final c = CreateEventController(null)
        ..dateEvent = _day
        ..dateStartEnrollement = DateTime(2026, 10, 25)
        ..deadlineEnrollment = _closes;
      expect(c.enrollmentProblem(), 'Înscrierile se deschid după ce se închid');
    });
  });
}
