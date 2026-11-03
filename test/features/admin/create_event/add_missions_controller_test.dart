import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/component-type.dart';
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
  reorderTests();
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

    test('titles and teasers survive removing a mission', () {
      final c = AddMissionsController(
        _event([Mission(id: '0', title: 'A'), Mission(id: '1', title: 'B', teaser: 'b', isTeaserPublic: true)]),
        'create',
      );
      c.removeMission(0);
      final m = c.event.missions.single;
      expect((m.id, m.title, m.teaser, m.isTeaserPublic), ('0', 'B', 'b', true));
    });

    test('titles and teasers survive moving a mission', () {
      final c = AddMissionsController(
        _event([Mission(id: '0', title: 'A', teaser: 'a'), Mission(id: '1', title: 'B')]),
        'create',
      );
      c.moveMission(0, 1);
      expect(c.event.missions.map((m) => (m.id, m.title, m.teaser)), [('0', 'B', null), ('1', 'A', 'a')]);
    });

    test('a copy of an old event keeps the mission titles and teasers', () {
      final c = AddMissionsController(
        _event([Mission(id: '0', title: 'A', teaser: 'a', isTeaserPublic: true)]),
        'blueprint',
      );
      final m = c.event.missions.single;
      expect((m.title, m.teaser, m.isTeaserPublic), ('A', 'a', true));
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
    test('keeps the missions and the puzzle types but clears answers, places and hints', () {
      final source = Mission(id: '0', puzzles: [_puzzle('0', type: PuzzleType.code, code: 'A')..latitude = 45..longitude = 24]);
      final c = AddMissionsController(_event([source]), 'blueprint');
      final puzzle = c.event.missions.single.puzzles.single;
      expect(puzzle.type, PuzzleType.code);
      expect(puzzle.code, isNull);
      expect(puzzle.latitude, isNull);
      expect(puzzle.longitude, isNull);
      expect(puzzle.indiciu, isNull);
    });

    test('keeps what is on the screen of each puzzle', () {
      final source = Mission(id: '0', puzzles: [_puzzle('0', type: PuzzleType.code, code: 'A')..components.add(Component(type: ComponentType.text, text: 'Salut'))]);
      final c = AddMissionsController(_event([source]), 'blueprint');
      expect(c.event.missions.single.puzzles.single.components.single.text, 'Salut');
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

void reorderTests() {
  group('reordering', () {
    Mission mission(String id, List<String> puzzleCodes) => Mission(
          id: id,
          puzzles: [
            for (var i = 0; i < puzzleCodes.length; i++)
              _puzzle('$i', type: PuzzleType.code, code: puzzleCodes[i]),
          ],
        );

    AddMissionsController build() => AddMissionsController(
          _event([mission('0', ['a1', 'a2']), mission('1', ['b1']), mission('2', ['c1', 'c2', 'c3'])]),
          'create',
        );

    List<String?> firstCodes(AddMissionsController c) =>
        c.event.missions.map((m) => m.puzzles.first.code).toList();

    test('a mission moves to its new place and everything is numbered again', () {
      final c = build();
      c.moveMission(2, 0);
      expect(firstCodes(c), ['c1', 'a1', 'b1']);
      expect(c.event.missions.map((m) => m.id), ['0', '1', '2']);
    });

    test('a mission can move down', () {
      final c = build();
      c.moveMission(0, 2);
      expect(firstCodes(c), ['b1', 'c1', 'a1']);
    });

    test('puzzles go with their mission', () {
      final c = build();
      c.moveMission(0, 1);
      expect(c.event.missions[1].puzzles.map((p) => p.code), ['a1', 'a2']);
    });

    test('moving to the same place or out of range changes nothing', () {
      final c = build();
      c.moveMission(1, 1);
      c.moveMission(-1, 0);
      c.moveMission(0, 7);
      c.moveMission(9, 0);
      expect(firstCodes(c), ['a1', 'b1', 'c1']);
    });

    test('a puzzle moves inside its mission and is numbered again', () {
      final c = build();
      c.movePuzzle(2, 2, 0);
      final puzzles = c.event.missions[2].puzzles;
      expect(puzzles.map((p) => p.code), ['c3', 'c1', 'c2']);
      expect(puzzles.map((p) => p.id), ['0', '1', '2']);
    });

    test('moving a puzzle does not touch the other missions', () {
      final c = build();
      c.movePuzzle(2, 0, 2);
      expect(c.event.missions[0].puzzles.map((p) => p.code), ['a1', 'a2']);
      expect(c.event.missions[1].puzzles.map((p) => p.code), ['b1']);
    });

    test('a puzzle that does not exist or a bad mission changes nothing', () {
      final c = build();
      c.movePuzzle(2, 5, 0);
      c.movePuzzle(2, 0, 5);
      c.movePuzzle(9, 0, 1);
      expect(c.event.missions[2].puzzles.map((p) => p.code), ['c1', 'c2', 'c3']);
    });

    test('the screen is told about a move', () {
      var told = 0;
      final c = AddMissionsController(
        _event([mission('0', ['a']), mission('1', ['b'])]),
        'create',
        onStateChanged: () => told++,
      );
      c.moveMission(0, 1);
      expect(told, 1);
    });
  });
}
