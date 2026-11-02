import 'package:teamxperience/ui/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:teamxperience/features/event_game/logic/component_fades.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/features/event_game/controller/puzzle_game_controller.dart';
import 'package:teamxperience/features/event_game/widgets/geolocation_puzzle_widget.dart';
import 'package:teamxperience/features/event_game/widgets/image_upload/image_upload_puzzle_widget.dart';
import '../../../model/event.dart';
import '../../../model/mission.dart';
import '../../../model/team.dart';

class PuzzleGameScreen extends StatefulWidget {
  const PuzzleGameScreen({super.key});

  @override
  State<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends State<PuzzleGameScreen> with SingleTickerProviderStateMixin{
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
      final background = args['background'] as ImageProvider;
      final event = args['event'] as Event;
      final team = args['team'] as Team;
      final missionIndex = args['missionIndex'] as int;
      controller = PuzzleGameController(mission, background, event, team, missionIndex);

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
    );
  }

  void _startAnimation() {
    startEntrance(_animationController, controller.event.screenAnimation);
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: controller.background,
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.page,
            ),
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
                  _startAnimation();
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
                                children: controller.buildComponentsWithSpacing(
                                  components,
                                  _animations,
                                ),
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
                                children: controller.buildComponentsWithSpacing(
                                  components,
                                  _animations,
                                ),
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
                    child: Text(
                      'No puzzle components found',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Column(
                          children: controller.buildComponentsWithSpacing(
                            components,
                            _animations,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}