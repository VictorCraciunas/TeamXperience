import 'package:flutter/material.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/puzzle_rules/puzzle_rules_controller.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/puzzle_list/puzzle_type_sheet.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/puzzle_rules/puzzle_type_tile.dart';
import 'package:teamxperience/model/puzzle.dart';
import 'package:teamxperience/ui/components/feedback/app_dialog.dart';
import 'package:teamxperience/features/admin/create_event/common_widgets/pin_field_button.dart';
import 'package:teamxperience/features/admin/create_event/common_widgets/pin_picker_screen.dart';
import 'package:teamxperience/ui/components/inputs/app_text_field.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

/// The "Reguli" tab of a puzzle: what counts as correct, the hint, and how many
/// attempts players get. Every change goes straight onto the puzzle.
class PuzzleRulesForm extends StatefulWidget {
  const PuzzleRulesForm({super.key, required this.puzzle, this.onChanged, this.near});

  final Puzzle puzzle;

  /// Where the map opens when the puzzle has no place: its mission's.
  final MapPlace? near;

  /// Called after a change was written onto the puzzle.
  final VoidCallback? onChanged;

  @override
  State<PuzzleRulesForm> createState() => _PuzzleRulesFormState();
}

class _PuzzleRulesFormState extends State<PuzzleRulesForm> {
  late final PuzzleRulesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PuzzleRulesController(widget.puzzle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _changed() {
    _controller.apply();
    setState(() {});
    widget.onChanged?.call();
  }

  Future<void> _pickType() async {
    final chosen = await showPuzzleTypeSheet(context);
    if (chosen == null || chosen == widget.puzzle.type || !mounted) return;

    if (_controller.hasDataToLose) {
      final ok = await showAppDialog(
        context,
        title: 'Schimbi tipul?',
        message: 'Se șterg răspunsul, locația și indiciul acestui puzzle.',
        confirmLabel: 'Schimbă',
        cancelLabel: 'Anulează',
        destructive: true,
      );
      if (!ok || !mounted) return;
    }

    _controller.changeType(chosen);
    setState(() {});
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.puzzle.type;
    const gap = SizedBox(height: 20);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PuzzleTypeTile(type: type, onTap: _pickType),
        gap,
        if (type == PuzzleType.code) ...[
          AppTextField(
            controller: _controller.answerController,
            label: 'Răspuns corect',
            hint: 'Codul pe care îl introduc jucătorii',
            onChanged: (_) => _changed(),
          ),
          gap,
          AppTextField(
            controller: _controller.maxAttemptsController,
            label: 'Număr maxim de încercări',
            hint: 'Gol = nelimitat',
            keyboardType: TextInputType.number,
            validator: (_) => _controller.maxAttemptsError,
            onChanged: (_) => _changed(),
          ),
          gap,
          AppTextField(
            controller: _controller.wrongAnswerController,
            label: 'Mesaj la răspuns greșit',
            hint: 'Gol = „Nu e corect. Mai încearcă.”',
            maxLines: null,
            onChanged: (_) => _changed(),
          ),
          gap,
        ],
        if (type == PuzzleType.geolocation) ...[
          AppTextField(
            controller: _controller.latitudeController,
            label: 'Latitudine',
            hint: 'Ex: 45.7833',
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            validator: (_) => _controller.latitudeError,
            onChanged: (_) => _changed(),
          ),
          gap,
          AppTextField(
            controller: _controller.longitudeController,
            label: 'Longitudine',
            hint: 'Ex: 24.1500',
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            validator: (_) => _controller.longitudeError,
            onChanged: (_) => _changed(),
          ),
          const SizedBox(height: 8),
          PinFieldButton(
            current: () => _controller.placeInFields,
            near: widget.near,
            onPicked: (place) {
              _controller.setPlace(place);
              _changed();
            },
          ),
          gap,
          AppTextField(
            controller: _controller.radiusController,
            label: 'Raza cercului (m)',
            hint: 'Gol = 20',
            keyboardType: TextInputType.number,
            validator: (_) => _controller.radiusError,
            onChanged: (_) => _changed(),
          ),
          gap,
        ],
        if (type == PuzzleType.imageToUpload) ...[
          Text(
            'Echipa trimite o fotografie, iar tu o aprobi din conversație.',
            style: TextStyle(color: context.colors.muted, fontSize: 13),
          ),
          gap,
        ],
        AppTextField(
          controller: _controller.hintController,
          label: 'Indiciu (opțional)',
          hint: 'Un ajutor pentru echipele blocate',
          maxLines: null,
          onChanged: (_) => _changed(),
        ),
      ],
    );
  }
}
