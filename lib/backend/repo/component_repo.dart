import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/component.dart';

class ComponentRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveComponents(
      String gameId,
      String missionId,
      String puzzleId,
      List<Component> components,
      ) async {
    // Convert the list of components to a list of JSON objects
    final componentJsonList = components.map((c) => c.toJson()).toList();

    // Update the specific components array in the nested structure
    await _firestore.collection('games').doc(gameId).update({
      'missions.$missionId.puzzles.$puzzleId.components': FieldValue.arrayUnion(componentJsonList),
    });
  }

}

