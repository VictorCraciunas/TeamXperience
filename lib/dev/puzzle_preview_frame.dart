import 'package:flutter/material.dart';
import 'package:teamxperience/features/event_game/logic/style_hints.dart';
import 'package:teamxperience/features/event_game/widgets/puzzle_header.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/game/mission_segments.dart';
import 'package:teamxperience/ui/components/misc/segmented_switch.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/utils/component_conversion/component_to_widget.dart';

/// The gallery's frame around one puzzle of a sample event: the 6b header and
/// bars, the organiser's pieces, then [body]; under it, the switches.
class PuzzlePreviewFrame extends StatelessWidget {
  const PuzzlePreviewFrame({
    super.key,
    required this.event,
    required this.mission,
    required this.clock,
    required this.body,
    required this.switches,
  });

  final Event event;
  final int mission;
  final String clock;
  final Widget body;

  /// Each switch: its labels, the selected one and what a tap does.
  final List<(List<String>, int, ValueChanged<int>)> switches;

  @override
  Widget build(BuildContext context) {
    final palette = eventPaletteOf(event, context.colors);
    final missionData = event.missions[mission];
    final convert = ComponentToWidget();
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
                      mission: mission + 1,
                      missions: event.missions.length,
                      title: missionData.title ?? '',
                      clock: clock,
                      onBack: () => Navigator.maybePop(context),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                      child: MissionSegments(total: event.missions.length, done: mission),
                    ),
                    for (final piece in missionData.puzzles.first.components)
                      Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: convert.convert(piece)),
                    Expanded(child: body),
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
                    for (final (labels, selected, onSelected) in switches) ...[
                      SegmentedSwitch(labels: labels, selectedIndex: selected, onSelected: onSelected),
                      const SizedBox(height: AppSpacing.xs),
                    ],
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
