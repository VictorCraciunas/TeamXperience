import 'package:flutter/material.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/save_puzzle/save_puzzle_controller.dart';
import 'package:teamxperience/model/puzzle.dart';
import 'package:teamxperience/ui/components/inputs/my_text_field.dart';
import 'package:teamxperience/ui/components/inputs/my_dropdown/my_dropdown.dart';
import 'package:teamxperience/ui/components/buttons/my_button.dart';

import '../../../../../../constants/padding.dart';
import 'package:teamxperience/ui/components/inputs/my_dropdown/dropdown_item.dart';
import '../../controller/add_missions_controller.dart';

class SavePuzzle extends StatefulWidget {
  final Puzzle puzzle;
  final VoidCallback onSave;


  const SavePuzzle({
    super.key,
    required this.puzzle,
    required this.onSave,

  });

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
        padding: const EdgeInsets.symmetric(
          horizontal: MyPaddings.appHorizontalPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60), // Match top spacing
            // Puzzle Type Dropdown
            MyDropdownField<PuzzleType>(
              labelText: 'Tip Puzzle',
              value: controller.type,
              items: PuzzleType.values
                  .map(
                    (type) => DropdownItem<PuzzleType>(
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
              borderColor: MyColors.lightBlue,
              borderWidth: 1.5,
              radius: 20,
              hint: const Text(
                'Selectează tipul de puzzle',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: MyColors.greyText,
                ),
              ),
            ),
            const SizedBox(height: 20), // Match spacing between fields
            // Code Text Field (conditional)
            if (controller.type == PuzzleType.code) ...[
              MyTextField(
                controller:controller.textColorController,
                labelText: 'Introdu Cod',
                hintText: 'Introdu codul',
                hintTextColor: MyColors.greyText,
                borderColor: MyColors.lightBlue,
                borderWidth: 1.5,
                radius: 20,
                validator:
                    (value) =>
                value == null || value.isEmpty
                    ? 'Introdu un cod'
                    : null,
              ),
              const SizedBox(height: 20), // Match spacing
            ],
            if (controller.type == PuzzleType.geolocation) ...[
              MyTextField(
                controller: controller.latitudeController,
                labelText: 'Latitudine',
                hintText: 'Ex: 45.7833',
                hintTextColor: MyColors.greyText,
                borderColor: MyColors.lightBlue,
                borderWidth: 1.5,
                radius: 20,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Introdu latitudinea' : null,
              ),
              const SizedBox(height: 20),
              MyTextField(
                controller: controller.longitudeController,
                labelText: 'Longitudine',
                hintText: 'Ex: 24.1500',
                hintTextColor: MyColors.greyText,
                borderColor: MyColors.lightBlue,
                borderWidth: 1.5,
                radius: 20,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Introdu longitudinea' : null,
              ),
              const SizedBox(height: 20),
            ],
            MyTextField(
              controller: controller.indiciuController,
              labelText: 'Indiciu',
              hintTextColor: MyColors.greyText,
              borderColor: MyColors.lightBlue,
              borderWidth: 1.5,
              radius: 20,
              maxLines: null,
              validator:
                  (value) =>
              value == null || value.isEmpty
                  ? 'Introdu indiciu'
                  : null,
            ),
            const SizedBox(height: 20), // Match spacing
            // Save Button
            Center(
              child: MyButton(
                buttonText: 'Salvează puzzle',
                textColor: Colors.white,
                buttonOnTap: () {
                  controller.savePuzzle(widget.puzzle, context);
                  widget.onSave();
                  Navigator.pop(context);
                },
                withBorder: false,
                buttonColor: MyColors.lightBlue,
                fontWeight: FontWeight.w500,
                buttonTextSize: 14,
                buttonWidth: 270,
              ),
            ),
            const SizedBox(height: 20), // Match bottom spacing
          ],
        ),
      ),
    );
  }
}