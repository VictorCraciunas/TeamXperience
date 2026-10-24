
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/create_mission/mission_widget.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/ui/components/feedback/snackbars.dart';

import '../../../../../exceptions/events_exceptions.dart';
import '../../../../../model/event.dart';
import '../../../../../state_management/events_state_management.dart';

/// What to tell the organiser when publishing was refused: the first three
/// problems, one per line, and how many more there are.
String publishFailureMessage(EventNotPublishableException e) {
  final problems = e.problems;
  if (problems.isEmpty) return 'Evenimentul nu este complet';

  final shown = problems.take(3).toList();
  final rest = problems.length - shown.length;
  return [...shown, if (rest > 0) 'și încă $rest'].join('\n');
}

class AddMissionsController {

  int selectedMission = 0;

  List<MissionWidget> missionWidgets = [];
  List<bool> isMissionDone = [];
  final VoidCallback? onStateChanged;

  late Event event;
  late String mode;

  /// True when the event was a draft: saving then publishes it.
  final bool isDraft;

  AddMissionsController(this.event, this.mode, {this.onStateChanged, this.isDraft = false}){
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
          bool missionComplete = _isMissionComplete(event.missions[i]);
          isMissionDone.add(missionComplete);

      }
  }
  bool _isMissionComplete(Mission mission) {
    // If mission has no puzzles, it's not complete
    if (mission.puzzles.isEmpty) {
      return false;
    }

    // Check if all puzzles have a type set
    for (var puzzle in mission.puzzles) {
      if (puzzle.type == null) {
        return false;
      }
    }

    return true;
  }
  Future<void> saveEvent(BuildContext context) async {
    try {

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      final eventList = context.read<EventList>();

      if (isDraft) {
        // Publish the draft: refused with the list of what is missing if not complete.
        await eventList.publishEvent(event);
        if (!context.mounted) return;
        Navigator.of(context).pop();
        MySnackBars.successSnackBar(context, title: "Eveniment publicat !", message: "Evenimentul este acum vizibil pentru jucători");
      } else if (mode == 'edit') {
        // Update existing event
        await eventList.updateEvent(event);
        if (!context.mounted) return;
        Navigator.of(context).pop();
        MySnackBars.successSnackBar(context, title: "Eveniment editat !", message: "Eveniment editat cu success");
      } else {
        // Create new event (EventService will handle all image uploads)
        await eventList.createEvent(event);
        if (!context.mounted) return;
        Navigator.of(context).pop();

        MySnackBars.successSnackBar(context, title: "Eveniment create !", message: "Eveniment creat cu success");

      }

    } on EventNotPublishableException catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // the progress dialog
        MySnackBars.warningSnackBar(
          context,
          title: 'Evenimentul nu poate fi publicat încă',
          message: publishFailureMessage(e),
        );
      }
    } catch (e) {
      print('Error saving event: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save event: $e')),
        );
      }
    }
  }


}
