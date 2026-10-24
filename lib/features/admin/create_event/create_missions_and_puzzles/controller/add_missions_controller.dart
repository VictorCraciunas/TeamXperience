
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/puzzle.dart';
import 'package:teamxperience/service/event_service/event_completeness.dart';
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
  final VoidCallback? onStateChanged;

  late Event event;
  late String mode;

  /// True when the event was a draft: saving then publishes it.
  final bool isDraft;

  AddMissionsController(this.event, this.mode, {this.onStateChanged, this.isDraft = false}) {
    if (mode == 'blueprint') _copyMissionsWithoutAnswers();
  }

  /// A copy of an old event keeps its missions and puzzles but not the answers.
  /// The missions are copied first so the old event is left as it was.
  void _copyMissionsWithoutAnswers() {
    event.missions = [
      for (final mission in event.missions)
        Mission(
          id: mission.id,
          puzzles: [
            for (final puzzle in mission.puzzles)
              Puzzle.fromMap(puzzle.toJson())
                ..type = null
                ..code = null
                ..latitude = null
                ..longitude = null
                ..indiciu = null,
          ],
        ),
    ];
    event.nrMissions = event.missions.length;
  }

  void addNewMission() {
    event.addMission(Mission(id: event.missions.length.toString()));
    event.nrMissions = event.missions.length;
    onStateChanged?.call();
  }

  /// Removes a mission and numbers the ones after it again.
  void removeMission(int index) {
    if (index < 0 || index >= event.missions.length) return;

    final left = [...event.missions]..removeAt(index);
    event.missions = [
      for (var i = 0; i < left.length; i++) Mission(id: i.toString(), puzzles: left[i].puzzles),
    ];
    event.nrMissions = event.missions.length;
    onStateChanged?.call();
  }

  bool isDone(int index) {
    if (index < 0 || index >= event.missions.length) return false;
    return isMissionComplete(event.missions[index]);
  }

  /// What the mission card says: the first thing missing, or that it is ready.
  String statusText(int index) {
    if (index < 0 || index >= event.missions.length) return '';

    final problems = missionProblems(event.missions[index]);
    if (problems.isEmpty) return 'Gata';
    final more = problems.length > 1 ? ' · încă ${problems.length - 1}' : '';
    return '${problems.first.text}$more';
  }

  /// Creates, updates or publishes the event. True when it worked, so the
  /// screen knows whether to leave.
  Future<bool> saveEvent(BuildContext context) async {
    _showProgress(context);
    final eventList = context.read<EventList>();

    try {
      if (isDraft) {
        // Refused with the list of what is missing if the event is not complete.
        await eventList.publishEvent(event);
        if (!context.mounted) return true;
        Navigator.of(context).pop();
        MySnackBars.successSnackBar(context, title: "Eveniment publicat !", message: "Evenimentul este acum vizibil pentru jucători");
      } else if (mode == 'edit') {
        await eventList.updateEvent(event);
        if (!context.mounted) return true;
        Navigator.of(context).pop();
        MySnackBars.successSnackBar(context, title: "Eveniment editat !", message: "Eveniment editat cu success");
      } else {
        // EventService handles all image uploads.
        await eventList.createEvent(event);
        if (!context.mounted) return true;
        Navigator.of(context).pop();
        MySnackBars.successSnackBar(context, title: "Eveniment create !", message: "Eveniment creat cu success");
      }
      return true;
    } on EventNotPublishableException catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // the progress dialog
        MySnackBars.warningSnackBar(
          context,
          title: 'Evenimentul nu poate fi publicat încă',
          message: publishFailureMessage(e),
        );
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // the progress dialog
        MySnackBars.warningSnackBar(context, title: 'Nu s-a putut salva', message: '$e');
      }
      return false;
    }
  }

  /// Keeps the event as a draft, however much of it is filled in.
  Future<bool> saveDraft(BuildContext context) async {
    _showProgress(context);
    final eventList = context.read<EventList>();

    try {
      await eventList.saveDraft(event, wizardStep: 2);
      if (!context.mounted) return true;
      Navigator.of(context).pop();
      MySnackBars.successSnackBar(context, title: 'Ciornă salvată', message: 'O găsești pe pagina principală');
      return true;
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        MySnackBars.warningSnackBar(context, title: 'Nu s-a putut salva ciorna', message: '$e');
      }
      return false;
    }
  }

  void _showProgress(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }
}
