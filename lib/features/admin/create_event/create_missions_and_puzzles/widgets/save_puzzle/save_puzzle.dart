import 'package:flutter/material.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/save_puzzle/save_puzzle_controller.dart';
import 'package:teamxperience/widgets/my_text_field.dart';
import 'package:teamxperience/widgets/my_dropdown.dart';
import 'package:teamxperience/widgets/my_button.dart';

import '../../../../../../constants/padding.dart';
import '../../controller/add_missions_controller.dart';

class SavePuzzle extends StatefulWidget {
  final int nrMission; // 1 indexed (so we need to make -1 when we use list.add)
  final AddMissionsController addMissionsController;
  final int selectedPuzzle;

  const SavePuzzle({
    super.key,
    required this.nrMission,
    required this.selectedPuzzle,
    required this.addMissionsController,
  });

  @override
  State<SavePuzzle> createState() => _SavePuzzleState();
}

class _SavePuzzleState extends State<SavePuzzle> {
  SavePuzzleController controller = SavePuzzleController();


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
              labelText: 'Tip Eveniment',
              value: controller.type,
              items:
                  PuzzleType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(
                            type.toString().split('.').last,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
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
              selectedItemStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.black,
              ),
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
                controller:controller.textColorController,
                labelText: 'Introdu coordonatele',
                hintText: 'Introdu coordonatele',
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
                    controller.savePuzzle(widget.addMissionsController, widget.nrMission, widget.selectedPuzzle, context);
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
