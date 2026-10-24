import 'package:flutter/material.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/controller/add_missions_controller.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/create_puzzle/puzzle_widget.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/puzzle_list/puzzle_type_info.dart';
import 'package:teamxperience/ui/ui.dart';

/// One puzzle opened from the mission, where its screen is put together.
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

    return Scaffold(
      backgroundColor: context.colors.page,
      appBar: AppBar(
        backgroundColor: context.colors.page,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(),
        title: Text('Puzzle ${index + 1} · ${type.label}'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, 30),
          child: PuzzleWidget(
            key: ValueKey('puzzle-$mission-$index'),
            puzzle: puzzle,
            mode: 'edit',
            addMissionsController: controller,
            onSave: () {},
          ),
        ),
      ),
    );
  }
}
