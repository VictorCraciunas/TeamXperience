import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/save_puzzle/save_puzzle_controller.dart';
import 'package:teamxperience/model/puzzle.dart';
import 'package:teamxperience/ui/components/inputs/app_text_field.dart';
import 'package:teamxperience/ui/components/inputs/app_dropdown.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';

import '../../controller/add_missions_controller.dart';

class SavePuzzle extends StatefulWidget {
  final Puzzle puzzle;
  final VoidCallback onSave;

  const SavePuzzle({super.key, required this.puzzle, required this.onSave});

  @override
  State<SavePuzzle> createState() => _SavePuzzleState();
}

class _SavePuzzleState extends State<SavePuzzle> {
  SavePuzzleController controller = SavePuzzleController();

  @override
  void initState() {
    super.initState();
    controller.loadFromPuzzle(widget.puzzle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60), // Match top spacing
            // Puzzle Type Dropdown
            AppDropdown<PuzzleType>(
              label: 'Tip Puzzle',
              value: controller.type,
              items:
                  PuzzleType.values
                      .map(
                        (type) => AppDropdownItem<PuzzleType>(
                          value: type,
                          label: type.toString().split('.').last,
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  controller.type = value;
                });
              },
              validator:
                  (value) =>
                      value == null ? 'Selectează tipul de puzzle' : null,
              hint: 'Selectează tipul de puzzle',
            ),
            const SizedBox(height: 20), // Match spacing between fields
            // Code Text Field (conditional)
            if (controller.type == PuzzleType.code) ...[
              AppTextField(
                controller: controller.textColorController,
                label: 'Introdu Cod',
                hint: 'Introdu codul',
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Introdu un cod'
                            : null,
              ),
              const SizedBox(height: 20), // Match spacing
            ],
            if (controller.type == PuzzleType.geolocation) ...[
              AppTextField(
                controller: controller.latitudeController,
                label: 'Latitudine',
                hint: 'Ex: 45.7833',
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Introdu latitudinea'
                            : null,
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: controller.longitudeController,
                label: 'Longitudine',
                hint: 'Ex: 24.1500',
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Introdu longitudinea'
                            : null,
              ),
              const SizedBox(height: 20),
            ],
            AppTextField(
              controller: controller.indiciuController,
              label: 'Indiciu',
              maxLines: null,
              validator:
                  (value) =>
                      value == null || value.isEmpty ? 'Introdu indiciu' : null,
            ),
            const SizedBox(height: 20), // Match spacing
            // Save Button
            Center(
              child: SizedBox(
                width: 270,
                child: AppButton(
                  label: 'Salvează puzzle',
                  onPressed: () {
                    controller.savePuzzle(widget.puzzle, context);
                    widget.onSave();
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20), // Match bottom spacing
          ],
        ),
      ),
    );
  }
}
