import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/event_status.dart';
import 'package:teamxperience/enums/event_type.dart';
import 'package:teamxperience/enums/screen_animation.dart';
import 'package:teamxperience/features/admin/create_event/create_event_landing/controller/create_event_controller.dart';
import 'package:teamxperience/model/event.dart';
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
  imageTests();
  animationTests();
  group('opening the form', () {
    test('an event with no name does not crash it', () {
      final c = CreateEventController(
        Event(eventId: 'x', status: EventStatus.draft),
      );
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

    test('takes the text, dates, type and images from the form', () {
      final c =
          CreateEventController(null)
            ..nameController.text = '  Xtreme  '
            ..locationController.text = 'Sibiu'
            ..descriptionController.text = 'Un joc'
            ..punctDeStartController.text = 'Piața Mare'
            ..startCodeController.text = 'XTREME'
            ..routeKmController.text = '4'
            ..durationController.text = '120'
            ..selectedType = EventType.PRIVAT
            ..dateEvent = _day
            ..dateStartEnrollement = _opens
            ..deadlineEnrollment = _closes
            ..landingImageFile = File('/tmp/cover.jpg');

      final event = c.buildNewEvent();

      expect(event.name, 'Xtreme', reason: 'trimmed');
      expect(event.location, 'Sibiu');
      expect(event.type, EventType.PRIVAT);
      expect(event.dateEvent, _day);
      expect(event.dateStartEnrollment, _opens);
      expect(event.dateDeadlineEnrollment, _closes);
      expect(event.landingImageUrl, '/tmp/cover.jpg');
      expect(event.taskBackgroundImageUrl, isNull);
    });

    test(
      'starts with one empty mission, or reuses the missions of the one it was copied from',
      () {
        expect(
          CreateEventController(null).buildNewEvent().missions,
          hasLength(1),
        );

        final source = Event(
          eventId: 's',
          name: 'Vechi',
          missions: [Mission(id: '0'), Mission(id: '1')],
        );
        final copy = CreateEventController(source).buildNewEvent();
        expect(copy.missions, hasLength(2));
        expect(copy.nrMissions, 2);
        expect(copy.eventId, '');
      },
    );
  });

  group('applyToOriginal', () {
    test(
      'updates the existing event and keeps what the form does not touch',
      () {
        final original =
            _draft()
              ..isStopped = false
              ..landingImageUrl = 'https://example.com/cover.jpg';
        final c =
            CreateEventController(original)
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
      },
    );

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
      final c =
          CreateEventController(null)
            ..dateEvent = _day
            ..dateStartEnrollement = _opens
            ..deadlineEnrollment = DateTime(2026, 10, 26);
      expect(
        c.enrollmentProblem(),
        'Înscrierile trebuie să se închidă înainte de eveniment',
      );
    });

    test('says when enrolment opens after it closes', () {
      final c =
          CreateEventController(null)
            ..dateEvent = _day
            ..dateStartEnrollement = DateTime(2026, 10, 25)
            ..deadlineEnrollment = _closes;
      expect(c.enrollmentProblem(), 'Înscrierile se deschid după ce se închid');
    });
  });
}

