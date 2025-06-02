import 'dart:ui';

import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/create_mission/mission_widget.dart';
import 'package:teamxperience/model/mission.dart';

import '../../../../../model/event.dart';

class AddMissionsController {

  int selectedMission = 0;

  List<MissionWidget> missionWidgets = [];
  List<bool> isMissionDone = [];
  final VoidCallback? onStateChanged;

  late Event event;
  late String mode;


  AddMissionsController(this.event, this.mode, {this.onStateChanged}){
    buildMissionWidgets(event.nrMissions, mode);
  }


  void addNewMission() {
      event.nrMissions += 1; // Increment the count

      Mission missionAdded = Mission(id: event.missions.length.toString());
      event.addMission(missionAdded);
      isMissionDone.add(false);

      addMissionWidget(missionAdded, "create");

  }

  void addMissionWidget(Mission missionAdded, String missionMode){
    missionWidgets.add(MissionWidget(
      currentMission: missionAdded,
      mode: missionMode,
      addMissionsController: this,
      missionDone: (bool isDone) {
        int missionIndex = int.parse(missionAdded.id);
        isMissionDone[missionIndex] = isDone;
        print (isMissionDone[missionIndex]) ;
        onStateChanged?.call();
      },
    ));
  }


  void buildMissionWidgets(int nrMissions, String mode) {
      for (int i = 0; i < nrMissions; i ++){
          addMissionWidget(event.missions[i], mode);
          isMissionDone.add(false);

      }
  }




}
