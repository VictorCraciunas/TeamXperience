import 'package:flutter/material.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/puzzle.dart';
import 'package:teamxperience/utils/component_conversion/component_to_widget.dart';
import '../../../enums/component-type.dart';

class PuzzleGameController {
  final Mission mission;
  final ImageProvider background;
  List<List<Widget>> puzzleWidgets = [];
  final ValueNotifier<int> selectedPuzzleNotifier = ValueNotifier(0);
  final ComponentToWidget componentToWidget = ComponentToWidget();
  String userInput = "";
  late BuildContext context;

  PuzzleGameController(this.mission, this.background) {
    loadPuzzles();
  }

  // Method to set context when screen is ready
  void setContext(BuildContext ctx) {
    context = ctx;
  }

  int get selectedPuzzle => selectedPuzzleNotifier.value;

  void loadPuzzles() {
    puzzleWidgets.clear();
    for (Puzzle puzzle in mission.puzzles) {
      List<Widget> widgets = [];
      for (var component in puzzle.components) {
        Widget widget;
        if (component.type == ComponentType.code) {
          widget = componentToWidget.convert(
            component,
            onTextChanged: (String value) => handleCodeInput(value),
          );
        } else if (component.type == ComponentType.button) {
          widget = componentToWidget.convert(
            component,
            onButtonPressed: () => buttonPressed(puzzle),
          );
        } else {
          widget = componentToWidget.convert(component);
        }
        widgets.add(widget);
      }
      puzzleWidgets.add(widgets);
    }
  }

  void handleCodeInput(String value) {
    userInput = value;
  }

  void buttonPressed(Puzzle puzzle) {
    if (puzzle.type == PuzzleType.code) {
      print("a intrat in code");
      if (userInput == puzzle.code) {
        print("codul e acelasi");
        navigate();
      } else {
        print("error");
      }
    } else {
      print("nu e code sau nush");
      navigate();
    }
  }

  void navigate() {
    if (hasNextPuzzle()) {
      selectedPuzzleNotifier.value++;
    } else {
      Navigator.pop(context);
    }
  }

  List<Widget> getCurrentPuzzleWidgets() {
    if (puzzleWidgets.isNotEmpty && selectedPuzzle < puzzleWidgets.length) {
      return puzzleWidgets[selectedPuzzle];
    }
    return [];
  }

  bool hasNextPuzzle() {
    return selectedPuzzle < puzzleWidgets.length - 1;
  }

  int get totalPuzzles => mission.puzzles.length;
  int get currentPuzzleIndex => selectedPuzzle;

  // Updated method to include sequential animations
  List<Widget> buildComponentsWithSpacing(List<Widget> components, List<Animation<double>> animations) {
    if (components.isEmpty) return components;

    List<Widget> spacedComponents = [];
    for (int i = 0; i < components.length; i++) {
      // Wrap each component with animated opacity
      Widget animatedComponent = Opacity(
        opacity: animations.isNotEmpty && i < animations.length
            ? animations[i].value
            : 1.0,
        child: components[i],
      );

      spacedComponents.add(animatedComponent);

      // Add spacing between components (except after the last one)
      if (i < components.length - 1) {
        double spacing = 40.0;
        spacedComponents.add(SizedBox(height: spacing));
      }
    }
    return spacedComponents;
  }

  void dispose() {
    selectedPuzzleNotifier.dispose();
  }
}