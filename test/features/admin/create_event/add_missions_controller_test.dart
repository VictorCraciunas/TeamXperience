import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/controller/add_missions_controller.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/puzzle.dart';

Puzzle _puzzle(String id, {PuzzleType? type, String? code}) =>
    Puzzle(id: id, type: type, code: code, indiciu: 'hint');

Event _event(List<Mission> missions) =>
    Event(eventId: 'e1', name: 'Hunt', missions: missions)..nrMissions = missions.length;

void main() {
  puzzleTests();
  group('missions', () {
    test('adding a mission numbers it after the last one', () {
      final c = AddMissionsController(_event([Mission(id: '0')]), 'create');
      c.addNewMission();
      expect(c.event.missions.map((m) => m.id), ['0', '1']);
      expect(c.event.nrMissions, 2);
    });

    test('removing a mission renumbers the ones after it', () {
      final c = AddMissionsController(
        _event([Mission(id: '0'), Mission(id: '1'), Mission(id: '2')]),
        'create',
      );
      c.removeMission(0);
      expect(c.event.missions.map((m) => m.id), ['0', '1']);
      expect(c.event.nrMissions, 2);
    });

    test('removing an index that does not exist changes nothing', () {
      final c = AddMissionsController(_event([Mission(id: '0')]), 'create');
      c.removeMission(5);
      expect(c.event.missions, hasLength(1));
    });

    test('the last mission can be removed', () {
      final c = AddMissionsController(_event([Mission(id: '0')]), 'create');
      c.removeMission(0);
      expect(c.event.missions, isEmpty);
      expect(c.event.nrMissions, 0);
    });

    test('puzzles survive a renumber', () {
      final kept = Mission(id: '1', puzzles: [_puzzle('0', type: PuzzleType.code, code: 'A')]);
      final c = AddMissionsController(_event([Mission(id: '0'), kept]), 'create');
      c.removeMission(0);
      expect(c.event.missions.single.puzzles, hasLength(1));
      expect(c.event.missions.single.id, '0');
    });
  });

  group('status of a mission', () {
    test('a mission without puzzles says so', () {
      final c = AddMissionsController(_event([Mission(id: '0')]), 'create');
      expect(c.isDone(0), isFalse);
      expect(c.statusText(0), 'Nu are puzzle-uri');
    });

    test('a mission with a puzzle that has no type is not done', () {
      final c = AddMissionsController(
        _event([Mission(id: '0', puzzles: [_puzzle('0')])]),
        'create',
      );
      expect(c.isDone(0), isFalse);
    });

    test('an out of range index is not done and has no status', () {
      final c = AddMissionsController(_event([]), 'create');
      expect(c.isDone(3), isFalse);
      expect(c.statusText(3), '');
    });
  });

  group('copying an old event', () {
    test('clears the puzzle answers but keeps the missions', () {
      final source = Mission(id: '0', puzzles: [_puzzle('0', type: PuzzleType.code, code: 'A')]);
      final c = AddMissionsController(_event([source]), 'blueprint');
      final puzzle = c.event.missions.single.puzzles.single;
      expect(puzzle.type, isNull);
      expect(puzzle.code, isNull);
      expect(puzzle.indiciu, isNull);
    });

    test('does not change the event it was copied from', () {
      final source = Mission(id: '0', puzzles: [_puzzle('0', type: PuzzleType.code, code: 'A')]);
      AddMissionsController(_event([source]), 'blueprint');
      expect(source.puzzles.single.code, 'A');
      expect(source.puzzles.single.type, PuzzleType.code);
    });
  });
}

void puzzleTests() {
  group('puzzles', () {
    AddMissionsController build() => AddMissionsController(
          _event([Mission(id: '0', puzzles: [_puzzle('0', type: PuzzleType.code, code: 'A')])]),
          'create',
        );

    test('adding a puzzle gives it the chosen type and the next number', () {
      final c = build();
      final index = c.addPuzzle(0, PuzzleType.geolocation);
      expect(index, 1);
      final puzzles = c.event.missions[0].puzzles;
      expect(puzzles.map((p) => p.id), ['0', '1']);
      expect(puzzles[1].type, PuzzleType.geolocation);
    });

    test('adding to a mission that does not exist does nothing', () {
      final c = build();
      expect(c.addPuzzle(4, PuzzleType.code), -1);
    });

    test('removing a puzzle numbers the others again and keeps their data', () {
      final c = build();
      c.addPuzzle(0, PuzzleType.imageToUpload);
      c.removePuzzle(0, 0);
      final puzzles = c.event.missions[0].puzzles;
      expect(puzzles, hasLength(1));
      expect(puzzles.single.id, '0');
      expect(puzzles.single.type, PuzzleType.imageToUpload);
    });

    test('removing a puzzle that does not exist changes nothing', () {
      final c = build();
      c.removePuzzle(0, 7);
      c.removePuzzle(3, 0);
      expect(c.event.missions[0].puzzles, hasLength(1));
    });

    test('a new puzzle says what is missing', () {
      final c = build();
      c.addPuzzle(0, PuzzleType.code);
      expect(c.puzzleStatus(0, 1), 'Lipsește răspunsul · încă 1');
    });

    test('a puzzle with nothing missing is ready', () {
      final c = build();
      c.event.missions[0].puzzles[0].components.add(Component());
      expect(c.puzzleStatus(0, 0), 'Gata');
    });

    test('a puzzle that does not exist has no status', () {
      expect(build().puzzleStatus(0, 9), '');
      expect(build().puzzleStatus(5, 0), '');
    });
  });
}
