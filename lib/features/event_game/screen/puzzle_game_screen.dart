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
import '../widgets/preview_skip_view.dart';

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
      controller = PuzzleGameController(mission, background, event, team, missionIndex, preview: args['preview'] == true);
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
    if (controller.preview) return;
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
                  // Location and photo puzzles run edge to edge with their own
                  // bars; the organiser's components keep the page padding.
                  child: Padding(
                    padding: EdgeInsets.zero,
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

                        // The organiser's content (text, images, etc.) on a
                        // location or photo puzzle: it goes inside what scrolls
                        // there, so a long one cannot push the button off.
                        final organiser = components.isEmpty
                            ? null
                            : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page + 20, vertical: 20),
                                child: AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    return Column(
                                      children: controller.buildComponentsWithSpacing(components, _animations),
                                    );
                                  },
                                ),
                              );

                        if (isGeolocation && currentPuzzle != null) {
                          if (controller.preview) {
                            return PreviewSkipView(
                              key: ValueKey('preview_$selectedPuzzle'),
                              text: 'Aici echipele trebuie să ajungă la locul de pe hartă.',
                              onSkip: controller.navigate,
                              header: organiser,
                            );
                          }
                          return GeolocationPuzzleWidget(
                            key: ValueKey('geo_$selectedPuzzle'),
                            puzzle: currentPuzzle,
                            onSolved: () => controller.navigate(),
                            isMissionCompleted: controller.isMissionCompleted,
                            routeService: controller.routeService,
                            onHint: controller.canUseHint ? _openHint : null,
                            onPicture: controller.background != null,
                            header: organiser,
                          );
                        }

                        if (isImageUpload && currentPuzzle != null) {
                          if (controller.preview) {
                            return PreviewSkipView(
                              key: ValueKey('preview_$selectedPuzzle'),
                              text: 'Aici echipele trimit o fotografie, iar tu o aprobi din chat.',
                              onSkip: controller.navigate,
                              header: organiser,
                            );
                          }
                          return ImageUploadPuzzleWidget(
                            key: ValueKey('img_$selectedPuzzle'),
                            eventId: controller.event.eventId,
                            teamName: controller.team.name,
                            missionIndex: controller.missionIndex,
                            puzzleIndex: selectedPuzzle,
                            onSolved: () => controller.navigate(),
                            onChat: _openChat,
                            isMissionCompleted: controller.isMissionCompleted,
                            onPicture: controller.background != null,
                            header: organiser,
                          );
                        }

                        if (components.isEmpty) {
                          return const Center(
                            child: Text('No puzzle components found', style: TextStyle(fontSize: 18)),
                          );
                        }

                        return Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page + 20, vertical: 20),
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
                    // Location and photo puzzles draw their own bar.
                    if (puzzle?.type == PuzzleType.geolocation || puzzle?.type == PuzzleType.imageToUpload) {
                      return const SizedBox.shrink();
                    }
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
