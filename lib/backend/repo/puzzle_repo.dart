import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/puzzle.dart';

class PuzzleRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addPuzzle(String gameId, String missionId, String puzzleId, Puzzle puzzle) async {
    await _firestore.collection('games').doc(gameId).update({
      'missions.$missionId.puzzles.$puzzleId': puzzle.toJson(),
    });
  }
}