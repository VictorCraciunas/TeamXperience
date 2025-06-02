import 'package:flutter/cupertino.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/controller/add_missions_controller.dart';
import 'package:teamxperience/model/mission.dart';

import '../../../../../../model/puzzle.dart';
import '../create_puzzle/puzzle_widget.dart';

class MissionController {
  int selectedPuzzle = -1; // Start with no selection
  List<PuzzleWidget> puzzleWidgets = [];
  List<bool> isPuzzleDone = [];
  final Function(bool isMissionDone) missionDone;

  MissionController(
    Mission mission,
    String mode,
    AddMissionsController addMissionsController,
      this.missionDone
  ) {
    if (mode == "blueprint" || mode == "edit") {
      buildPuzzleWidgets(mission, addMissionsController, mode);
    }
  }

  void buildPuzzleWidgets(
    Mission mission,
    AddMissionsController addMissionsController,
    String mode,
  ) {
    for (int i = 0; i < mission.puzzles.length; i++) {
      addPuzzleWidget(mission.puzzles[i], addMissionsController, mode);
      if (mission.puzzles[i].type == null) {
        isPuzzleDone.add(false);
      } else {
        isPuzzleDone.add(true);
      }
    }
  }

  void addNewPuzzle(
    AddMissionsController addMissionsController,
    Mission currMission,
  ) {
    Puzzle puzzle = Puzzle(id: currMission.puzzles.length.toString());
    currMission.addPuzzle(puzzle);
    addPuzzleWidget(puzzle, addMissionsController, "create");
    selectedPuzzle = currMission.puzzles.length - 1;
    isPuzzleDone.add(false);
  }

  void addPuzzleWidget(
    Puzzle puzzle,
    AddMissionsController addMissionsController,
    String puzzleMode,
  ) {
    puzzleWidgets.add(
      PuzzleWidget(
        key: UniqueKey(),
        puzzle: puzzle,
        mode: puzzleMode,
        onSave: () {
          print('Puzzle saved at index: ${int.parse(puzzle.id)}');
          togglePuzzle(int.parse(puzzle.id));
          print('Puzzle states after toggle: $isPuzzleDone');
          bool isDone = areAllPuzzlessDone();
          print('Are all puzzles done? $isDone');
          missionDone(isDone);
          print('missionDone called successfully');
        },
        addMissionsController: addMissionsController,
      ),
    );
  }

  void togglePuzzle(int puzzleIndex) {
    if (puzzleIndex >= 0 && puzzleIndex < isPuzzleDone.length) {
      isPuzzleDone[puzzleIndex] = !isPuzzleDone[puzzleIndex];
    }
  }

  bool areAllPuzzlessDone() {
    for (int i = 0; i < isPuzzleDone.length; i++) {
      if (isPuzzleDone[i] == false) {
        return false;
      }
    }
    return true;

  }
}
