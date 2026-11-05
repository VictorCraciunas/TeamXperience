import 'package:flutter/material.dart';
import 'package:teamxperience/features/event_game/logic/answer_check.dart';
import 'package:teamxperience/features/event_game/logic/spaced_components.dart';
import 'package:teamxperience/utils/component_conversion/answer_feedback.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/puzzle.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/service/route_service.dart';
import 'package:teamxperience/service/team_service/team_service.dart';
import 'package:teamxperience/utils/component_conversion/component_to_widget.dart';
import '../../../enums/component-type.dart';

class PuzzleGameController {
  final Mission mission;
  final ImageProvider background;
  final int missionIndex;
  List<List<Widget>> puzzleWidgets = [];

  /// The space under each component of each puzzle; null means the usual gap.
  List<List<double?>> puzzleSpaces = [];
  final ValueNotifier<int> selectedPuzzleNotifier = ValueNotifier(0);
  final ComponentToWidget componentToWidget = ComponentToWidget();
  String userInput = "";

  /// Tells the code input of the puzzle that an answer was checked.
  final AnswerFeedback answerFeedback = AnswerFeedback();
  bool _advancing = false;
  bool _disposed = false;
  late BuildContext context;
  TeamService teamService = TeamService();
  final RouteService routeService = RouteService();
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
    puzzleSpaces.clear();
    for (Puzzle puzzle in mission.puzzles) {
      List<Widget> widgets = [];
      for (var component in puzzle.components) {
        Widget widget;
        if (component.type == ComponentType.code) {
          widget = componentToWidget.convert(
            component,
            onTextChanged: (String value) => handleCodeInput(value),
            feedback: answerFeedback,
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
      puzzleSpaces.add([for (final component in puzzle.components) component.spaceBelow]);
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
      if (isCorrectAnswer(userInput, puzzle.code)) {
        final pause = pauseAfterCorrectAnswer(puzzle);
        if (pause == Duration.zero) {
          navigate();
        } else if (!_advancing) {
          // Let the pop be seen before going on.
          _advancing = true;
          answerFeedback.correct();
          Future.delayed(pause, () {
            if (!_disposed) navigate();
          });
        }
      } else {
        answerFeedback.wrong();
      }
    } else {
      navigate();
    }
  }

  void navigate() async {
    _advancing = false;
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
        await teamService.updateMissionProgress(
          event.eventId,
          team.name,
          team.missionProgress,
          completedMission: team.missionProgress - 1,
        );
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

  List<double?> getCurrentPuzzleSpaces() {
    if (puzzleSpaces.isNotEmpty && selectedPuzzle < puzzleSpaces.length) {
      return puzzleSpaces[selectedPuzzle];
    }
    return const [];
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

  /// The components with the gaps the organiser chose under them.
  List<Widget> buildComponentsWithSpacing(List<Widget> components, List<Animation<double>> animations) {
    return spacedComponents(
      components,
      animations,
      getCurrentPuzzleSpaces(),
      mode: event.screenAnimation,
    );
  }

  void dispose() {
    _disposed = true;
    answerFeedback.dispose();
    selectedPuzzleNotifier.dispose();
  }
}