import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/team.dart';

class TeamRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getNewTeamId(String eventId) async {
    return _firestore.collection('events').doc(eventId).collection('teams').doc().id;
  }

  Future<void> addTeam(Team team, String eventId, String userId) async {
    var docRef = _firestore.collection('events').doc(eventId).collection('teams').doc(userId);
    await docRef.set(team.toJson());
  }

  Future<void> deleteTeam(String eventId, String userId) async {
    try {
      await _firestore.collection('events').doc(eventId).collection('teams').doc(userId).delete();
    } catch (e, stacktrace) {
      print('Error deleting team: $e');
      print('Stack trace: $stacktrace');
      throw Exception('Failed to delete team for user: $userId');
    }
  }

  Future<List<Team>> getAllTeamsForEvent(String eventId) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('events').doc(eventId).collection('teams').get();

      List<Team> teams = snapshot.docs.map((doc) {
        return Team.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      return teams;
    } catch (e, stacktrace) {
      print('Error fetching teams: $e');
      print('Stack trace: $stacktrace');
      throw Exception('Failed to fetch teams for event: $eventId');
    }
  }

  Future<Team?> getTeamByUserId(String eventId, String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('events').doc(eventId).collection('teams').doc(userId).get();

      if (doc.exists) {
        return Team.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e, stacktrace) {
      print('Error fetching team by user ID: $e');
      print('Stack trace: $stacktrace');
      throw Exception('Failed to fetch team for user: $userId');
    }
  }

  Future<void> updateTeam(Team team, String eventId, String userId) async {
    try {
      var docRef = _firestore.collection('events').doc(eventId).collection('teams').doc(userId);
      await docRef.update(team.toJson());
    } catch (e, stacktrace) {
      print('Error updating team: $e');
      print('Stack trace: $stacktrace');
      throw Exception('Failed to update team for user: $userId');
    }
  }

  Future<void> updateMissionProgress(String eventId, String userId, int progress) async {
    try {
      await _firestore.collection('events').doc(eventId).collection('teams').doc(userId).update({
        'missionProgress': progress,
      });
    } catch (e, stacktrace) {
      print('Error updating mission progress: $e');
      print('Stack trace: $stacktrace');
      throw Exception('Failed to update mission progress for user: $userId');
    }
  }

  Future<void> updatePuzzleNumber(String eventId, String userId, int puzzleNumber) async {
    try {
      await _firestore.collection('events').doc(eventId).collection('teams').doc(userId).update({
        'puzzleNumber': puzzleNumber,
      });
    } catch (e, stacktrace) {
      print('Error updating puzzle number: $e');
      print('Stack trace: $stacktrace');
      throw Exception('Failed to update puzzle number for user: $userId');
    }
  }

  Future<void> addUserToTeam(String eventId, String teamOwnerId, String userId) async {
    try {
      await _firestore.collection('events').doc(eventId).collection('teams').doc(teamOwnerId).update({
        'userIds': FieldValue.arrayUnion([userId])
      });
    } catch (e, stacktrace) {
      print('Error adding user to team: $e');
      print('Stack trace: $stacktrace');
      throw Exception('Failed to add user to team owned by: $teamOwnerId');
    }
  }

  Future<void> removeUserFromTeam(String eventId, String teamOwnerId, String userId) async {
    try {
      await _firestore.collection('events').doc(eventId).collection('teams').doc(teamOwnerId).update({
        'userIds': FieldValue.arrayRemove([userId])
      });
    } catch (e, stacktrace) {
      print('Error removing user from team: $e');
      print('Stack trace: $stacktrace');
      throw Exception('Failed to remove user from team owned by: $teamOwnerId');
    }
  }

  // Additional method to get all teams across all events (if needed)
  Future<List<Team>> getAllTeams() async {
    try {
      List<Team> allTeams = [];

      // Get all events first
      QuerySnapshot eventsSnapshot = await _firestore.collection('events').get();

      // For each event, get its teams
      for (var eventDoc in eventsSnapshot.docs) {
        QuerySnapshot teamsSnapshot = await eventDoc.reference.collection('teams').get();

        List<Team> eventTeams = teamsSnapshot.docs.map((doc) {
          return Team.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();

        allTeams.addAll(eventTeams);
      }

      return allTeams;
    } catch (e, stacktrace) {
      print('Error fetching all teams: $e');
      print('Stack trace: $stacktrace');
      throw Exception('Failed to fetch all teams');
    }
  }
}