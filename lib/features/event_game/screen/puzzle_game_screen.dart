import 'package:flutter/material.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/event_game/logic/route_texts.dart';
import 'package:teamxperience/features/event_game/logic/style_hints.dart';
import 'package:teamxperience/features/event_game/widgets/frame_band.dart';
import 'package:teamxperience/features/event_game/widgets/hint_sheet.dart';
import 'package:teamxperience/features/event_game/widgets/puzzle_bottom_bar.dart';
import 'package:teamxperience/features/event_game/widgets/puzzle_feedback.dart';
import 'package:teamxperience/features/event_game/widgets/puzzle_header.dart';
import 'package:teamxperience/ui/components/game/mission_segments.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/features/event_game/logic/component_fades.dart';
import 'package:teamxperience/features/event_game/logic/entrance.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/features/event_game/controller/puzzle_game_controller.dart';
import 'package:teamxperience/features/event_game/widgets/geolocation_puzzle_widget.dart';
import 'package:teamxperience/features/event_game/widgets/image_upload/image_upload_puzzle_widget.dart';
import '../../../model/event.dart';
import '../../../model/mission.dart';
import '../../../model/team.dart';

/// One mission's puzzles inside the game frame of mockup 06, in the event's
/// colours: header, mission bars, the organiser's content (as built), the
/// wrong-answer line and attempts, and "Indiciu" with the chat.
class PuzzleGameScreen extends StatefulWidget {
  const PuzzleGameScreen({super.key});

  @override
  State<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends State<PuzzleGameScreen> with SingleTickerProviderStateMixin {
  late PuzzleGameController controller;
  bool _initialized = false;
  late AnimationController _animationController;
  List<Animation<double>> _animations = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final mission = args['mission'] as Mission;
      final background = args['background'] as ImageProvider?;
      final event = args['event'] as Event;
      final team = args['team'] as Team;
      final missionIndex = args['missionIndex'] as int;
      controller = PuzzleGameController(mission, background, event, team, missionIndex);
      controller.onOutOfAttempts = () {
        if (mounted && controller.canUseHint) _openHint();
      };

      // Initialize animation controller
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), // Total duration for all animations
        vsync: this,
      );

      _initialized = true;
    }

    controller.setContext(context);
  }

  void _createAnimations(int componentCount) {
    if (componentCount == 0) return;

    _animations = componentFades(
      _animationController,
      componentCount,
      controller.event.screenAnimation,
      timing: _timing,
    );
  }

  EntranceTiming get _timing =>
      EntranceTiming(durationMs: controller.event.animationDuration, delayMs: controller.event.animationDelay);

  void _startAnimation(int componentCount) {
    startEntrance(_animationController, controller.event.screenAnimation, count: componentCount, timing: _timing);
  }

  /// The organiser's picture behind the puzzle, when there is one.
  static DecorationImage? _backdrop(ImageProvider? image) =>
      image == null ? null : DecorationImage(image: image, fit: BoxFit.cover, onError: (_, __) {});

  void _openHint() {
    final hint = controller.getCurrentPuzzle()?.indiciu?.trim() ?? '';
    if (hint.isEmpty) return;
    controller.useHint();
    showHintSheet(context, hint: hint, palette: eventPaletteOf(controller.event, context.colors));
  }

  void _openChat() {
    Navigator.pushNamed(
      context,
      Routes.chatScreen,
      arguments: {'eventId': controller.event.eventId, 'team': controller.team},
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final palette = eventPaletteOf(controller.event, context.colors);
    return EventThemeScope(
      palette: palette,
      child: Scaffold(
        backgroundColor: palette.background,
        body: Container(
          decoration: BoxDecoration(image: _backdrop(controller.background)),
          child: SafeArea(
            child: Column(
              children: [
                FrameBand(
                  onPicture: controller.background != null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ValueListenableBuilder<DateTime>(
                        valueListenable: controller.now,
                        builder:
                            (context, now, _) => PuzzleHeader(
                              mission: controller.missionIndex + 1,
                              missions: controller.event.missions.length,
                              title: controller.missionTitle,
                              clock: playedClock(controller.team.startedAt, controller.event.dateEvent, now),
                              onBack: () => Navigator.maybePop(context),
                            ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                        child: MissionSegments(
                          total: controller.event.missions.length,
                          done: controller.team.missionProgress,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                    child: ValueListenableBuilder<int>(
                      valueListenable: controller.selectedPuzzleNotifier,
                      builder: (context, selectedPuzzle, child) {
                        final currentPuzzle = controller.getCurrentPuzzle();
                        final components = controller.getCurrentPuzzleWidgets();
                        final isGeolocation = currentPuzzle?.type == PuzzleType.geolocation;
                        final isImageUpload = currentPuzzle?.type == PuzzleType.imageToUpload;

                        // Create animations for current puzzle components
                        _createAnimations(components.length);

                        // Start animation when puzzle changes
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _startAnimation(components.length);
                        });

                        if (isGeolocation && currentPuzzle != null) {
                          return Column(
                            children: [
                              // Render admin components (text, images, etc.)
                              if (components.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: AnimatedBuilder(
                                    animation: _animationController,
                                    builder: (context, child) {
                                      return Column(
                                        children: controller.buildComponentsWithSpacing(components, _animations),
                                      );
                                    },
                                  ),
                                ),
                              // Map + button
                              Expanded(
                                child: GeolocationPuzzleWidget(
                                  key: ValueKey('geo_$selectedPuzzle'),
                                  puzzle: currentPuzzle,
                                  onSolved: () => controller.navigate(),
                                  isMissionCompleted: controller.isMissionCompleted,
                                  routeService: controller.routeService,
                                ),
                              ),
                            ],
                          );
                        }

                        if (isImageUpload && currentPuzzle != null) {
                          return Column(
                            children: [
                              if (components.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: AnimatedBuilder(
                                    animation: _animationController,
                                    builder: (context, child) {
                                      return Column(
                                        children: controller.buildComponentsWithSpacing(components, _animations),
                                      );
                                    },
                                  ),
                                ),
                              Expanded(
                                child: ImageUploadPuzzleWidget(
                                  key: ValueKey('img_$selectedPuzzle'),
                                  eventId: controller.event.eventId,
                                  teamName: controller.team.name,
                                  missionIndex: controller.missionIndex,
                                  puzzleIndex: selectedPuzzle,
                                  onSolved: () => controller.navigate(),
                                  isMissionCompleted: controller.isMissionCompleted,
                                ),
                              ),
                            ],
                          );
                        }

                        if (components.isEmpty) {
                          return const Center(
                            child: Text('No puzzle components found', style: TextStyle(fontSize: 18)),
                          );
                        }

                        return Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Column(children: controller.buildComponentsWithSpacing(components, _animations));
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                ListenableBuilder(
                  listenable: Listenable.merge([
                    controller.rules.changes,
                    controller.wrongMessage,
                    controller.now,
                    controller.selectedPuzzleNotifier,
                  ]),
                  builder: (context, _) {
                    final puzzle = controller.getCurrentPuzzle();
                    final isCode = puzzle?.type == PuzzleType.code && !controller.isMissionCompleted;
                    return FrameBand(
                      onPicture: controller.background != null,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isCode)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: PuzzleFeedback(
                                wrong: controller.wrongMessage.value,
                                maxAttempts: puzzle?.maxAttempts,
                                attemptsLeft: controller.currentAttemptsLeft,
                                lockLeft: controller.currentLock,
                              ),
                            ),
                          PuzzleBottomBar(onHint: controller.canUseHint ? _openHint : null, onChat: _openChat),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
