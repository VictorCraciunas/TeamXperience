import 'package:flutter/material.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/controller/add_missions_controller.dart';

import '../../../../../../enums/puzzle_type.dart';

class SavePuzzleController{
  PuzzleType? type;
  final TextEditingController textColorController = TextEditingController();
  final TextEditingController indiciuController = TextEditingController();

  void savePuzzle(AddMissionsController addMissionsController, int nrMission, int selectedPuzzle, BuildContext context){
    if (type != null) {
      addMissionsController.setPuzzleType(
        nrMission,
        selectedPuzzle,
        type!,
        type == PuzzleType.code ? textColorController.text : null,
        type == PuzzleType.geolocation ? textColorController.text : null,
        indiciuController.text
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Puzzle salvat cu succes')),
      );
      Navigator.pop(context);
    }
  }
}