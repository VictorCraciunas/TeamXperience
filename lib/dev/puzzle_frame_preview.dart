import 'package:flutter/material.dart';
import 'package:teamxperience/features/event_game/logic/puzzle_rules.dart';
import 'package:teamxperience/features/event_game/logic/style_hints.dart';
import 'package:teamxperience/features/event_game/widgets/hint_sheet.dart';
import 'package:teamxperience/features/event_game/widgets/puzzle_bottom_bar.dart';
import 'package:teamxperience/features/event_game/widgets/puzzle_feedback.dart';
import 'package:teamxperience/features/event_game/widgets/puzzle_header.dart';
import 'package:teamxperience/ui/components/game/mission_segments.dart';
import 'package:teamxperience/ui/components/misc/segmented_switch.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/utils/component_conversion/component_to_widget.dart';

import 'sample_event.dart';

/// The puzzle frame of mockup 06 around the sample event's "Casa cu ochi"
/// code puzzle, after a wrong answer or during the lock, in parchment or in
/// black and green: the frame takes its colours from the puzzle's pieces.
class PuzzleFramePreview extends StatefulWidget {
  const PuzzleFramePreview({super.key});

  @override
  State<PuzzleFramePreview> createState() => _PuzzleFramePreviewState();
}

class _PuzzleFramePreviewState extends State<PuzzleFramePreview> {
  bool _neon = false;
  bool _locked = false;
  final _convert = ComponentToWidget();

  @override
  Widget build(BuildContext context) {
    final event = _neon ? neonSampleEvent() : sampleEvent();
    final mission = event.missions[3];
    final puzzle = mission.puzzles.first;
    final palette = eventPaletteOf(event, context.colors);

    return Scaffold(
      backgroundColor: palette.background,
      body: Column(
        children: [
          Expanded(
            child: EventThemeScope(
              palette: palette,
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    PuzzleHeader(
                      mission: 4,
                      missions: event.missions.length,
                      title: mission.title ?? '',
                      clock: '0:42:18',
                      onBack: () => Navigator.maybePop(context),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: MissionSegments(total: event.missions.length, done: 3),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            for (final component in puzzle.components) ...[
                              _convert.convert(component, onTextChanged: (_) {}, onButtonPressed: () {}),
                              const SizedBox(height: 16),
                            ],
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: PuzzleFeedback(
                        wrong: _locked ? null : wrongLine(puzzle),
                        maxAttempts: puzzle.maxAttempts,
                        attemptsLeft: _locked ? puzzle.maxAttempts : 2,
                        lockLeft: _locked ? const Duration(seconds: 45) : null,
                      ),
                    ),
                    PuzzleBottomBar(
                      onHint: () => showHintSheet(context, hint: puzzle.indiciu ?? '', palette: palette),
                      onChat: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
          ColoredBox(
            color: context.colors.page,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SegmentedSwitch(
                      labels: const ['Pergament', 'Neon'],
                      selectedIndex: _neon ? 1 : 0,
                      onSelected: (i) => setState(() => _neon = i == 1),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SegmentedSwitch(
                      labels: const ['Greșit', 'Blocat'],
                      selectedIndex: _locked ? 1 : 0,
                      onSelected: (i) => setState(() => _locked = i == 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
