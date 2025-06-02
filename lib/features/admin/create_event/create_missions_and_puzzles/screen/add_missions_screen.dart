import 'package:flutter/material.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/controller/add_missions_controller.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/widgets/my_button.dart';

import '../../../../../constants/padding.dart';
import '../widgets/my_list_component.dart';

class AddMissionsPage extends StatefulWidget {
  const AddMissionsPage({super.key});

  @override
  State<AddMissionsPage> createState() => _AddMissionsPageState();
}

class _AddMissionsPageState extends State<AddMissionsPage> {
  late AddMissionsController _addMissionsController;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    print("didChangeDependencies called - nameController texttttttttttttttttttttttttttttttttttttttttttttttttttt");

    super.didChangeDependencies();
    if (!_initialized) {
      final args =
      ModalRoute
          .of(context)!
          .settings
          .arguments as Map<String, dynamic>?;
      final Event event = args?['event'];
      final String mode = args?['mode'] ?? "create";

      _addMissionsController = AddMissionsController(
        event,
        mode,
        onStateChanged: () {
          setState(() {}); // Rebuild UI when state changes
        },
      );
      _initialized = true;

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MyPaddings.appHorizontalPadding,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _addMissionsController.event.nrMissions + 1,
                    itemBuilder: (context, index) {
                      if (index < _addMissionsController.event.nrMissions) {
                        print('Building MyListComponent for index $index, isDone: ${_addMissionsController.isMissionDone[index]}');
                        return MyListComponent(
                          index: index,
                          type: "Misiunea",
                          isSelected:
                              _addMissionsController.selectedMission == index,
                          isDone: _addMissionsController.isMissionDone[index],
                          onTap: () {
                            setState(() {
                              _addMissionsController.selectedMission = index;
                            });
                          },
                        );
                      } else {
                        return GestureDetector(
                          onTap: () {
                            _addMissionsController.addNewMission();
                            setState(() {});
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: MyColors.lightBlue,
                                width: 2,
                              ),
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

                //missions widget
                IndexedStack(
                  index: _addMissionsController.selectedMission,
                  children: _addMissionsController.missionWidgets,
                ),

                const SizedBox(height: 20),
                MyButton(
                  buttonText: 'Creeza eveniment',
                  textColor: Colors.white,
                  buttonOnTap: () {},
                  withBorder: false,
                  gradient: MyColors.myGradient,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
