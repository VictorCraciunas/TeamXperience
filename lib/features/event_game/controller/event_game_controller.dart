import 'package:flutter/cupertino.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

import '../../../enums/missions_state.dart';
import '../../../service/LocationService.dart';

class EventGameController {
  late Event event;
  late ImageProvider background;
  late BuildContext context;
  late Team? team;
  List<MissionState> missionDone = [];
  final LocationService _locationService = LocationService();

  EventGameController(this.event, this.team, this.context) {
    _initializeBackground();
    initMissionState();
    _startLocationTracking(); // Start location tracking
  }


  void _startLocationTracking() async {
    if (team != null) {
      await _locationService.startLocationTracking(
        eventId: event.eventId,
        teamName: team!.name,
      );
    }
  }
  void initMissionState() {
    missionDone.clear();
    if (team != null) {
      for (int i = 0; i < team!.missionProgress; i++) {
        missionDone.add(MissionState.finalizata);
      }
      missionDone.add(MissionState.deblcata);
      for (int i = team!.missionProgress; i < event.nrMissions; i++) {
        missionDone.add(MissionState.blocata);
      }
    }
    else{
      print("oare nu intra aici ?????????????????????");
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
  void dispose() {
    print("location tracking ended");
    _locationService.stopLocationTracking();
  }
}
