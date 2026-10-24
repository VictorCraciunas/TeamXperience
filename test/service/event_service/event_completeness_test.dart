import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/enums/event_status.dart';
import 'package:teamxperience/enums/event_type.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/service/event_service/event_completeness.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/puzzle.dart';

Component _text() => Component(type: ComponentType.text, text: 'Ghicitoare');

Puzzle _codePuzzle({String? code = 'ceas', bool withComponent = true}) => Puzzle(
      id: 'p',
      type: PuzzleType.code,
      code: code,
      components: [if (withComponent) _text()],
    );

Puzzle _geoPuzzle({double? lat = 45.79, double? lng = 24.15}) => Puzzle(
      id: 'g',
      type: PuzzleType.geolocation,
      latitude: lat,
      longitude: lng,
      components: [_text()],
    );

Mission _mission(List<Puzzle> puzzles) => Mission(id: '0', puzzles: puzzles);

final _start = DateTime(2026, 10, 1);
final _deadline = DateTime(2026, 10, 24);
final _day = DateTime(2026, 10, 25, 14);

Event _event({List<Mission>? missions}) => Event(
      eventId: 'e',
      name: 'Xtreme',
      description: 'Un joc',
      location: 'Sibiu',
      punctDeStart: 'Piața Mare',
      dateEvent: _day,
      dateStartEnrollment: _start,
      dateDeadlineEnrollment: _deadline,
      type: EventType.PUBLIC,
      startCode: 'XTREME',
      lungimeTraseu: '4 km',
      durata: '2 ore',
      dificultate: 'Medie',
      missions: missions ?? [_mission([_codePuzzle()])],
    );

void main() {
  group('puzzleIssues', () {
    test('a complete code puzzle has none', () {
      expect(puzzleIssues(_codePuzzle()), isEmpty);
    });

    test('a puzzle without a type is missing its type', () {
      expect(puzzleIssues(Puzzle(id: 'x', components: [_text()])), [PuzzleIssue.noType]);
    });

    test('a code puzzle needs an answer, not just spaces', () {
      expect(puzzleIssues(_codePuzzle(code: null)), [PuzzleIssue.noAnswer]);
      expect(puzzleIssues(_codePuzzle(code: '  ')), [PuzzleIssue.noAnswer]);
    });

    test('a location puzzle needs both coordinates, inside the valid ranges', () {
      expect(puzzleIssues(_geoPuzzle()), isEmpty);
      expect(puzzleIssues(_geoPuzzle(lat: null)), [PuzzleIssue.noLocation]);
      expect(puzzleIssues(_geoPuzzle(lng: null)), [PuzzleIssue.noLocation]);
      expect(puzzleIssues(_geoPuzzle(lat: 95)), [PuzzleIssue.noLocation]);
      expect(puzzleIssues(_geoPuzzle(lng: -200)), [PuzzleIssue.noLocation]);
    });

    test('a puzzle with nothing on its screen is empty', () {
      expect(puzzleIssues(_codePuzzle(withComponent: false)), [PuzzleIssue.noComponents]);
    });

    test('a photo puzzle needs no answer', () {
      final puzzle = Puzzle(id: 'f', type: PuzzleType.imageToUpload, components: [_text()]);
      expect(puzzleIssues(puzzle), isEmpty);
    });

    test('the hint is optional', () {
      expect(puzzleIssues(_codePuzzle()..indiciu = null), isEmpty);
    });
  });

  group('missionProblems', () {
    test('a mission with no puzzles says so', () {
      final problems = missionProblems(_mission([]));
      expect(problems.single.text, 'Nu are puzzle-uri');
      expect(problems.single.puzzleIndex, isNull);
    });

    test('names the puzzle and what is missing', () {
      final problems = missionProblems(_mission([_codePuzzle(), _codePuzzle(code: null)]));
      expect(problems.single.text, 'Puzzle 2: lipsește răspunsul');
      expect(problems.single.puzzleIndex, 1);
    });

    test('a complete mission has no problems and is complete', () {
      final mission = _mission([_codePuzzle(), _geoPuzzle()]);
      expect(missionProblems(mission), isEmpty);
      expect(isMissionComplete(mission), isTrue);
    });
  });

  group('eventIssues', () {
    test('a complete event has none', () {
      expect(eventIssues(_event()), isEmpty);
    });

    test('lists what is missing from the details', () {
      final bare = Event(eventId: 'd', status: _draft);
      final issues = eventIssues(bare);
      expect(issues, containsAll([
        EventIssue.noName,
        EventIssue.noDescription,
        EventIssue.noLocation,
        EventIssue.noStartPoint,
        EventIssue.noDate,
        EventIssue.noEnrollmentDates,
        EventIssue.noType,
        EventIssue.noStartCode,
        EventIssue.noRoute,
        EventIssue.noDuration,
        EventIssue.noDifficulty,
        EventIssue.noMissions,
      ]));
    });

    test('enrolment must close before the event and open before it closes', () {
      final late = _event()..dateDeadlineEnrollment = DateTime(2026, 10, 26);
      expect(eventIssues(late), [EventIssue.enrollmentAfterEvent]);

      final backwards = _event()..dateStartEnrollment = DateTime(2026, 10, 25);
      expect(eventIssues(backwards), [EventIssue.enrollmentOrder]);
    });

    test('images are optional', () {
      final event = _event()
        ..landingImageUrl = null
        ..taskBackgroundImageUrl = null;
      expect(eventIssues(event), isEmpty);
    });

    test('every issue has a label to show', () {
      for (final issue in EventIssue.values) {
        expect(issue.label, isNotEmpty);
      }
    });
  });

  group('publishProblems', () {
    test('event details come first, then each mission', () {
      final event = _event(missions: [
        _mission([_codePuzzle()]),
        _mission([_codePuzzle(code: null)]),
      ])
        ..name = '';
      final problems = publishProblems(event);
      expect(problems.first.text, EventIssue.noName.label);
      expect(problems.first.missionIndex, isNull);
      expect(problems.last.text, 'Misiunea 2: Puzzle 1: lipsește răspunsul');
      expect(problems.last.missionIndex, 1);
    });

    test('canPublish is true only when nothing is missing', () {
      expect(canPublish(_event()), isTrue);
      expect(canPublish(_event(missions: [_mission([])])), isFalse);
      expect(canPublish(_event()..startCode = ''), isFalse);
    });
  });
}

// Imported lazily to keep the test list above readable.
const _draft = EventStatus.draft;
