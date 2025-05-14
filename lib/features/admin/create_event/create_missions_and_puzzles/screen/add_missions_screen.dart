import 'package:flutter/material.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/controller/add_missions_controller.dart';
import 'package:teamxperience/model/event.dart';

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
        _addMissionsController.missionWidgets = _addMissionsController.buildMissionWidgets();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add missions"), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              // list of missions
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _addMissionsController.event!.nrMissions,
                itemBuilder: (context, index) {
                  return _addMissionsController.mission(index, () {
                    setState(() {
                      _addMissionsController.selectedMission = index;
                    });
                  });
                },
              ),
            ),
            //missions widget
            IndexedStack(
              index: _addMissionsController.selectedMission,
              children: _addMissionsController.missionWidgets,
            ),
          ],
        ),
      ),
    );
  }
}
