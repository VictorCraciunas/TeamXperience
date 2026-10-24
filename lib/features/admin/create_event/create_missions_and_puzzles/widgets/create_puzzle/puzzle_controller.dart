import 'package:flutter/cupertino.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/puzzle.dart';
import 'package:teamxperience/service/event_service/event_completeness.dart';
import 'package:teamxperience/utils/component_conversion/component_to_widget.dart';

class PuzzleController {
  ComponentToWidget componentToWidget = ComponentToWidget();
  bool isDone = false;
  List<Widget> puzzleComponents = [];
  int componentIndex = 0;

  PuzzleController(Puzzle puzzle) {
    buildPuzzleComponents(puzzle);
    isDone = _isPuzzleComplete(puzzle);
  }

  void buildPuzzleComponents(Puzzle puzzle) {
    for (int i = 0; i < puzzle.components.length; i++) {
      buildComponent(puzzle.components[i]);
    }
  }
  /// Shown as finished once nothing is missing from it.
  bool _isPuzzleComplete(Puzzle puzzle) => puzzleIssues(puzzle).isEmpty;

  void buildComponent(Component component) {
    puzzleComponents.add(componentToWidget.convert(component));
  }
  bool isUrl(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }
}
