
import 'package:flutter/material.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/service/add_missions_service.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/mission_widget.dart';
import 'package:teamxperience/model/mission.dart';

import '../../../../../model/event.dart';

class AddMissionsController{
    final AddMissionsService _addMissionsService = AddMissionsService();

    int selectedMission = 0;

    List<MissionWidget> missionWidgets = [];

    List<Column> puzzleWidgets = [];
    Event? event;


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

    List<MissionWidget> buildMissionWidgets() {
        if (event == null) return [];
        return List.generate(
            event!.nrMissions,
                (index) => MissionWidget(
                nrMission: index + 1,
                onSetPuzzles: (count) {
                    _addMissionsService.initializePuzzleAtMission(count, index);
                },
            ),
        );
    }
}