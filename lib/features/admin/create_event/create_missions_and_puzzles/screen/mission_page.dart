import 'package:flutter/material.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/controller/add_missions_controller.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/screen/puzzle_page.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/mission_list/mission_text_fields.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/puzzle_list/puzzle_row.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/puzzle_list/puzzle_type_sheet.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';
import 'package:teamxperience/ui/components/feedback/app_dialog.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';
import 'package:teamxperience/ui/ui.dart';

/// One mission opened from the list: its puzzles, one row each.
class MissionPage extends StatefulWidget {
  const MissionPage({super.key, required this.controller, required this.index});

  final AddMissionsController controller;
  final int index;

  @override
  State<MissionPage> createState() => _MissionPageState();
}

class _MissionPageState extends State<MissionPage> {
  AddMissionsController get _controller => widget.controller;

  Future<void> _openPuzzle(int puzzle) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => PuzzlePage(
              controller: _controller,
              mission: widget.index,
              index: puzzle,
            ),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _addPuzzle() async {
    final type = await showPuzzleTypeSheet(context);
    if (type == null || !mounted) return;

    final puzzle = _controller.addPuzzle(widget.index, type);
    if (puzzle >= 0) await _openPuzzle(puzzle);
  }

  Future<void> _confirmDelete(int puzzle) async {
    final ok = await showAppDialog(
      context,
      title: 'Ștergi puzzle-ul ${puzzle + 1}?',
      confirmLabel: 'Șterge',
      cancelLabel: 'Anulează',
      destructive: true,
    );
    if (!ok) return;

    _controller.removePuzzle(widget.index, puzzle);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final puzzles = _controller.event.missions[widget.index].puzzles;

    return Scaffold(
      backgroundColor: context.colors.page,
      appBar: MyAppBar(appBarText: 'Misiunea ${widget.index + 1}'),
      body: SafeArea(
        // Hold a puzzle and drag it to change the order.
        child: ReorderableListView.builder(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            8,
            AppSpacing.page,
            30,
          ),
          header: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: MissionTextFields(
              mission: _controller.event.missions[widget.index],
              onChanged: ({title, teaser, isTeaserPublic}) => _controller.setMissionText(
                widget.index,
                title: title,
                teaser: teaser,
                isTeaserPublic: isTeaserPublic,
              ),
            ),
          ),
          itemCount: puzzles.length,
          onReorderItem:
              (from, to) => _controller.movePuzzle(widget.index, from, to),
          itemBuilder:
              (context, i) => Padding(
                key: ObjectKey(puzzles[i]),
                padding: const EdgeInsets.only(bottom: 10),
                child: PuzzleRow(
                  index: i,
                  type: puzzles[i].type,
                  status: _controller.puzzleStatus(widget.index, i),
                  done: _controller.puzzleStatus(widget.index, i) == 'Gata',
                  onTap: () => _openPuzzle(i),
                  onDelete: () => _confirmDelete(i),
                ),
              ),
          footer: Column(
            children: [
              if (puzzles.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Misiunea nu are încă puzzle-uri.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: context.colors.muted, fontSize: 13),
                  ),
                ),
              AppButton(
                label: 'Adaugă puzzle',
                variant: AppButtonVariant.secondary,
                foregroundColor: context.colors.text,
                onPressed: _addPuzzle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
