import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/model/puzzle.dart';

class PuzzleService {
  List<Puzzle> puzzles = [];

  List<Puzzle> initializePuzzles(int nrPuzzles) {
    puzzles.clear();

    for (int i = 0; i < nrPuzzles; i++) {
      final id = String.fromCharCode('a'.codeUnitAt(0) + i);

      puzzles.add(Puzzle(id: id));
    }
    return puzzles;
  }

}
