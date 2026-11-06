import 'dart:async';

import 'package:flutter/material.dart';
import 'package:teamxperience/features/event_game/logic/answer_check.dart';
import 'package:teamxperience/features/event_game/logic/puzzle_rules.dart';
import 'package:teamxperience/features/event_game/logic/puzzle_rules_keeper.dart';
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
  /// The organiser's picture behind the puzzles, or null.
  final ImageProvider? background;
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

  /// The team's attempts, locks and hints, kept in step with teammates'
  /// phones while the puzzle is open.
  late final PuzzleRulesKeeper rules;

  /// The organiser's line after a wrong answer; cleared on the next input.
  final ValueNotifier<String?> wrongMessage = ValueNotifier(null);

  /// Called when the last attempt of a puzzle was used (the screen opens the
  /// hint).
  VoidCallback? onOutOfAttempts;

  StreamSubscription<Team>? _teamWatch;

  /// The current time, ticking every second for the clock and the lock.
  final ValueNotifier<DateTime> now = ValueNotifier(DateTime.now());
  Timer? _tick;

  /// Whether this mission was already completed before entering
  bool get isMissionCompleted => missionIndex < team.missionProgress;

  PuzzleGameController(this.mission, this.background, this.event, this.team, this.missionIndex) {
    rules = PuzzleRulesKeeper(
      team: team,
      addWrongAttempt: (key) => teamService.addWrongAttempt(event.eventId, team.name, key),
      lockPuzzle: (key, until) => teamService.lockPuzzle(event.eventId, team.name, key, until),
      markHintUsed: (key) => teamService.markHintUsed(event.eventId, team.name, key),
    );
    _teamWatch = teamService
        .getStreamTeam(event.eventId, team.name)
        .listen(_absorb, onError: (Object _) {});
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => now.value = DateTime.now());
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

  /// A fresh team doc: counts, locks and hints from every phone. A lock that
  /// starts here this way opens the hint as one this phone triggered would.
  void _absorb(Team fresh) {
    final justLocked = rules.absorb(fresh, puzzle: getCurrentPuzzle(), key: currentKey);
    if (justLocked && !isMissionCompleted) {
      wrongMessage.value = null;
      onOutOfAttempts?.call();
    }
  }

  void handleCodeInput(String value) {
    userInput = value;
    wrongMessage.value = null;
  }

  /// The key of the puzzle on screen in the team's counters.
  String get currentKey => Team.puzzleKey(missionIndex, selectedPuzzle);

  /// Whether the puzzle on screen has a hint the team may open.
  bool get canUseHint {
    final puzzle = getCurrentPuzzle();
    return puzzle != null && !isMissionCompleted && hintAvailable(event, puzzle, team, missionIndex, selectedPuzzle);
  }

  /// The mission's title, or "Misiunea 4" when it has none.
  String get missionTitle {
    final title = mission.title?.trim() ?? '';
    return title.isEmpty ? 'Misiunea ${missionIndex + 1}' : title;
  }

  /// Attempts left on the puzzle on screen; null without a limit.
  int? get currentAttemptsLeft {
    final puzzle = getCurrentPuzzle();
    return puzzle == null ? null : attemptsLeft(puzzle, team, currentKey);
  }

  /// How long the puzzle on screen still refuses answers; null when it does not.
  Duration? get currentLock => rules.lockLeft(currentKey);

  /// Opens the hint of the puzzle on screen (counted once per puzzle).
  Future<void> useHint() => rules.useHint(currentKey);

  void buttonPressed(Puzzle puzzle) {
    if (isMissionCompleted) {
      navigate();
      return;
    }

    if (puzzle.type == PuzzleType.code) {
      final key = Team.puzzleKey(missionIndex, mission.puzzles.indexOf(puzzle));
      // A locked puzzle takes no answer, right or wrong, until the lock ends.
      if (rules.isLocked(key)) return;
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
        final result = rules.wrong(puzzle, key);
        if (result == WrongResult.locked) return;
        answerFeedback.wrong();
        if (result == WrongResult.outOfAttempts) {
          // The countdown takes the line's place until the lock ends.
          wrongMessage.value = null;
          onOutOfAttempts?.call();
        } else {
          wrongMessage.value = wrongLine(puzzle);
        }
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
      wrongMessage.value = null;

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
    _teamWatch?.cancel();
    _tick?.cancel();
    now.dispose();
    rules.dispose();
    wrongMessage.dispose();
    answerFeedback.dispose();
    selectedPuzzleNotifier.dispose();
  }
}