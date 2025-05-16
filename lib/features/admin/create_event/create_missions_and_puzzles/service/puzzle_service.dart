import 'package:teamxperience/model/puzzle.dart';

class PuzzleService {

  List<Puzzle> initializePuzzles(int nrPuzzles) {
    List<Puzzle> puzzles = [];

    puzzles.clear();

    for (int i = 0; i < nrPuzzles; i++) {
      final id = String.fromCharCode('a'.codeUnitAt(0) + i);

      puzzles.add(Puzzle(id: id));
    }
    return puzzles;
  }

}
