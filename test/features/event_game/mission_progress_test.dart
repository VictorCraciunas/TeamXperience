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
