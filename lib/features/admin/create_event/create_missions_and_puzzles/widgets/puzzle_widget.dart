import 'dart:io';

import 'package:flutter/material.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/save_puzzle/save_puzzle.dart';
import 'package:teamxperience/widgets/my_button.dart';

import '../controller/add_missions_controller.dart';
import 'create_components/add_component_widget.dart';

class PuzzleWidget extends StatefulWidget {
  final int
  nrMission; // 1 indexed ( so we need to make -1 when we use list.add)
  final AddMissionsController addMissionsController;
  final int selectedPuzzle;

  const PuzzleWidget({
    super.key,
    required this.nrMission,
    required this.selectedPuzzle,
    required this.addMissionsController,
  });

  @override
  State<PuzzleWidget> createState() => _PuzzleWidgetState();
}

class _PuzzleWidgetState extends State<PuzzleWidget> {
  List<Widget> puzzleComponents = [];
  int componentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (puzzleComponents.isNotEmpty) ...[
          const SizedBox(height: 20),

          //background puzzle
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(15.0)),
              image:
                  widget.addMissionsController.event?.taskBackgroundImageUrl !=
                          null
                      ? DecorationImage(
                        image: FileImage(
                          File(
                            widget
                                .addMissionsController
                                .event!
                                .taskBackgroundImageUrl,
                          ),
                        ),
                        fit: BoxFit.cover,
                      )
                      : null, // No background if the URL is null
            ),

            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: List.generate(
                  puzzleComponents.length,
                  (index) => ListTile(
                    title: puzzleComponents[index],
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          puzzleComponents.removeAt(index);
                          widget.addMissionsController.deleteComponent(
                            widget.nrMission,
                            widget.selectedPuzzle,
                            index,
                          );
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],

        const SizedBox(height: 20),

        // adauga componenta
        Center(
          child: MyButton(
            fontWeight: FontWeight.w500,
            buttonTextSize: 14,
            buttonText: 'Adauga componenta',
            textColor: Colors.white,
            buttonOnTap: () {
              showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder:
                    (context) => AddComponentWidget(
                  addMissionsController: widget.addMissionsController,
                  missionSelected: widget.nrMission,
                  puzzleSelected: widget.selectedPuzzle,
                  refreshUI: (Widget componentWidget) {
                    setState(() {
                      puzzleComponents.add(componentWidget);
                      componentIndex++;
                    });
                  },
                )
              );
            },
            withBorder: false,
            buttonColor: MyColors.lightBlue,
            buttonWidth: 263,
          ),
        ),
        const SizedBox(height: 15,),

        MyButton(
          fontWeight: FontWeight.w500,
          buttonTextSize: 14,
          buttonText: 'Sterge toate componentele',
          textColor: Colors.white,
          buttonOnTap: () {
            setState(() {
              puzzleComponents.clear();
              widget.addMissionsController.deleteAllComponents(
                widget.nrMission,
                widget.selectedPuzzle,
              );
            });
          },
          withBorder: false,
          buttonColor: MyColors.lightBlue,
          buttonWidth: 304,
        ),
        const SizedBox(height: 150,),

        MyButton(
          fontWeight: FontWeight.w500,
          buttonTextSize: 14,
          buttonText: 'Salveaza puzzle',
          textColor: Colors.white,
          buttonOnTap: () {
            showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder:
                  (context) => SavePuzzle(
                nrMission: widget.nrMission,
                selectedPuzzle: widget.selectedPuzzle,
                addMissionsController: widget.addMissionsController,
              ),
            );
          },
          withBorder: false,
          buttonColor: MyColors.lightBlue,
          buttonWidth: 222,
        ),

      ],
    );
  }
}
