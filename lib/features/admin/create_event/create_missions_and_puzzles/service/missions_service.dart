import 'dart:io';

import 'package:teamxperience/backend/repo/event_repo.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/service/component_service.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/service/puzzle_service.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/puzzle.dart';

import '../../../../../backend/storage/storage_images.dart';
import '../../../../../enums/animation_type.dart';
import '../../../../../model/mission.dart';

class MissionsService {
  PuzzleService addPuzzleService = PuzzleService();
  ComponentService componentService = ComponentService();
  EventRepo eventRepo = EventRepo();
  final ImageRepo imageRepo = ImageRepo();

  List<Mission> missions = [];

  List<Mission> initializeMissions(int nrMissions) {
    for (int i = 0; i < nrMissions; i++) {
      Mission mission = Mission(id: i.toString());
      missions.add(mission);
    }
    return missions;
  }

  void initializePuzzleAtMission(int nrPuzzles, int selectedMission) {
    List<Puzzle> puzzles = addPuzzleService.initializePuzzles(nrPuzzles);
    missions[selectedMission].puzzles = puzzles;
  }

  Component addComponentAtPuzzleAtMission(
      int missionSelected,
      int puzzleSelected,
      ComponentType type, {
        String? text,
        String? textColor,
        AnimationType? animation,
        String? imageUrl,
        String? buttonLabel,
        String? buttonColor, // New
        String? buttonColorOnTap, // New
        String? buttonTextColor, // New
        String? buttonTextColorOnTap, // New
        String? borderColor,
        double? fontSize,
        String? fontWeight,
        int? codeLength,
      }) {
    if (missions.isEmpty) {
      throw Exception("No missions initialized");
    }
    if (missionSelected < 0 || missionSelected >= missions.length) {
      throw Exception("Mission index out of range: $missionSelected");
    }
    if (missions[missionSelected].puzzles.isEmpty) {
      throw Exception("No puzzles initialized for mission $missionSelected");
    }
    if (puzzleSelected < 0 || puzzleSelected >= missions[missionSelected].puzzles.length) {
      throw Exception("Puzzle index out of range: $puzzleSelected");
    }

    Component component;
    switch (type) {
      case ComponentType.text:
        if (text == null || text.isEmpty) {
          throw Exception("Text is required for text component");
        }
        component = componentService.createTextComponent(
          text: text,
          textColor: textColor,
          animation: animation,
          fontSize: fontSize,
          fontWeight: fontWeight,
        );
        break;
      case ComponentType.image:
        if (imageUrl == null || imageUrl.isEmpty) {
          throw Exception("Image URL is required for image component");
        }
        component = componentService.createImageComponent(
          imageUrl: imageUrl,
        );
        break;
      case ComponentType.button:
        if (buttonLabel == null || buttonLabel.isEmpty) {
          throw Exception("Button label is required for button component");
        }
        component = componentService.createButtonComponent(
          buttonLabel: buttonLabel,
          buttonColor: buttonColor,
          buttonColorOnTap: buttonColorOnTap,
          buttonTextColor: buttonTextColor,
          buttonTextColorOnTap: buttonTextColorOnTap,
          borderColor: borderColor
        );
        break;
      case ComponentType.code:
        component = componentService.createCodeComponent(codeLength: codeLength);
        break;
    }

    return missions[missionSelected].puzzles[puzzleSelected].addComponent(component);
  }

  void deleteAllComponentsAtPuzzleAtMission(
    int missionSelected,
    int puzzleSelected,
  ) {
    missions[missionSelected].puzzles[puzzleSelected].deleteComponents();
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

  void setPuzzleTypeAtPuzzleAtMission(
      int missionSelected,
      int puzzleSelected,
      PuzzleType type,
      String? code
      ){
    missions[missionSelected].puzzles[puzzleSelected].type = type;
    missions[missionSelected].puzzles[puzzleSelected].code = code;
  }

  void deleteComponentAtPuzzleAtMission(
    int missionSelected,
    int puzzleSelected,
    int componentIndex,
  ) {
    if (missions.isEmpty) {
      print("No missions initialized, skipping component delete");
      return;
    }
    if (missionSelected < 0 || missionSelected >= missions.length) {
      print(
        "Mission index out of range: $missionSelected, skipping component delete",
      );
      return;
    }
    if (missions[missionSelected].puzzles.isEmpty) {
      print(
        "No puzzles initialized for mission $missionSelected, skipping component delete",
      );
      return;
    }
    if (puzzleSelected < 0 ||
        puzzleSelected >= missions[missionSelected].puzzles.length) {
      print(
        "Puzzle index out of range: $puzzleSelected, skipping component delete",
      );
      return;
    }
    if (componentIndex < 0 ||
        componentIndex >=
            missions[missionSelected]
                .puzzles[puzzleSelected]
                .components
                .length) {
      print("Component index out of range: $componentIndex, skipping delete");
      return;
    }
    print(
      "Deleting component at index $componentIndex for mission $missionSelected, puzzle $puzzleSelected",
    );
    missions[missionSelected].puzzles[puzzleSelected].removeComponent(
      componentIndex,
    );
  }

  Future<void> saveEvent(Event event) async{
    event.missions = missions;
    // String? landingImageUrl = await imageRepo.uploadImage(File(event.landingImageUrl), event.eventId, 'landing');
    String? taskBackgroundImageUrl = await imageRepo.uploadImage(File(event.taskBackgroundImageUrl), event.eventId,'task_background');

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
