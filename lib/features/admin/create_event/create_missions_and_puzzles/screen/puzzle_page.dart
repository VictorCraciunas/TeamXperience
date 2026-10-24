import 'package:flutter/material.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/controller/add_missions_controller.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/create_puzzle/puzzle_widget.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/puzzle_list/puzzle_type_info.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/puzzle_rules/puzzle_rules_form.dart';
import 'package:teamxperience/ui/ui.dart';

/// One puzzle opened from the mission. "Aspect" is how its screen looks (the
/// components), "Reguli" is what counts as correct and how players are helped.
class PuzzlePage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final puzzle = controller.event.missions[mission].puzzles[index];
    final type = PuzzleTypeInfo.of(puzzle.type);
    const padding = EdgeInsets.fromLTRB(AppSpacing.page, 16, AppSpacing.page, 30);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: context.colors.page,
        appBar: AppBar(
          backgroundColor: context.colors.page,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: const BackButton(),
          title: Text('Puzzle ${index + 1} · ${type.label}'),
          bottom: const TabBar(tabs: [Tab(text: 'Aspect'), Tab(text: 'Reguli')]),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              SingleChildScrollView(
                padding: padding,
                child: PuzzleWidget(
                  key: ValueKey('puzzle-$mission-$index'),
                  puzzle: puzzle,
                  mode: 'edit',
                  addMissionsController: controller,
                ),
              ),
              SingleChildScrollView(
                padding: padding,
                child: PuzzleRulesForm(puzzle: puzzle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
