import 'dart:io';

import 'package:teamxperience/backend/repo/event_repo.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/service/component_service.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/service/puzzle_service.dart';
import 'package:teamxperience/model/event.dart';

import '../../../../../backend/storage/storage_images.dart';
import '../../../../../model/mission.dart';

class MissionsService {
  PuzzleService addPuzzleService = PuzzleService();
  ComponentService componentService = ComponentService();
  EventRepo eventRepo = EventRepo();
  final ImageRepo imageRepo = ImageRepo();

  List<Mission> missions = [];

  List<Mission> initializeMissions(int nrMissions) {
    missions.clear();
    for (int i = 0; i < nrMissions; i++) {
      Mission mission = Mission(id: i.toString());
      missions.add(mission);
    }
    return missions;
  }

  void addMission() {
    missions.add(Mission(id: missions.length.toString()));
  }



  void printMissions() {
    if (missions.isEmpty) {
      print("No missions initialized");
      return;
    }
    print("Missions (${missions.length}):");
    for (int i = 0; i < missions.length; i++) {
      print("Mission $i:\n${missions[i]}");
    }
  }

  Future<void> saveEvent(Event event) async{
    event.missions = missions;
    // String? landingImageUrl = await imageRepo.uploadImage(File(event.landingImageUrl), event.eventId, 'landing');
    String? taskBackgroundImageUrl = await imageRepo.uploadImage(File(event.taskBackgroundImageUrl!), event.eventId,'task_background');

    if (taskBackgroundImageUrl == null) {
      throw Exception("Failed to upload the images");
    }

    // event.landingImageUrl = landingImageUrl;
    event.taskBackgroundImageUrl =taskBackgroundImageUrl;
    int im = 1;
    for (var mission in event.missions) {
      for(var puzzle in mission.puzzles){
        for(var component in puzzle.components){
          if(component.type == ComponentType.image){
            String? componentImageURl = await imageRepo.uploadImage(File(component.imageUrl!), event.eventId, 'component$im');
            im++;
            if (componentImageURl == null) {
              throw Exception("Failed to upload the images");
            }
            component.imageUrl = componentImageURl;
          }
        }
      }
    }
    eventRepo.createEvent(event);
  }
}
