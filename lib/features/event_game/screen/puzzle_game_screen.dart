import 'package:flutter/material.dart';
import 'package:teamxperience/features/event_game/controller/puzzle_game_controller.dart';
import '../../../constants/padding.dart';
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
      controller = PuzzleGameController(mission, background,event,team);

      // Initialize animation controller
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 4000), // Total duration for all animations
        vsync: this,
      );

      _initialized = true;
    }

    controller.setContext(context);
  }

  void _createAnimations(int componentCount) {
    if (componentCount == 0) return;

    _animations = List.generate(componentCount, (index) {
      double start = index / componentCount;
      double end = (index + 1) / componentCount;

      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(start, end, curve: Curves.easeIn),
      ));
    });
  }

  void _startAnimation() {
    _animationController.reset();
    _animationController.forward();
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
              horizontal: MyPaddings.appHorizontalPadding,
            ),
            child: ValueListenableBuilder<int>(
              valueListenable: controller.selectedPuzzleNotifier,
              builder: (context, selectedPuzzle, child) {
                final components = controller.getCurrentPuzzleWidgets();

                // Create animations for current puzzle components
                _createAnimations(components.length);

                // Start animation when puzzle changes
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _startAnimation();
                });

                return Container(
                  child: components.isEmpty
                      ? const Center(
                    child: Text(
                      'No puzzle components found',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                      : Center(
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