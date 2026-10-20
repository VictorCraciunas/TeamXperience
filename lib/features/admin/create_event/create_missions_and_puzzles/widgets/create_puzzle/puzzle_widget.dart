import 'dart:io';

import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/create_puzzle/puzzle_controller.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/save_puzzle/save_puzzle.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/model/puzzle.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';

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
    controller = PuzzleController(widget.puzzle);
  }

  void _showEditDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: context.colors.panel,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => _editComponent(index),
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
                        image:
                            controller.isUrl(
                                  widget
                                      .addMissionsController
                                      .event
                                      .taskBackgroundImageUrl!,
                                )
                                ? NetworkImage(
                                  widget
                                      .addMissionsController
                                      .event
                                      .taskBackgroundImageUrl!,
                                ) // Use NetworkImage for URLs
                                : FileImage(
                                      File(
                                        widget
                                            .addMissionsController
                                            .event
                                            .taskBackgroundImageUrl!,
                                      ),
                                    )
                                    as ImageProvider, // Use FileImage for local paths
                        fit: BoxFit.cover,
                      )
                      : null, // No background if the URL is null
            ),

            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: List.generate(controller.puzzleComponents.length, (
                  index,
                ) {
                  final isCodeComponent =
                      index < widget.puzzle.components.length &&
                      widget.puzzle.components[index].type ==
                          ComponentType.code;
                  final isEditMode = !controller.isDone;

                  Widget child = Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: controller.puzzleComponents[index],
                  );

                  if (isEditMode && isCodeComponent) {
                    return Stack(
                      children: [
                        IgnorePointer(child: child),
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onLongPress: () => _showEditDialog(index),
                          ),
                        ),
                      ],
                    );
                  }

                  return GestureDetector(
                    onLongPress:
                        isEditMode ? () => _showEditDialog(index) : null,
                    child: child,
                  );
                }),
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
                child: SizedBox(
                  width: 263,
                  child: AppButton(
                    label: 'Adaugă componentă',
                    onPressed: () {
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
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: 304,
                child: AppButton(
                  label: 'Șterge toate componentele',
                  onPressed: () {
                    setState(() {
                      controller.puzzleComponents.clear();
                      widget.puzzle.deleteComponents();
                    });
                  },
                ),
              ),
              const SizedBox(height: 150),

              SizedBox(
                width: 222,
                child: AppButton(
                  label: 'Salvează puzzle',
                  onPressed: () {
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
                ),
              ),
            ] else ...[
              // This is the else case - shown when controller.isDone is true
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: 200,
                  child: AppButton(
                    label: 'Edit Puzzle',
                    onPressed: () {
                      setState(() {
                        controller.isDone = false; // Allow editing again
                      });
                      widget.onSave();
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
