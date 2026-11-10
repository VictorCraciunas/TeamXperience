
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/model/puzzle.dart';
import 'package:teamxperience/service/event_service/event_completeness.dart';
import 'package:teamxperience/service/event_service/event_status_changes.dart';
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

  /// The event's start pin, if it has one.
  ({double lat, double lng})? get startPlace {
    final lat = event.startLatitude;
    final lng = event.startLongitude;
    return lat == null || lng == null ? null : (lat: lat, lng: lng);
  }

  /// Where a puzzle's map opens: its mission's place, else the event's start.
  ({double lat, double lng})? placeNearMission(int mission) {
    final lat = event.missions[mission].latitude;
    final lng = event.missions[mission].longitude;
    return lat == null || lng == null ? startPlace : (lat: lat, lng: lng);
  }

  AddMissionsController(this.event, this.mode, {this.onStateChanged, this.isDraft = false}) {
    if (mode == 'blueprint') _copyMissionsWithoutAnswers();
  }

  /// A copy of an old event keeps its missions, puzzles and their types but not
  /// the answers, places or hints.
  /// The missions are copied first so the old event is left as it was.
  void _copyMissionsWithoutAnswers() {
    event.missions = [
      for (final mission in event.missions)
        mission.withId(mission.id)
          ..puzzles = [
            for (final puzzle in mission.puzzles)
              Puzzle.fromMap(puzzle.toJson())
                ..code = null
                ..latitude = null
                ..longitude = null
                ..indiciu = null,
          ],
    ];
    event.nrMissions = event.missions.length;
  }

  /// Sets the title, the event-page line and whether the page shows the
  /// mission. Text is trimmed and blank is stored as nothing; fields not given
  /// stay as they are.
  void setMissionText(int index, {String? title, String? teaser, bool? isTeaserPublic}) {
    if (index < 0 || index >= event.missions.length) return;
    final mission = event.missions[index];
    String? clean(String text) => text.trim().isEmpty ? null : text.trim();
    if (title != null) mission.title = clean(title);
    if (teaser != null) mission.teaser = clean(teaser);
    if (isTeaserPublic != null) mission.isTeaserPublic = isTeaserPublic;
    onStateChanged?.call();
  }

  /// Sets where a mission is, or clears it with null.
  void setMissionPlace(int index, ({double lat, double lng})? place) {
    if (index < 0 || index >= event.missions.length) return;
    event.missions[index]
      ..latitude = place?.lat
      ..longitude = place?.lng;
    onStateChanged?.call();
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
      for (var i = 0; i < left.length; i++) left[i].withId(i.toString()),
    ];
    event.nrMissions = event.missions.length;
    onStateChanged?.call();
  }

  /// Moves a mission from [from] to the place [to] (both positions in the list)
  /// and numbers them all again.
  void moveMission(int from, int to) {
    final count = event.missions.length;
    if (from == to || from < 0 || to < 0 || from >= count || to >= count) return;

    final moved = [...event.missions];
    moved.insert(to, moved.removeAt(from));
    event.missions = [
      for (var i = 0; i < moved.length; i++) moved[i].withId(i.toString()),
    ];
    onStateChanged?.call();
  }

  /// Moves a puzzle inside its mission from [from] to [to] and numbers them
  /// all again.
  void movePuzzle(int mission, int from, int to) {
    if (mission < 0 || mission >= event.missions.length) return;

    final puzzles = event.missions[mission].puzzles;
    final count = puzzles.length;
    if (from == to || from < 0 || to < 0 || from >= count || to >= count) return;

    puzzles.insert(to, puzzles.removeAt(from));
    for (var i = 0; i < puzzles.length; i++) {
      puzzles[i] = puzzles[i].withId(i.toString());
    }
    onStateChanged?.call();
  }

  /// Adds a puzzle of [type] to a mission and returns its index, or -1 when
  /// there is no such mission.
  int addPuzzle(int mission, PuzzleType type) {
    if (mission < 0 || mission >= event.missions.length) return -1;

    final puzzles = event.missions[mission].puzzles;
    puzzles.add(Puzzle(id: puzzles.length.toString(), type: type));
    onStateChanged?.call();
    return puzzles.length - 1;
  }

  /// Removes a puzzle and numbers the ones after it again.
  void removePuzzle(int mission, int index) {
    if (mission < 0 || mission >= event.missions.length) return;

    final puzzles = event.missions[mission].puzzles;
    if (index < 0 || index >= puzzles.length) return;

    puzzles.removeAt(index);
    for (var i = 0; i < puzzles.length; i++) {
      puzzles[i] = puzzles[i].withId(i.toString());
    }
    onStateChanged?.call();
  }

  /// What the puzzle row says: the first thing missing, or that it is ready.
  String puzzleStatus(int mission, int index) {
    if (mission < 0 || mission >= event.missions.length) return '';

    final puzzles = event.missions[mission].puzzles;
    if (index < 0 || index >= puzzles.length) return '';

    final issues = puzzleIssues(puzzles[index]);
    if (issues.isEmpty) return 'Gata';

    final first = issues.first.label;
    final text = first[0].toUpperCase() + first.substring(1);
    return issues.length > 1 ? '$text · încă ${issues.length - 1}' : text;
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

  /// Publishes or updates the event. True when it worked, so the screen knows
  /// whether to leave. A new event or a draft has to be complete; an edit of a
  /// live event only must not leave teams stuck.
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
        checkLiveEdit(event);
        await eventList.updateEvent(event);
        if (!context.mounted) return true;
        Navigator.of(context).pop();
        MySnackBars.successSnackBar(context, title: "Eveniment editat !", message: "Eveniment editat cu success");
      } else {
        // EventService handles all image uploads.
        await eventList.publishEvent(event);
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
          title: !isDraft && mode == 'edit' ? 'Evenimentul nu poate fi salvat' : 'Evenimentul nu poate fi publicat încă',
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
