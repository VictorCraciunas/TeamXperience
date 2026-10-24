import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/event_status.dart';
import 'package:teamxperience/enums/event_type.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/event_defaults.dart';

Map<String, dynamic> _publishedDoc() => {
      'eventId': 'e1',
      'name': 'Xtreme',
      'missions': <dynamic>[],
      'dateEvent': Timestamp.fromDate(DateTime(2026, 10, 25, 14)),
      'dateDeadlineEnrollment': Timestamp.fromDate(DateTime(2026, 10, 24)),
      'dateStartEnrollment': Timestamp.fromDate(DateTime(2026, 10, 1)),
      'location': 'Sibiu',
      'description': 'Joc',
      'nrMissions': 0,
      'type': 'PUBLIC',
      'startCode': 'XTREME',
      'isStopped': false,
    };

void main() {
  group('events saved before drafts existed', () {
    test('read as published, at step 0, without defaults or an edit time', () {
      final event = Event.fromMap(_publishedDoc());
      expect(event.status, EventStatus.published);
      expect(event.isDraft, isFalse);
      expect(event.wizardStep, 0);
      expect(event.defaults, isNull);
      expect(event.updatedAt, isNull);
      expect(event.type, EventType.PUBLIC);
    });
  });

  group('a draft saved half way', () {
    // Only the first wizard step was filled in.
    final doc = {
      'eventId': 'd1',
      'name': 'Treasure Hunt Brașov',
      'status': 'draft',
      'wizardStep': 1,
    };

    test('reads without a type, dates or location', () {
      final event = Event.fromMap(doc);
      expect(event.isDraft, isTrue);
      expect(event.name, 'Treasure Hunt Brașov');
      expect(event.type, isNull);
      expect(event.dateEvent, isNull);
      expect(event.dateStartEnrollment, isNull);
      expect(event.dateDeadlineEnrollment, isNull);
      expect(event.wizardStep, 1);
    });

    test('writes back without crashing and keeps its status', () {
      final json = Event.fromMap(doc).toJson();
      expect(json['status'], 'draft');
      expect(json['wizardStep'], 1);
      expect(json['type'], isNull);
      expect(json['dateEvent'], isNull);
    });

    test('a draft with nothing but an id still reads', () {
      final event = Event.fromMap({'eventId': 'x', 'status': 'draft'});
      expect(event.isDraft, isTrue);
      expect(event.name, '');
    });
  });

  group('new fields', () {
    test('status, step, edit time and defaults survive a round trip', () {
      final edited = DateTime(2026, 10, 20, 9, 30);
      final event = Event(
        eventId: 'e2',
        name: 'Cod Roșu',
        type: EventType.PRIVAT,
        status: EventStatus.draft,
        wizardStep: 3,
        updatedAt: edited,
        defaults: const EventDefaults(
          backgroundColor: '#050805',
          textColor: '#33FF66',
          accentColor: '#33FF66',
          fontFamily: 'Monospace',
        ),
      );

      final json = event.toJson();
      // Firestore stores dates as Timestamps.
      json['updatedAt'] = Timestamp.fromDate(edited);
      final back = Event.fromMap(json);

      expect(back.status, EventStatus.draft);
      expect(back.wizardStep, 3);
      expect(back.updatedAt, edited);
      expect(back.defaults?.backgroundColor, '#050805');
      expect(back.defaults?.fontFamily, 'Monospace');
      expect(back.type, EventType.PRIVAT);
    });

    test('an unknown status in the database reads as published', () {
      final doc = _publishedDoc()..['status'] = 'something-new';
      expect(Event.fromMap(doc).status, EventStatus.published);
    });

    test('a published event is not a draft', () {
      expect(Event(eventId: 'p').isDraft, isFalse);
    });
  });

  group('EventDefaults', () {
    test('an empty map gives no defaults', () {
      expect(EventDefaults.fromMap(null), isNull);
      expect(EventDefaults.fromMap(const {}), isNull);
    });

    test('keeps only what is set', () {
      final defaults = EventDefaults.fromMap({'accentColor': '#2AA5A9'});
      expect(defaults?.accentColor, '#2AA5A9');
      expect(defaults?.fontFamily, isNull);
      expect(defaults?.toJson(), {'accentColor': '#2AA5A9'});
    });
  });
}
