import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/team.dart';

class TeamRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addTeam(Team team, String eventId) async {
    var docRef = _firestore.collection('events').doc(eventId).collection('teams').doc(team.name);
    await docRef.set(team.toJson());
  }

  Future<void> deleteTeam(String eventId, String teamName) async {
    try {
      await _firestore.collection('events').doc(eventId).collection('teams').doc(teamName).delete();
    } catch (e, stacktrace) {
      print('Error deleting team: $e');
      print('Stack trace: $stacktrace');
      throw Exception('Failed to delete team: $teamName');
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


  // Updated: Use team name as document ID
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

  // Updated: Use team name as document ID
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


  // Check if team name already exists for an event
  Future<bool> isTeamNameTaken(String eventId, String teamName) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('teams')
          .doc(teamName)
          .get();

      return doc.exists;
    } catch (e, stacktrace) {
      print('Error checking team name availability: $e');
      print('Stack trace: $stacktrace');
      return true; // Return true to be safe - assume name is taken if error occurs
    }
  }

  Future<Team?> getUserTeamForEvent(String eventId, String userId) async {
    try {
      // Query teams where userIds array contains the userId
      QuerySnapshot snapshot = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('teams')
          .where('userIds', arrayContains: userId)
          .get();

      // If user is found in any team, return the first one
      // (user should only be in one team per event)
      if (snapshot.docs.isNotEmpty) {
        return Team.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e, stacktrace) {
      print('Error fetching user team for event: $e');
      print('Stack trace: $stacktrace');
      throw Exception('Failed to fetch team for user: $userId in event: $eventId');
    }
  }
  Future<void> startTeam(String eventId, String teamName) async {
    try {
      await _firestore.collection('events').doc(eventId).collection('teams').doc(teamName).update({
        'hasStarted': true,
      });
    } catch (e, stacktrace) {
      print('Error starting team: $e');
      print('Stack trace: $stacktrace');
      throw Exception('Failed to start team: $teamName');
    }
  }

}