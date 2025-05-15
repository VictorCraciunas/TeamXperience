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



}
