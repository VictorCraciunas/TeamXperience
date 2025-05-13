
import 'package:teamxperience/model/puzzle.dart';

class Mission{
  final String id;
  final Map<String, Puzzle> puzzles;
  bool isDone ;

  Mission({
    required this.id,
    Map<String, Puzzle>? puzzles,
    this.isDone = false,
  }) : puzzles = puzzles ?? {};


  int get puzzlesCount => puzzles.length;

  void addPuzzle(String puzzleId, Puzzle puzzle) => puzzles[puzzleId] = puzzle;


  factory Mission.fromMap(Map<String, dynamic> map) {
    return Mission(
      id: map['id'] as String? ?? '',
      puzzles: (map['puzzles'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, Puzzle.fromMap(value as Map<String, dynamic>)),
      ) ??
          {},
      isDone: map['isDone'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'puzzles': {for (var entry in puzzles.entries) entry.key: entry.value.toJson()},
      'isDone': isDone,
    };
  }
}