import 'package:cloud_firestore/cloud_firestore.dart';

import '../../enums/photo_approval_status.dart';
import '../../model/team.dart';

class TeamRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Stream<Team> getStreamTeam(String eventId, String teamName) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('teams')
        .doc(teamName)
        .snapshots()
        .map((doc) => Team.fromMap(doc.data() as Map<String, dynamic>));
  }

  Future<void> setPhotoApproval(
    String eventId,
    String teamName,
    String key,
    PhotoApprovalStatus status,
  ) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('teams')
          .doc(teamName)
          .update({'photoApprovals.$key': status.name});
    } catch (e, stacktrace) {
      print('Error updating photo approval: $e');
      print('Stack trace: $stacktrace');
      throw Exception('Failed to set photo approval for team: $teamName');
    }
  }

  Stream<List<Team>> getStreamTeamsForEvent(String eventId) {
    try {
      return _firestore
          .collection('events')
          .doc(eventId)
          .collection('teams')
          .snapshots()
          .map((QuerySnapshot snapshot) {
        return snapshot.docs.map((doc) {
          return Team.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();
      });
    } catch (e, stacktrace) {
      print('Error setting up teams stream: $e');
      print('Stack trace: $stacktrace');
      throw Exception('Failed to set up teams stream for event: $eventId');
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

  Future<void> finishTeam(String eventId, String teamName) async {
    try {
      await _firestore.collection('events').doc(eventId).collection('teams').doc(teamName).update({
        'hasFinished': true,
      });
    } catch (e, stacktrace) {
      print('Error finishing team: $e');
      print('Stack trace: $stacktrace');
      throw Exception('Failed to finish team: $teamName');
    }
  }

  /// Changes only the captain's phone; the rest of the team is not touched.
  Future<void> updateTeamPhone(String eventId, String teamName, String phone) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('teams')
          .doc(teamName)
          .update({'phoneNumber': phone});
    } catch (e, stacktrace) {
      print('Error updating team phone: $e');
      print('Stack trace: $stacktrace');
      throw Exception('Failed to update phone for team: $teamName');
    }
  }

  Future<void> updateTeamLocation(String eventId, String teamName, double latitude, double longitude) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('teams')
          .doc(teamName)
          .update({
        'latitude': latitude,
        'longitude': longitude,
      });
    } catch (e, stacktrace) {
      print('Error updating team location: $e');
      print('Stack trace: $stacktrace');
      throw Exception('Failed to update location for team: $teamName');
    }
  }

}