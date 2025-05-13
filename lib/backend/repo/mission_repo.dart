import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/mission.dart';

class MissionRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addMission(String gameId, String missionId, Mission mission) async {
    await _firestore.collection('games').doc(gameId).update({
      'missions.$missionId': mission.toJson(),
    });
  }
}