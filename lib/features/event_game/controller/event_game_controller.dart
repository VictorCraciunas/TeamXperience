import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/service/event_service/event_service.dart';
import 'package:teamxperience/service/team_service/team_service.dart';

import '../../../enums/missions_state.dart';
import '../../../service/LocationService.dart';

class EventGameController extends ChangeNotifier {
  late Event event;
  late ImageProvider background;
  late BuildContext context;
  late Team? team;
  List<MissionState> missionDone = [];
  final LocationService _locationService = LocationService();
  final EventService _eventService = EventService();
  final TeamService _teamService = TeamService();

  StreamSubscription<Event>? _eventSubscription;
  Timer? _deadlineTimer;
  bool _eventEnded = false;
  bool get eventEnded => _eventEnded;

  EventGameController(this.event, this.team, this.context) {
    _initializeBackground();
    initMissionState();
    _startLocationTracking();
    _watchEventDeadline();
  }


  void _startLocationTracking() async {
    final t = team;
    if (t != null) {
      await _locationService.startLocationTracking(
        eventId: event.eventId,
        teamName: t.name,
      );
    }
  }

  void _watchEventDeadline() {
    final start = event.dateEvent;
    if (start == null) return;

    if (event.isOver) {
      _triggerEventEnded();
      return;
    }

    final remaining = start.add(Event.maxDuration).difference(DateTime.now());
    _deadlineTimer = Timer(remaining, _triggerEventEnded);
    _eventSubscription = _eventService.streamEvent(event.eventId).listen((
      updatedEvent,
    ) {
      if (updatedEvent.isStopped) _triggerEventEnded();
    });
  }

  void _triggerEventEnded() {
    if (_eventEnded) return;
    _eventEnded = true;
    _deadlineTimer?.cancel();
    _eventSubscription?.cancel();

    final t = team;
    if (t != null && !t.hasFinished) {
      _teamService.finishTeam(event.eventId, t.name);
      t.hasFinished = true;
    }
    notifyListeners();
  }
  void initMissionState() {
    missionDone.clear();
    if (team != null) {
      for (int i = 0; i < event.nrMissions; i++) {
        if (i < team!.missionProgress) {
          missionDone.add(MissionState.finalizata);
        } else if (i == team!.missionProgress) {
          missionDone.add(MissionState.deblcata);
        } else {
          missionDone.add(MissionState.blocata);
        }
      }
    }
    else{
      for (int i = 0; i < event.nrMissions; i++) {
        missionDone.add(MissionState.blocata);
      }
    }
  }

  void _initializeBackground() async {
    if (event.taskBackgroundImageUrl != null &&
        event.taskBackgroundImageUrl!.isNotEmpty) {
      if (_isUrl(event.taskBackgroundImageUrl!)) {
        background = NetworkImage(event.taskBackgroundImageUrl!);
      } else {
        // Assuming it's a local file path
        background = AssetImage(event.taskBackgroundImageUrl!);
        // Or use FileImage if it's a file system path:
        // background = FileImage(File(event.taskBackgroundImageUrl!));
      }
    } else {
      // Fallback to a default background
      background = const AssetImage('assets/images/default_background.png');
    }
    precacheImage(background, context);
  }

  bool _isUrl(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  MissionState getMissionState(int index) {
    return missionDone[index];
  }

  @override
  void dispose() {
    _deadlineTimer?.cancel();
    _eventSubscription?.cancel();
    print("location tracking ended");
    _locationService.stopLocationTracking();
    super.dispose();
  }
}
