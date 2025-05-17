import 'dart:io';

import 'package:flutter/material.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/controller/add_missions_controller.dart';
import 'package:teamxperience/model/event.dart';

import '../widgets/my_list_component.dart';

class AddMissionsPage extends StatefulWidget {
  const AddMissionsPage({super.key});

  @override
  State<AddMissionsPage> createState() => _AddMissionsPageState();
}

class _AddMissionsPageState extends State<AddMissionsPage> {
  late AddMissionsController _addMissionsController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _addMissionsController = AddMissionsController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_addMissionsController.event == null) {
      setState(() {
        _addMissionsController.event =
            ModalRoute.of(context)!.settings.arguments as Event;
        _addMissionsController.initializeMissions();
        _addMissionsController.missionWidgets =
            _addMissionsController.buildMissionWidgets();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add missions"), centerTitle: true),
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: _addMissionsController.event?.taskBackgroundImageUrl != null
              ? DecorationImage(
            image: FileImage(
              File(_addMissionsController.event!.taskBackgroundImageUrl),
            ),
            fit: BoxFit.cover,
          )
              : null, // No background if the URL is null
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _addMissionsController.event!.nrMissions,
                  itemBuilder: (context, index) {
                    return MyListComponent(
                      index: index,
                      type: "Mission",
                      isSelected: _addMissionsController.selectedMission == index,
                      onTap: () {
                        setState(() {
                          _addMissionsController.selectedMission = index;
                        });
                      },
                    );
                  },
                ),
              ),
              //missions widget
              IndexedStack(
                index: _addMissionsController.selectedMission,
                children: _addMissionsController.missionWidgets,
              ),
              ElevatedButton(onPressed: () {
                  _addMissionsController.printMissions();
              }, child: Text("print the missions")),
            ],
          ),
        ),
      ),
    );
  }
}
