
import 'package:teamxperience/model/puzzle.dart';

class Mission{
  final String id;
  List<Puzzle> puzzles;
  bool published;


  Mission({
    required this.id,
    List<Puzzle>? puzzles,
    this.published = false
  }) : puzzles = puzzles ?? [];


  int get puzzlesCount => puzzles.length;

  Puzzle addPuzzle(Puzzle puzzle) {
    puzzles.add(puzzle);
    return puzzle;
  }


  factory Mission.fromMap(Map<String, dynamic> map) {
    final rawList = map['puzzles'] as List<dynamic>? ?? [];
    final puzzles = rawList.map((e) => Puzzle.fromMap(e as Map<String, dynamic>)).toList();
    return Mission(
      id: map['id'] as String? ?? '',
      puzzles: puzzles,
      published: map ['published'] as bool
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'puzzles': puzzles.map((p) => p.toJson()).toList(),
      'published' : published
    };
  }
  @override
  String toString() {
    return 'Mission(id: $id, published: $published, puzzles: [\n  ${puzzles.join(',\n  ')}\n])';
  }
}