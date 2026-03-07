import 'package:flutter/material.dart';
import 'package:teamxperience/model/puzzle.dart';

import '../../../../../../enums/puzzle_type.dart';

class SavePuzzleController{
  PuzzleType? type;
  final TextEditingController textColorController = TextEditingController();
  final TextEditingController indiciuController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();

  void savePuzzle(Puzzle puzzle,BuildContext context){
    if (type != null) {
      puzzle.type = type;
      type == PuzzleType.code ? puzzle.code = textColorController.text : null;
      if (type == PuzzleType.geolocation) {
        puzzle.latitude = double.tryParse(latitudeController.text);
        puzzle.longitude = double.tryParse(longitudeController.text);
      }
      puzzle.indiciu = indiciuController.text;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Puzzle salvat cu succes')),
      );

    }
  }
}