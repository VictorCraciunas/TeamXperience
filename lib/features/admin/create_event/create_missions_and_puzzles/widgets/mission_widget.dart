import 'package:flutter/material.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/controller/add_missions_controller.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/puzzle_widget.dart';
import 'package:teamxperience/widgets/my_button.dart';
import 'package:teamxperience/widgets/my_text_field.dart';
import 'my_list_component.dart';

class MissionWidget extends StatefulWidget {
  final int nrMission;
  final Function(int) onSetPuzzles; // Callback to notify parent
  final AddMissionsController addMissionsController;

  const MissionWidget({
    super.key,
    required this.nrMission,
    required this.onSetPuzzles,
    required this.addMissionsController,
  });

  @override
  State<MissionWidget> createState() => _MissionWidgetState();
}

class _MissionWidgetState extends State<MissionWidget> {
  late TextEditingController puzzlesCountController;
  int numberOfPuzzles = 0;
  int selectedPuzzle = -1; // Start with no selection
  List<PuzzleWidget> puzzleWidgets = [];

  @override
  void initState() {
    super.initState();
    puzzlesCountController = TextEditingController();
  }

  @override
  void dispose() {
    puzzlesCountController.dispose();
    super.dispose();
  }

  void _addNewPuzzle() {
    setState(() {
      numberOfPuzzles += 1; // Increment the count
      widget.addMissionsController.addPuzzleAtMission(widget.nrMission); // Add puzzle to the model
      puzzleWidgets.add(PuzzleWidget(
        key: UniqueKey(),
        nrMission: widget.nrMission,
        selectedPuzzle: numberOfPuzzles - 1, // Index of the new puzzle
        addMissionsController: widget.addMissionsController,
      ));
      selectedPuzzle = numberOfPuzzles - 1; // Select the newly added puzzle
    });
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'Detalii Misunea ${widget.nrMission + 1}',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            color: MyColors.blackColor,
            fontWeight: FontWeight.w500,
          ),
        ),

        // set nr puzzles
        const SizedBox(height: 35),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 2,
              child: MyTextField(
                controller: puzzlesCountController,
                labelText: 'Număr de puzzle-uri',
                labelFontWeight: FontWeight.w500,
                labelFontSize: 15,
                hintText: 'Introdu nr de puzzleuri',
                borderWidth: 1.5,
                borderColor: MyColors.lightBlue,
                keyboardType: TextInputType.number,
                radius: 15,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              flex: 1,
              child: MyButton(
                radius: 46,
                buttonText: 'Seteaza',
                textColor: Colors.white,
                buttonOnTap: () {
                  final text = puzzlesCountController.text;
                  final nrPuzzles = int.tryParse(text) ?? 0;
                  widget.onSetPuzzles(nrPuzzles); // initialize puzzles
                  setState(() {
                    numberOfPuzzles = nrPuzzles;
                    selectedPuzzle = -1;
                    puzzleWidgets.clear();
                    puzzleWidgets = List.generate(
                      nrPuzzles,
                      (puzzleSelected) => PuzzleWidget(
                        key: UniqueKey(),
                        nrMission: widget.nrMission,
                        selectedPuzzle: puzzleSelected,
                        addMissionsController: widget.addMissionsController,
                      ),
                    );
                  });
                },
                withBorder: false,
                buttonColor: MyColors.lightBlue,
                fontWeight: FontWeight.w400,
                buttonTextSize: 15,
              ),
            ),
          ],
        ),

        // puzzle list
        if (numberOfPuzzles >= 0) ...[
          const SizedBox(height: 20),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: numberOfPuzzles + 1, // +1 for the "Add Puzzle" button
              itemBuilder: (context, index) {
                if (index < numberOfPuzzles) {
                  return MyListComponent(
                    index: index,
                    type: "Puzzle",
                    isSelected: selectedPuzzle == index,
                    onTap: () {
                      setState(() {
                        selectedPuzzle = index;
                      });
                    },
                  );
                } else {
                  return GestureDetector(
                    onTap: _addNewPuzzle, // Call the method to add a new puzzle
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: MyColors.lightBlue, width: 2),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: MyColors.lightBlue,
                        size: 24,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
        IndexedStack(index: selectedPuzzle, children: puzzleWidgets),
      ],
    );
  }
}
