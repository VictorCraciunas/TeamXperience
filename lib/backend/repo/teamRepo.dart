import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/team.dart';

class TeamRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getNewTeamId(String eventId) async {
    return _firestore.collection('events').doc(eventId).collection('teams').doc().id;
  }

  Future<void> addTeam(Team team, String eventId) async {
    String teamId = _firestore.collection('events').doc(eventId).collection('teams').doc().id;

    var docRef = _firestore.collection('events').doc(eventId).collection('teams').doc(teamId);
    await docRef.set(team.toJson());
  }

  Future<void> deleteTeam(String eventId, String teamName) async {
    try {
      await _firestore.collection('events').doc(eventId).collection('teams').doc(teamName).delete();
    } catch (e, stacktrace) {
      print('Error deleting team: $e');
      print('Stack trace: $stacktrace');
      throw Exception('Failed to delete team with name: $teamName');
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

  Future<Team?> getTeamByName(String eventId, String teamName) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('events').doc(eventId).collection('teams').doc(teamName).get();

      if (doc.exists) {
        return Team.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e, stacktrace) {
      print('Error fetching team by name: $e');
      print('Stack trace: $stacktrace');
      throw Exception('Failed to fetch team with name: $teamName');
    }
  }

  Future<void> updateTeam(Team team, String eventId) async {
    try {
      var docRef = _firestore.collection('events').doc(eventId).collection('teams').doc(team.name);
      await docRef.update(team.toJson());
    } catch (e, stacktrace) {
      print('Error updating team: $e');
      print('Stack trace: $stacktrace');
      throw Exception('Failed to update team with name: ${team.name}');
    }
  }

  Future<void> updateMissionProgress(String eventId, String teamName, int progress) async {
    try {
      await _firestore.collection('events').doc(eventId).collection('teams').doc(teamName).update({
        'missionProgress': progress,
      });
    } catch (e, stacktrace) {
      print('Error updating mission progress: $e');
      print('Stack trace: $stacktrace');
      throw Exception('Failed to update mission progress for team: $teamName');
    }
  }

  Future<void> updatePuzzleNumber(String eventId, String teamName, int puzzleNumber) async {
    try {
      await _firestore.collection('events').doc(eventId).collection('teams').doc(teamName).update({
        'puzzleNumber': puzzleNumber,
      });
    } catch (e, stacktrace) {
      print('Error updating puzzle number: $e');
      print('Stack trace: $stacktrace');
      throw Exception('Failed to update puzzle number for team: $teamName');
    }
  }

  Future<void> addUserToTeam(String eventId, String teamName, String userId) async {
    try {
      await _firestore.collection('events').doc(eventId).collection('teams').doc(teamName).update({
        'userIds': FieldValue.arrayUnion([userId])
      });
    } catch (e, stacktrace) {
      print('Error adding user to team: $e');
      print('Stack trace: $stacktrace');
      throw Exception('Failed to add user to team: $teamName');
    }
  }

  Future<void> removeUserFromTeam(String eventId, String teamName, String userId) async {
    try {
      await _firestore.collection('events').doc(eventId).collection('teams').doc(teamName).update({
        'userIds': FieldValue.arrayRemove([userId])
      });
    } catch (e, stacktrace) {
      print('Error removing user from team: $e');
      print('Stack trace: $stacktrace');
      throw Exception('Failed to remove user from team: $teamName');
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