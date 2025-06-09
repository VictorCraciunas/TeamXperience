import 'package:flutter/material.dart';
import 'package:teamxperience/features/event_game/controller/puzzle_game_controller.dart';
import '../../../constants/padding.dart';
import '../../../model/mission.dart';

class PuzzleGameScreen extends StatefulWidget {
  const PuzzleGameScreen({super.key});

  @override
  State<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends State<PuzzleGameScreen> {
  late PuzzleGameController controller;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final mission = args['mission'] as Mission;
      final background = args['background'] as ImageProvider;
      controller = PuzzleGameController(mission, background);
      _initialized = true;
    }

    controller.setContext(context);
    _initialized = true;

  }

  @override
  void dispose() {
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
            child: Column(
              children: [
                // Header with puzzle info - this will rebuild when selectedPuzzle changes
                ValueListenableBuilder<int>(
                  valueListenable: controller.selectedPuzzleNotifier,
                  builder: (context, selectedPuzzle, child) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Puzzle ${selectedPuzzle + 1}/${controller.totalPuzzles}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // Main puzzle content area - this will also rebuild
                Expanded(
                  child: ValueListenableBuilder<int>(
                    valueListenable: controller.selectedPuzzleNotifier,
                    builder: (context, selectedPuzzle, child) {
                      return Container(
                        child: controller.getCurrentPuzzleWidgets().isEmpty
                            ? const Center(
                          child: Text(
                            'No puzzle components found',
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                            : Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: controller.buildComponentsWithSpacing(
                                  controller.getCurrentPuzzleWidgets()),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}