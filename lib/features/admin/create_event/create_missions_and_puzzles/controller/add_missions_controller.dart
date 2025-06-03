import 'dart:io';
import 'dart:ui';

import 'package:teamxperience/backend/repo/event_repo.dart';
import 'package:teamxperience/backend/storage/storage_images.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/create_mission/mission_widget.dart';
import 'package:teamxperience/model/mission.dart';

import '../../../../../model/event.dart';

class AddMissionsController {
  ImageRepo imageRepo = ImageRepo();
  EventRepo eventRepo = EventRepo();

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

  Future<void> saveEvent() async{
    String? backgroundURL = await imageRepo.uploadImage(File(event.taskBackgroundImageUrl!), event.eventId, "background");
    String? landingImage = await imageRepo.uploadImage(File(event.taskBackgroundImageUrl!), event.eventId, "landingImage");

    if(backgroundURL != null && landingImage != null){
      event.taskBackgroundImageUrl =backgroundURL;
      event.landingImageUrl = landingImage;
    }
    eventRepo.createEvent(event);

  }


}
