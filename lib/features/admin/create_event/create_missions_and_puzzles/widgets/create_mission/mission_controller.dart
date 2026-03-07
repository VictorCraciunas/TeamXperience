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
      if(mode == "blueprint"){
        _clearPuzzleDataForDuplication(mission);
      }
      buildPuzzleWidgets(mission, addMissionsController, mode);
    }
  }
  void _clearPuzzleDataForDuplication(Mission mission) {
    for (Puzzle puzzle in mission.puzzles) {
      puzzle.type = null;
      puzzle.code = null;
      puzzle.latitude = null;
      puzzle.longitude = null;
      puzzle.indiciu = null;
    }
  }

  void buildPuzzleWidgets(
      Mission mission,
      AddMissionsController addMissionsController,
      String mode,
      ) {
    for (int i = 0; i < mission.puzzles.length; i++) {
      addPuzzleWidget(mission.puzzles[i], addMissionsController, mode);

      // Check if puzzle is done based on whether it has a type
      if (mode == "edit") {
        // In edit mode, check if puzzle has a type to determine if it's done
        isPuzzleDone.add(mission.puzzles[i].type != null);
      } else {
        // For other modes (blueprint, duplicate, create), puzzle is not done initially
        isPuzzleDone.add(false);
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
          togglePuzzle(int.parse(puzzle.id));
          bool isDone = areAllPuzzlessDone();
          missionDone(isDone);
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
