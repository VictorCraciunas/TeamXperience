import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/service/add_puzzle_service.dart';
import 'package:teamxperience/model/puzzle.dart';

import '../../../../../model/mission.dart';

class AddMissionsService{
  AddPuzzleService addPuzzleService = AddPuzzleService();
  List<Mission> missions = [];

  List<Mission> initializeMissions(int nrMissions){
    for (int i = 0 ; i < nrMissions; i++){
      Mission mission = Mission(id: i.toString());
      missions.add(mission);
    }
    return missions;
  }

  void initializePuzzleAtMission(int nrPuzzles, int selectedMission){
    Map<String, Puzzle> puzzles = addPuzzleService.initializePuzzles(nrPuzzles, selectedMission);
    missions[selectedMission].puzzles = puzzles;
  }



}
