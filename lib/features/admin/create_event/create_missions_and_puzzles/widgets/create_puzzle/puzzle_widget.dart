import 'dart:io';

import 'package:flutter/material.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/create_puzzle/puzzle_controller.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/save_puzzle/save_puzzle.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/model/puzzle.dart';
import 'package:teamxperience/widgets/my_button.dart';

import '../../controller/add_missions_controller.dart';
import '../create_components/add_component_widget.dart';

class PuzzleWidget extends StatefulWidget {
  final Puzzle puzzle;
  final String mode;
  final AddMissionsController addMissionsController;
  final VoidCallback onSave;

  const PuzzleWidget({
    super.key,
    required this.puzzle,
    required this.mode,
    required this.addMissionsController,
    required this.onSave,
  });

  @override
  State<PuzzleWidget> createState() => _PuzzleWidgetState();
}

class _PuzzleWidgetState extends State<PuzzleWidget> {
  late PuzzleController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = PuzzleController();
  }

  void _editComponent(int componentIndex) {
    Component componentToEdit = widget.puzzle.components[componentIndex];
    // Hypothetical method
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddComponentWidget(
              puzzle: widget.puzzle,
              refreshUI: (Widget componentWidget) {
                setState(() {
                  controller.puzzleComponents[componentIndex] = componentWidget;
                });
                Navigator.pop(context);
              },
              component: componentToEdit, // Pass the component to edit
              edit: true,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (controller.puzzleComponents.isNotEmpty) ...[
          const SizedBox(height: 20),

          //background puzzle
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(15.0)),
              image:
                  widget.addMissionsController.event.taskBackgroundImageUrl !=
                          null
                      ? DecorationImage(
                        image: FileImage(
                          File(
                            widget
                                .addMissionsController
                                .event
                                .taskBackgroundImageUrl!,
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
                  controller.puzzleComponents.length,
                  (index) => GestureDetector(
                    onLongPress: () {
                      if (!controller.isDone) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              content: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      _editComponent(index);
                                    },
                                    child: const Text('Edit'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        controller.puzzleComponents.removeAt(index);
                                        widget.puzzle.removeComponent(index);
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child:
                          controller
                              .puzzleComponents[index], // Direct use of the component
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],

        const SizedBox(height: 20),

        // adauga componenta
        Column(
          children: [
            if (!controller.isDone) ...[
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
                            puzzle: widget.puzzle,
                            refreshUI: (Widget componentWidget) {
                              setState(() {
                                controller.puzzleComponents.add(
                                  componentWidget,
                                );
                                controller.componentIndex++;
                              });
                            },
                            component: Component(),
                            edit: false,
                          ),
                    );
                  },
                  withBorder: false,
                  buttonColor: MyColors.lightBlue,
                  buttonWidth: 263,
                ),
              ),
              const SizedBox(height: 15),
              MyButton(
                fontWeight: FontWeight.w500,
                buttonTextSize: 14,
                buttonText: 'Sterge toate componentele',
                textColor: Colors.white,
                buttonOnTap: () {
                  setState(() {
                    controller.puzzleComponents.clear();
                    widget.puzzle.deleteComponents();
                  });
                },
                withBorder: false,
                buttonColor: MyColors.lightBlue,
                buttonWidth: 304,
              ),
              const SizedBox(height: 150),

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
                          puzzle: widget.puzzle,
                          onSave: () {
                            setState(() {
                              controller.isDone = true;
                            });
                            widget.onSave();
                          },
                        ),
                  );
                },
                withBorder: false,
                buttonColor: MyColors.lightBlue,
                buttonWidth: 222,
              ),
            ] else ...[
              // This is the else case - shown when controller.isDone is true
              const SizedBox(height: 20),
              Center(
                child: MyButton(
                  fontWeight: FontWeight.w500,
                  buttonTextSize: 14,
                  buttonText: 'Edit Puzzle',
                  // Or any text you want
                  textColor: Colors.white,
                  buttonOnTap: () {
                    setState(() {
                      controller.isDone = false; // Allow editing again
                    });
                    widget.onSave();

                  },
                  withBorder: false,
                  buttonColor: MyColors.yellow,
                  buttonWidth: 200,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
