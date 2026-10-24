import 'package:flutter/material.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/controller/add_missions_controller.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/create_puzzle/puzzle_widget.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/puzzle_list/puzzle_type_info.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/puzzle_rules/puzzle_rules_form.dart';
import 'package:teamxperience/ui/components/misc/segmented_switch.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';
import 'package:teamxperience/ui/ui.dart';

/// One puzzle opened from the mission. "Aspect" is how its screen looks (the
/// components), "Reguli" is what counts as correct and how players are helped.
class PuzzlePage extends StatefulWidget {
  const PuzzlePage({
    super.key,
    required this.controller,
    required this.mission,
    required this.index,
  });

  final AddMissionsController controller;
  final int mission;
  final int index;

  @override
  State<PuzzlePage> createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> {
  static const _padding = EdgeInsets.fromLTRB(AppSpacing.page, 16, AppSpacing.page, 30);

  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final puzzle = widget.controller.event.missions[widget.mission].puzzles[widget.index];

    return Scaffold(
      backgroundColor: context.colors.page,
      appBar: MyAppBar(
        appBarText: 'Puzzle ${widget.index + 1}',
        subtitle: PuzzleTypeInfo.of(puzzle.type).label,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.page, 12, AppSpacing.page, 0),
              child: SegmentedSwitch(
                labels: const ['Aspect', 'Reguli'],
                selectedIndex: _tab,
                onSelected: (i) => setState(() => _tab = i),
              ),
            ),
            // Both stay built so nothing typed or added is lost when switching.
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: [
                  SingleChildScrollView(
                    padding: _padding,
                    child: PuzzleWidget(
                      key: ValueKey('puzzle-${widget.mission}-${widget.index}'),
                      puzzle: puzzle,
                      mode: 'edit',
                      addMissionsController: widget.controller,
                    ),
                  ),
                  SingleChildScrollView(
                    padding: _padding,
                    child: PuzzleRulesForm(
                      puzzle: puzzle,
                      onChanged: () => setState(() {}),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
