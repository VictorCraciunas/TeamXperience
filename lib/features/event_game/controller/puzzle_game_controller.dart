import 'package:flutter/material.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/puzzle.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/service/team_service/team_service.dart';
import 'package:teamxperience/utils/component_conversion/component_to_widget.dart';
import '../../../enums/component-type.dart';

class PuzzleGameController {
  final Mission mission;
  final ImageProvider background;
  final int missionIndex;
  List<List<Widget>> puzzleWidgets = [];
  final ValueNotifier<int> selectedPuzzleNotifier = ValueNotifier(0);
  final ComponentToWidget componentToWidget = ComponentToWidget();
  String userInput = "";
  late BuildContext context;
  TeamService teamService = TeamService();
  late Event event;
  late Team team;

  /// Whether this mission was already completed before entering
  bool get isMissionCompleted => missionIndex < team.missionProgress;

  PuzzleGameController(this.mission, this.background, this.event, this.team, this.missionIndex) {
    loadPuzzles();
    // Resume from saved puzzle progress (only for the current unlocked mission)
    if (!isMissionCompleted && team.puzzleNumber > 0 && team.puzzleNumber < mission.puzzles.length) {
      selectedPuzzleNotifier.value = team.puzzleNumber;
    }
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
    if (isMissionCompleted) {
      navigate();
      return;
    }

    if (puzzle.type == PuzzleType.code) {
      if (userInput.trim().toLowerCase() == (puzzle.code ?? '').trim().toLowerCase()) {
        navigate();
      }
    } else {
      navigate();
    }
  }

  void navigate() async {
    if (hasNextPuzzle()) {
      selectedPuzzleNotifier.value++;
      userInput = "";

      if (!isMissionCompleted) {
        team.puzzleNumber = selectedPuzzleNotifier.value;
        try {
          await teamService.updatePuzzleNumber(event.eventId, team.name, team.puzzleNumber);
        } catch (e) {
          print("Error updating puzzle number: $e");
        }
      }
    } else {
      if (isMissionCompleted) {
        Navigator.pop(context, team);
        return;
      }

      // Mission completed - reset puzzle number first, then increment progress
      team.puzzleNumber = 0;
      team.missionProgress = team.missionProgress + 1;

      try {
        await teamService.updatePuzzleNumber(event.eventId, team.name, 0);
        await teamService.updateMissionProgress(event.eventId, team.name, team.missionProgress);
        Navigator.pop(context, team);
      } catch (e) {
        print("Error updating mission progress: $e");
        Navigator.pop(context, null);
      }
    }
  }

  Puzzle? getCurrentPuzzle() {
    if (mission.puzzles.isNotEmpty && selectedPuzzle < mission.puzzles.length) {
      return mission.puzzles[selectedPuzzle];
    }
    return null;
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