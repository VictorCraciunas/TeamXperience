import 'package:flutter/material.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/controller/add_missions_controller.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/create_mission/mission_controller.dart';
import 'package:teamxperience/model/mission.dart';
import '../my_list_component.dart';

class MissionWidget extends StatefulWidget {
  final Mission currentMission;
  final String mode;
  final Function(bool isMissionDone) missionDone;

  final AddMissionsController addMissionsController;

  const MissionWidget({
    super.key,
    required this.currentMission,
    required this.mode,
    required this.missionDone,
    required this.addMissionsController,
  });

  @override
  State<MissionWidget> createState() => _MissionWidgetState();
}

class _MissionWidgetState extends State<MissionWidget> {
  late MissionController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = MissionController(widget.currentMission, widget.mode, widget.addMissionsController, widget.missionDone);
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'Detalii Misunea ${int.parse(widget.currentMission.id) + 1}',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            color: MyColors.blackColor,
            fontWeight: FontWeight.w500,
          ),
        ),

        // set nr puzzles
        const SizedBox(height: 35),

        // puzzle list
          const SizedBox(height: 20),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.currentMission.puzzles.length + 1,
              // +1 for the "Add Puzzle" button
              itemBuilder: (context, index) {
                if (index < widget.currentMission.puzzles.length) {
                  return GestureDetector(
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            content: TextButton(
                              onPressed: () {
                                setState(() {
                                  widget.currentMission.puzzles.removeAt(index);
                                  controller.isPuzzleDone.removeAt(index);
                                  controller.puzzleWidgets.removeAt(index);
                                  if(controller.selectedPuzzle >= index && controller.selectedPuzzle > 0){
                                    controller.selectedPuzzle --;
                                  }
                                  else if (widget.currentMission.puzzles.isEmpty){
                                    controller.selectedPuzzle = 0;
                                  }

                                });
                                Navigator.pop(context);
                              },
                              child: const Text('delete'),
                            ),
                          );
                        },
                      );
                    },
                    child: MyListComponent(
                      index: index,
                      type: "Puzzle",
                      isSelected: controller.selectedPuzzle == index,
                      isDone: controller.isPuzzleDone[index],
                      onTap: () {
                        setState(() {
                          controller.selectedPuzzle = index;
                        });
                      },
                    ),
                  );
                } else {
                  return GestureDetector(
                    onTap: () {
                      controller.addNewPuzzle(
                          widget.addMissionsController, widget.currentMission);
                      setState(() {

                      });
                    }, // Call the method to add a new puzzle
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
                  ),);
              }
              },
            ),
          ),
        if (controller.puzzleWidgets.isNotEmpty &&
            controller.selectedPuzzle >= 0 &&
            controller.selectedPuzzle < controller.puzzleWidgets.length)
          IndexedStack(
              index: controller.selectedPuzzle,
              children: controller.puzzleWidgets),
      ],
    );
  }
}
