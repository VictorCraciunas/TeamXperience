import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/enums/difficulty.dart';
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

Mission _mission(List<Puzzle> puzzles) => Mission(id: '0', title: 'Ceasul', puzzles: puzzles);

final _start = DateTime(2026, 10, 1);
final _deadline = DateTime(2026, 10, 24);
final _day = DateTime(2026, 10, 25, 14);

Event _event({List<Mission>? missions}) => Event(
      eventId: 'e',
      name: 'Xtreme',
      description: 'Un joc',
      location: 'Sibiu',
      punctDeStart: 'Piața Mare',
      finishPoint: 'Turnul Sfatului',
      startLatitude: 45.79,
      startLongitude: 24.15,
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

  group('event page fields', () {
    test('an event with no start pin says so', () {
      expect(eventIssues(_event()..startLatitude = null), contains(EventIssue.noStartPin));
    });

    test('an event with no finish point says so', () {
      expect(eventIssues(_event()..finishPoint = ' '), contains(EventIssue.noFinishPoint));
    });

    test('route, duration and difficulty may come from the new fields or the old text', () {
      final numbers = _event()
        ..lungimeTraseu = ''
        ..durata = ''
        ..dificultate = ''
        ..routeLengthKm = 4
        ..durationMinutes = 90
        ..difficulty = Difficulty.easy;
      expect(eventIssues(numbers), isEmpty);
      final unreadable = _event()..lungimeTraseu = 'lung';
      expect(eventIssues(unreadable), [EventIssue.noRoute]);
    });

    test('a mission without a title says so first', () {
      final untitled = Mission(id: '0', puzzles: [_codePuzzle()]);
      expect(missionProblems(untitled).map((p) => p.text), ['Nu are titlu']);
      expect(missionProblems(Mission(id: '0')).map((p) => p.text), ['Nu are titlu', 'Nu are puzzle-uri']);
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

  group('an answer that does not fit its boxes', () {
    Puzzle boxes(String code, {int? length = 4, String? input = 'Separated'}) => Puzzle(
          id: 'p',
          type: PuzzleType.code,
          code: code,
          components: [Component(type: ComponentType.code, codeLength: length, inputType: input)],
        );

    test('longer than the boxes cannot be typed', () {
      expect(puzzleIssues(boxes('ABCDE')), [PuzzleIssue.answerDoesNotFit]);
    });

    test('as long as the boxes is fine, and so is shorter, since it can still be typed', () {
      expect(puzzleIssues(boxes('ABCD')), isEmpty);
      expect(puzzleIssues(boxes('ABC')), isEmpty);
    });

    test('spaces at the ends are not typed, so they do not count', () {
      expect(puzzleIssues(boxes(' ABCD ')), isEmpty);
    });

    test('no number of boxes means five', () {
      expect(puzzleIssues(boxes('ABCDE', length: null)), isEmpty);
      expect(puzzleIssues(boxes('ABCDEF', length: null)), [PuzzleIssue.answerDoesNotFit]);
    });

    test('one free box takes any length, also when the input type is left out', () {
      expect(puzzleIssues(boxes('ABCDEFGHIJKLMNOP', input: 'Free')), isEmpty);
      expect(puzzleIssues(boxes('ABCDEFGHIJKLMNOP', input: null)), isEmpty);
    });

    test('one box takes one whole character, whatever it is made of', () {
      expect(puzzleIssues(boxes('🔑🔑', length: 2)), isEmpty);
      expect(puzzleIssues(boxes('🔑🔑🔑', length: 2)), [PuzzleIssue.answerDoesNotFit]);
    });

    test('it is enough that one of two inputs fits', () {
      final puzzle = boxes('ABCDE')..components.add(Component(type: ComponentType.code, inputType: 'Free'));
      expect(puzzleIssues(puzzle), isEmpty);
    });

    test('a puzzle that is not a code puzzle is not checked', () {
      expect(puzzleIssues(boxes('ABCDE')..type = PuzzleType.imageToUpload), isEmpty);
    });

    test('stops the event from being published, and says where', () {
      final problems = publishProblems(_event(missions: [_mission([boxes('ABCDE')])]));
      expect(problems.map((p) => p.text), ['Misiunea 1: Puzzle 1: răspunsul nu încape în căsuțe']);
    });
  });

  group('stuckProblems, what would leave teams stuck on a live event', () {
    Puzzle boxes(String code) => Puzzle(
          id: 'p',
          type: PuzzleType.code,
          code: code,
          components: [Component(type: ComponentType.code, codeLength: 4, inputType: 'Separated')],
        );

    test('a playable event has none, even with newer details missing', () {
      final event = _event(missions: [_mission([boxes('ABCD')])])
        ..finishPoint = null
        ..startLatitude = null;
      expect(stuckProblems(event), isEmpty);
    });

    test('says which mission and puzzle has an answer that does not fit', () {
      final event = _event(missions: [
        _mission([boxes('ABCD')]),
        _mission([boxes('ABCD'), boxes('ABCDE')]),
      ]);
      final problems = stuckProblems(event);
      expect(problems.map((p) => p.text), ['Misiunea 2: Puzzle 2: răspunsul nu încape în căsuțe']);
      expect(problems.single.missionIndex, 1);
    });

    test('team sizes the wrong way round', () {
      final event = _event()
        ..teamSizeMin = 6
        ..teamSizeMax = 2;
      expect(stuckProblems(event).map((p) => p.text), [EventIssue.teamSizeOrder.label]);
    });
  });

  group('team sizes', () {
    test('a minimum above the maximum stops the event from being published', () {
      final event = _event()
        ..teamSizeMin = 6
        ..teamSizeMax = 2;
      expect(eventIssues(event), [EventIssue.teamSizeOrder]);
    });

    test('the same minimum and maximum is fine', () {
      final event = _event()
        ..teamSizeMin = 4
        ..teamSizeMax = 4;
      expect(eventIssues(event), isEmpty);
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
