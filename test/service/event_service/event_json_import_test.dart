import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/enums/event_type.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/features/admin/create_event/start/event_json_sample.dart';
import 'package:teamxperience/service/event_service/event_completeness.dart';
import 'package:teamxperience/service/event_service/event_json_import.dart';

Map<String, dynamic> _event({
  Map<String, dynamic>? extra,
  List<dynamic>? missions,
}) => {
  'name': 'Treasure Hunt Sibiu',
  'type': 'PUBLIC',
  'dateEvent': '2026-11-20T18:00:00',
  'missions': missions ??
      [
        {
          'puzzles': [
            {
              'type': 'code',
              'code': 'SIBIU',
              'components': [
                {'type': 'text', 'text': 'Salut', 'fontSize': 18},
              ],
            },
          ],
        },
      ],
  ...?extra,
};

EventImportResult _import(Object? json) => importEventFromJson(jsonEncode(json));

void main() {
  group('a good event', () {
    test('is read into an event', () {
      final result = _import(_event(extra: {'location': 'Sibiu', 'startCode': 'GO'}));
      expect(result.errors, isEmpty);
      final event = result.event;
      expect(event, isNotNull);
      expect(event?.name, 'Treasure Hunt Sibiu');
      expect(event?.location, 'Sibiu');
      expect(event?.type, EventType.PUBLIC);
      expect(event?.startCode, 'GO');
    });

    test('dates written as text become dates', () {
      final event = _import(
        _event(extra: {
          'dateStartEnrollment': '2026-11-01T09:00',
          'dateDeadlineEnrollment': '2026-11-19T23:59:00',
        }),
      ).event;
      expect(event?.dateEvent, DateTime(2026, 11, 20, 18));
      expect(event?.dateStartEnrollment, DateTime(2026, 11, 1, 9));
      expect(event?.dateDeadlineEnrollment, DateTime(2026, 11, 19, 23, 59));
    });

    test('missions and puzzles are numbered by their place, whatever the file says', () {
      final event = _import(
        _event(missions: [
          {'id': '9', 'puzzles': [{'id': '7', 'type': 'code', 'components': []}, {'type': 'code', 'components': []}]},
          {'puzzles': []},
        ]),
      ).event;
      expect(event?.missions.map((m) => m.id), ['0', '1']);
      expect(event?.missions.first.puzzles.map((p) => p.id), ['0', '1']);
      expect(event?.nrMissions, 2);
    });

    test('whole numbers are accepted where a decimal is expected', () {
      final event = _import(
        _event(missions: [
          {
            'puzzles': [
              {
                'type': 'geolocation',
                'latitude': 45,
                'longitude': 24,
                'components': [
                  {'type': 'text', 'text': 'x', 'fontSize': 18, 'cornerRadius': 8, 'width': 200, 'height': 40},
                  {'type': 'code', 'codeLength': 4, 'frameCornerRadius': 12, 'inputCornerRadius': 6},
                ],
              },
            ],
          },
        ]),
      ).event;
      final puzzle = event?.missions.single.puzzles.single;
      expect(puzzle?.latitude, 45.0);
      expect(puzzle?.components.first.fontSize, 18.0);
      expect(puzzle?.components.first.width, 200.0);
      expect(puzzle?.components.last.codeLength, 4);
      expect(puzzle?.components.last.frameCornerRadius, 12.0);
    });

    test('puzzle and component types are read', () {
      final puzzle = _import(_event()).event?.missions.single.puzzles.single;
      expect(puzzle?.type, PuzzleType.code);
      expect(puzzle?.components.single.type, ComponentType.text);
    });

    test('what the file says about id, status and being stopped is ignored', () {
      final event = _import(_event(extra: {'eventId': 'abc', 'status': 'published', 'isStopped': true})).event;
      expect(event?.eventId, '');
      expect(event?.isStopped, isFalse);
      expect(event?.isDraft, isFalse, reason: 'saving it as a draft sets the status');
    });

    test('keys it does not know are ignored', () {
      expect(_import(_event(extra: {'something': 1})).errors, isEmpty);
    });

    test('an event with nothing but a name can be imported, to be finished in the app', () {
      final result = _import({'name': 'Doar un nume'});
      expect(result.errors, isEmpty);
      expect(result.event?.missions, isEmpty);
    });
  });

  group('the sample', () {
    test('imports without errors', () {
      final result = importEventFromJson(eventJsonSample);
      expect(result.errors, isEmpty);
    });

    test('is a complete event that could be published', () {
      final event = importEventFromJson(eventJsonSample).event;
      expect(event, isNotNull);
      if (event != null) {
        expect(publishProblems(event).map((p) => p.text), isEmpty);
      }
    });

    test('is the same as the example file in docs', () {
      final file = File('docs/event-import-sample.json').readAsStringSync();
      expect(file.replaceAll('\r\n', '\n'), eventJsonSample);
    });

    test('shows each puzzle type', () {
      final event = importEventFromJson(eventJsonSample).event;
      final types = event?.missions.expand((m) => m.puzzles).map((p) => p.type).toSet();
      expect(types, containsAll([PuzzleType.code, PuzzleType.geolocation, PuzzleType.imageToUpload]));
    });
  });

  group('mistakes are explained', () {
    test('text that is not JSON', () {
      final result = importEventFromJson('{ nu e json');
      expect(result.event, isNull);
      expect(result.errors.single, contains('JSON'));
    });

    test('empty text', () {
      expect(importEventFromJson('   ').errors, isNotEmpty);
    });

    test('JSON that is not an object', () {
      expect(_import([1, 2]).errors.single, contains('obiect'));
    });

    test('an unknown event type lists the ones that exist', () {
      final result = _import(_event(extra: {'type': 'SECRET'}));
      expect(result.event, isNull);
      expect(result.errors.single, allOf(contains('type'), contains('SECRET'), contains('PUBLIC'), contains('PRIVAT')));
    });

    test('an unknown puzzle type says where it is', () {
      final result = _import(
        _event(missions: [
          {'puzzles': [{'type': 'code', 'components': []}, {'type': 'quiz', 'components': []}]},
        ]),
      );
      expect(result.errors.single, allOf(contains('Misiunea 1'), contains('puzzle 2'), contains('quiz')));
    });

    test('an unknown component type says where it is', () {
      final result = _import(
        _event(missions: [
          {'puzzles': [{'type': 'code', 'components': [{'type': 'text'}, {'type': 'video'}]}]},
        ]),
      );
      expect(result.errors.single, allOf(contains('Misiunea 1'), contains('puzzle 1'), contains('componenta 2'), contains('video')));
    });

    test('a component without a type', () {
      final result = _import(
        _event(missions: [
          {'puzzles': [{'type': 'code', 'components': [{'text': 'fără tip'}]}]},
        ]),
      );
      expect(result.errors.single, allOf(contains('componenta 1'), contains('type')));
    });

    test('a date that is not a date', () {
      final result = _import(_event(extra: {'dateEvent': 'mâine seara'}));
      expect(result.errors.single, allOf(contains('dateEvent'), contains('2026-')));
    });

    test('a field with the wrong kind of value', () {
      final result = _import(_event(extra: {'name': 5}));
      expect(result.errors.single, contains('name'));
    });

    test('missions that are not a list', () {
      expect(_import(_event(extra: {'missions': 'două'})).errors.single, contains('missions'));
    });

    test('a number where text is expected inside a component', () {
      final result = _import(
        _event(missions: [
          {'puzzles': [{'type': 'code', 'components': [{'type': 'text', 'text': 12}]}]},
        ]),
      );
      expect(result.errors.single, contains('componenta 1'));
    });

    test('several mistakes are all reported, not only the first', () {
      final result = _import(
        _event(extra: {'type': 'SECRET', 'dateEvent': 'nu'}),
      );
      expect(result.errors.length, 2);
    });

    test('a file with mistakes gives no event', () {
      expect(_import(_event(extra: {'type': 'SECRET'})).event, isNull);
    });
  });
}
