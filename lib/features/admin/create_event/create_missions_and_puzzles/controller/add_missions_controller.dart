
import 'package:flutter/material.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/service/add_missions_service.dart';
import 'package:teamxperience/model/mission.dart';

import '../../../../../model/event.dart';

class AddMissionsController{
    final AddMissionsService _addMissionsService = AddMissionsService();

    int selectedMission = 0;
    int selectedPuzzle = 0;

    List<Column> missionWidgets = [];
    List<Column> puzzleWidgets = [];

    Event? event;
    late List<TextEditingController> puzzlesCountControllers;

    Widget mission(int index, Function callBack) {
        return GestureDetector(
            onTap: (){
                callBack();
            },
            child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                    color: selectedMission == index
                        ? Colors.blue[100]
                        : Colors.red[200],
                    borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                    'Mission ${index + 1}',
                    style: const TextStyle(fontSize: 16),
                ),
            ),
        );
    }


    List<Mission> initializeMissions(){
        return _addMissionsService.initializeMissions(event!.nrMissions);
    }

    List<Column> createDefaultWidgetMission(){
        return List.generate(
            event!.nrMissions,
                (index) => Column(
                children: [
                    Text('Mission ${index + 1} Details'),
                    TextFormField(
                        controller: puzzlesCountControllers[index],
                        decoration: const InputDecoration(labelText: 'Number of Puzzles for current mission'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                            if (value!.isEmpty) return 'Please enter the number of missions';
                            if (int.tryParse(value) == null) return 'Please enter a valid number';
                            return null;
                        },
                    ),
                    // Placeholder for future puzzle-building widgets
                ],
            ),
        );
    }
}