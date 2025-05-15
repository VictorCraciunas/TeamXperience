import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/service/missions_service.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/mission_widget.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/model/mission.dart';

import '../../../../../model/event.dart';

class AddMissionsController{
    final MissionsService _addMissionsService = MissionsService();

    int selectedMission = 0;

    List<MissionWidget> missionWidgets = [];

    Event? event;


    List<Mission> initializeMissions(){
        return _addMissionsService.initializeMissions(event!.nrMissions);
    }

    List<MissionWidget> buildMissionWidgets() {
        if (event == null) return [];
        return List.generate(
            event!.nrMissions,
                (missionSelected) => MissionWidget(
                nrMission: missionSelected + 1,
                onSetPuzzles: (nrPuzzles) {
                    _addMissionsService.initializePuzzleAtMission(nrPuzzles, missionSelected);
                },
                    addMissionsController: this,
            ),
        );
    }

    Component addComponent(int missionSelected, int puzzleSelected, ComponentType type){
        return _addMissionsService.addComponentAtPuzzleAtMission(missionSelected, puzzleSelected, type);
    }
}