import 'package:teamxperience/features/event_game/logic/preview_team.dart';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/state_management/user_provider.dart';
import 'package:teamxperience/features/event_game/logic/route_texts.dart';
import 'package:teamxperience/features/event_game/logic/style_hints.dart';
import 'package:teamxperience/features/event_game/logic/trail_layout.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/service/event_service/event_service.dart';
import 'package:teamxperience/service/team_service/team_service.dart';

import '../../../enums/missions_state.dart';
import '../../../service/LocationService.dart';

class EventGameController extends ChangeNotifier {
  late Event event;
  /// The organiser's picture behind the puzzles, or null.
  ImageProvider? background;
  late BuildContext context;
  late Team? team;
  List<MissionState> missionDone = [];
  final LocationService _locationService = LocationService();
  final EventService _eventService = EventService();
  final TeamService _teamService = TeamService();

  StreamSubscription<Event>? _eventSubscription;
  StreamSubscription<Team>? _teamWatch;
  StreamSubscription<List<Team>>? _rankingWatch;
  Timer? _tick;

  /// The current time, ticking every second for the header's clocks.
  final ValueNotifier<DateTime> now = ValueNotifier(DateTime.now());

  /// The organiser's throwaway team in a walk-through (the route opened with no
  /// team): it lives on this phone and has no stream, location or finish.
  late Team? previewTeam = team == null ? previewTeamOf() : null;

  bool get isPreview => team == null;

  /// The team's place among every team; null until the first ranking.
  ({int place, int teams})? place;
  Timer? _deadlineTimer;
  bool _eventEnded = false;
  bool get eventEnded => _eventEnded;

  EventGameController(this.event, this.team, this.context) {
    _initializeBackground();
    initMissionState();
    _startLocationTracking();
    _watchEventDeadline();
    _watchTeam();
    watchRanking(true);
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => now.value = DateTime.now());
  }

  /// Follows the team doc: progress from teammates' phones and the position
  /// `LocationService` writes.
  void _watchTeam() {
    final t = team;
    if (t == null) return;
    _teamWatch = _teamService.getStreamTeam(event.eventId, t.name).listen(takeTeam, onError: (Object _) {});
  }

  /// A fresher copy of the team (from the stream or back from a puzzle).
  void takeTeam(Team fresh) {
    if (_disposed) return;
    if (isPreview) {
      previewTeam = fresh;
      notifyListeners();
      return;
    }
    team = fresh;
    initMissionState();
    notifyListeners();
  }

  /// Streams every team for the place line, only while the route is on top
  /// (paused while a puzzle is open).
  void watchRanking(bool on) {
    _rankingWatch?.cancel();
    _rankingWatch = null;
    final t = team;
    if (!on || t == null) return;
    _rankingWatch = _teamService.getStreamTeams(event.eventId).listen((teams) {
      if (_disposed) return;
      place = placeOf(teams, t.name, event.missions.length);
      notifyListeners();
    }, onError: (Object _) {});
  }

  /// "Vulpile · locul 2 din 12", or null before the ranking.
  String? get placeText {
    if (isPreview) return previewLine;
    final p = place;
    final t = team;
    if (p == null || t == null) return null;
    return placeLine(t.name, p.place, p.teams);
  }

  /// The mission the team is on, by index.
  int get currentMission => (team ?? previewTeam)?.missionProgress ?? 0;

  /// The trail's stops, with the distance from the team's last position to
  /// the current mission.
  List<TrailStop> get stops {
    final t = team;
    final missions = event.missions;
    final index = currentMission;
    final target = index < missions.length ? missionPoint(missions[index]) : null;
    final from = t == null ? null : (lat: t.latitude, lng: t.longitude);
    return trailStops(event, index, distanceLine(from, target));
  }

  /// Marks [uid] as seen playing now, for the live Home's "jucători activi".
  Future<void> markPresent(String uid) async {
    final t = team;
    if (t == null) return;
    await _teamService.markPresent(event.eventId, t.name, uid);
  }


  void _startLocationTracking() async {
    final t = team;
    if (t != null) {
      await _locationService.startLocationTracking(
        eventId: event.eventId,
        teamName: t.name,
        uid: context.read<UserProvider>().currentUser?.uid,
      );
    }
  }

  void _watchEventDeadline() {
    final start = event.dateEvent;
    // An organiser may walk through any event, also one that is over.
    if (start == null || team == null) return;

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
      _teamService.finishTeam(event.eventId, t.name, completed: false);
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

  void _initializeBackground() {
    final image = gameBackgroundOf(event);
    background = image;
    if (image != null) precacheImage(image, context);
  }

  MissionState getMissionState(int index) {
    return missionDone[index];
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _tick?.cancel();
    _teamWatch?.cancel();
    _rankingWatch?.cancel();
    now.dispose();
    _deadlineTimer?.cancel();
    _eventSubscription?.cancel();
    print("location tracking ended");
    _locationService.stopLocationTracking();
    super.dispose();
  }
}
