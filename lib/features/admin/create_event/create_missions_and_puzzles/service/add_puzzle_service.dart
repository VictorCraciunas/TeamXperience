import 'package:teamxperience/model/puzzle.dart';

class AddPuzzleService{
  Map<String, Puzzle> puzzles = {};

  Map<String, Puzzle> initializePuzzles(int nrPuzzles, int curMission){
    puzzles.clear();

    for (int i = 0; i < nrPuzzles; i++) {
      final letter = String.fromCharCode('a'.codeUnitAt(0) + i);
      final id = '$curMission$letter';

      puzzles[id] = Puzzle(id: id);

    }

    return puzzles;
  }
}