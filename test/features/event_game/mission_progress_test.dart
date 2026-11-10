import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/event_game/logic/mission_progress.dart';

void main() {
  group('solvedMission', () {
    test('the first phone to solve a mission moves the team on and stamps it', () {
      expect(solvedMission(3, 3), (progress: 4, stamp: 3));
      expect(solvedMission(0, 0), (progress: 1, stamp: 0));
    });

    test('a teammate already ahead: the progress stays and nothing is re-stamped', () {
      expect(solvedMission(3, 5), (progress: 5, stamp: null));
      expect(solvedMission(3, 4), (progress: 4, stamp: null));
    });
  });

  group('mergeProgress', () {
    test('a teammate a mission ahead: take their mission and their puzzle', () {
      expect(mergeProgress(mission: 3, puzzle: 3, freshMission: 4, freshPuzzle: 0), (mission: 4, puzzle: 0));
    });

    test('same mission: the furthest puzzle', () {
      expect(mergeProgress(mission: 3, puzzle: 1, freshMission: 3, freshPuzzle: 2), (mission: 3, puzzle: 2));
      expect(mergeProgress(mission: 3, puzzle: 2, freshMission: 3, freshPuzzle: 1), (mission: 3, puzzle: 2));
    });

    test('a stale copy behind us changes nothing', () {
      expect(mergeProgress(mission: 4, puzzle: 0, freshMission: 3, freshPuzzle: 3), (mission: 4, puzzle: 0));
    });
  });

  group('nextPuzzleNumber', () {
    test('on the stored mission, never below what a teammate reached', () {
      expect(nextPuzzleNumber(0, 2, sameMission: true), 2);
      expect(nextPuzzleNumber(2, 1, sameMission: true), 3);
    });

    test('on another mission, just the next puzzle', () {
      expect(nextPuzzleNumber(0, 2, sameMission: false), 1);
    });
  });
}