void animationTests() {
  group('the animation of the screen', () {
    test('a new form fades, as events always did', () {
      expect(CreateEventController(null).screenAnimation, ScreenAnimation.fade);
      expect(CreateEventController(null).buildNewEvent().screenAnimation, ScreenAnimation.fade);
    });

    test('an event that has none starts with none', () {
      final c = CreateEventController(Event(eventId: 'e', name: 'x', screenAnimation: ScreenAnimation.none));
      expect(c.screenAnimation, ScreenAnimation.none);
    });

    test('the choice goes onto a new event', () {
      final c = CreateEventController(null)..screenAnimation = ScreenAnimation.none;
      expect(c.buildNewEvent().screenAnimation, ScreenAnimation.none);
    });

    test('the choice goes onto the event being edited', () {
      final event = Event(eventId: 'e', name: 'x');
      final c = CreateEventController(event)..screenAnimation = ScreenAnimation.none;
      expect(c.applyToOriginal().screenAnimation, ScreenAnimation.none);
    });

    test('the timing starts as automatic', () {
      final c = CreateEventController(null);
      expect(c.animationDuration, isNull);
      expect(c.animationDelay, isNull);
      final event = c.buildNewEvent();
      expect(event.animationDuration, isNull);
      expect(event.animationDelay, isNull);
    });

    test('a chosen timing goes onto the event', () {
      final c = CreateEventController(null)
        ..screenAnimation = ScreenAnimation.zoom
        ..animationDuration = 900
        ..animationDelay = 100;
      final event = c.buildNewEvent();
      expect(event.screenAnimation, ScreenAnimation.zoom);
      expect(event.animationDuration, 900);
      expect(event.animationDelay, 100);
    });

    test('an event with a timing opens with it', () {
      final c = CreateEventController(Event(eventId: 'e', name: 'x', animationDuration: 500, animationDelay: 50));
      expect(c.animationDuration, 500);
      expect(c.animationDelay, 50);
    });

    test('a timing that was set back to automatic is removed from the event', () {
      final event = Event(eventId: 'e', name: 'x', animationDuration: 500, animationDelay: 50);
      final c = CreateEventController(event)
        ..animationDuration = null
        ..animationDelay = null;
      final saved = c.applyToOriginal();
      expect(saved.animationDuration, isNull);
      expect(saved.animationDelay, isNull);
    });

    test('a copy of an old event keeps its choice', () {
      final c = CreateEventController(Event(eventId: 'e', name: 'x', screenAnimation: ScreenAnimation.none));
      expect(c.buildNewEvent().screenAnimation, ScreenAnimation.none);
    });
  });
}

void imageTests() {
  group('the pictures of the event', () {
    Event withImages() => Event(
          eventId: 'e1',
          name: 'Hunt',
          landingImageUrl: 'https://example.com/cover.jpg',
          taskBackgroundImageUrl: 'assets/images/hacker_background.jpg',
          missions: [Mission(id: '0')],
        );

    test('continuing without picking new ones keeps the existing ones', () {
      final event = withImages();
      final saved = CreateEventController(event).applyToOriginal();
      expect(saved.landingImageUrl, 'https://example.com/cover.jpg');
      expect(saved.taskBackgroundImageUrl, 'assets/images/hacker_background.jpg');
    });

    test('a newly picked picture replaces the existing one', () {
      final c = CreateEventController(withImages())..landingImageFile = File('/tmp/new.jpg');
      final saved = c.applyToOriginal();
      expect(saved.landingImageUrl, '/tmp/new.jpg');
      expect(saved.taskBackgroundImageUrl, 'assets/images/hacker_background.jpg', reason: 'the other one is untouched');
    });

    test('a copy of an old event starts with its pictures, as the form shows them', () {
      final copy = CreateEventController(withImages()).buildNewEvent();
      expect(copy.eventId, '');
      expect(copy.landingImageUrl, 'https://example.com/cover.jpg');
      expect(copy.taskBackgroundImageUrl, 'assets/images/hacker_background.jpg');
    });

    test('a copy gets a picked picture instead of the old one', () {
      final c = CreateEventController(withImages())..taskBackgroundImageFile = File('/tmp/bg.jpg');
      expect(c.buildNewEvent().taskBackgroundImageUrl, '/tmp/bg.jpg');
    });

    test('an event without pictures stays without', () {
      final saved = CreateEventController(Event(eventId: 'e', name: 'x')).applyToOriginal();
      expect(saved.landingImageUrl, isNull);
      expect(saved.taskBackgroundImageUrl, isNull);
    });

    test('an empty form has no pictures', () {
      final event = CreateEventController(null).buildNewEvent();
      expect(event.landingImageUrl, isNull);
      expect(event.taskBackgroundImageUrl, isNull);
    });

    test('an empty text from an old database entry counts as no picture', () {
      final event = Event(eventId: 'e', name: 'x', landingImageUrl: '', taskBackgroundImageUrl: '');
      final saved = CreateEventController(event).applyToOriginal();
      expect(saved.landingImageUrl ?? '', isEmpty);
    });
  });
}
