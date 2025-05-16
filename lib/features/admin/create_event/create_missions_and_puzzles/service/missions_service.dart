import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/service/component_service.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/service/puzzle_service.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/model/puzzle.dart';

import '../../../../../model/mission.dart';

class MissionsService{
  PuzzleService addPuzzleService = PuzzleService();
  ComponentService componentService = ComponentService();
  List<Mission> missions = [];

  List<Mission> initializeMissions(int nrMissions){
    for (int i = 0 ; i < nrMissions; i++){
      Mission mission = Mission(id: i.toString());
      missions.add(mission);
    }
    return missions;
  }

  void initializePuzzleAtMission(int nrPuzzles, int selectedMission){
    List<Puzzle> puzzles = addPuzzleService.initializePuzzles(nrPuzzles);
    missions[selectedMission].puzzles = puzzles;
  }

  Component addComponentAtPuzzleAtMission(int missionSelected, int puzzleSelected, ComponentType type) {
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
    return missions[missionSelected].puzzles[puzzleSelected].addComponent(componentService.createComponent(type));
  }

  void deleteAllComponentsAtPuzzleAtMission(int missionSelected, int puzzleSelected){
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

  void deleteComponentAtPuzzleAtMission(int missionSelected, int puzzleSelected, int componentIndex) {
    if (missions.isEmpty) {
      print("No missions initialized, skipping component delete");
      return;
    }
    if (missionSelected < 0 || missionSelected >= missions.length) {
      print("Mission index out of range: $missionSelected, skipping component delete");
      return;
    }
    if (missions[missionSelected].puzzles.isEmpty) {
      print("No puzzles initialized for mission $missionSelected, skipping component delete");
      return;
    }
    if (puzzleSelected < 0 || puzzleSelected >= missions[missionSelected].puzzles.length) {
      print("Puzzle index out of range: $puzzleSelected, skipping component delete");
      return;
    }
    if (componentIndex < 0 || componentIndex >= missions[missionSelected].puzzles[puzzleSelected].components.length) {
      print("Component index out of range: $componentIndex, skipping delete");
      return;
    }
    print("Deleting component at index $componentIndex for mission $missionSelected, puzzle $puzzleSelected");
    missions[missionSelected].puzzles[puzzleSelected].removeComponent(componentIndex);
  }


}
