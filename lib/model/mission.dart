
import 'package:teamxperience/model/puzzle.dart';

class Mission{
  final String id;
  List<Puzzle> puzzles;

  /// The name of the mission on the event page and in the game ("Scara Pasajului").
  String? title;

  /// One line for the event page ("Numără treptele.").
  String? teaser;

  /// Whether the event page shows this mission before the game; the others
  /// count as secret.
  bool isTeaserPublic;

  /// Where the mission is, for "la 180 m de tine" on the route; optional
  /// (a mission's first location puzzle is used when it has none).
  double? latitude;
  double? longitude;

  Mission({
    required this.id,
    List<Puzzle>? puzzles,
    this.title,
    this.teaser,
    this.isTeaserPublic = false,
    this.latitude,
    this.longitude,
  }) : puzzles = puzzles ?? [];

  /// The same mission under another number.
  Mission withId(String newId) =>
      Mission(
        id: newId,
        puzzles: puzzles,
        title: title,
        teaser: teaser,
        isTeaserPublic: isTeaserPublic,
        latitude: latitude,
        longitude: longitude,
      );


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
      title: map['title'] as String?,
      teaser: map['teaser'] as String?,
      isTeaserPublic: map['isTeaserPublic'] as bool? ?? false,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'puzzles': puzzles.map((p) => p.toJson()).toList(),
      'title': title,
      'teaser': teaser,
      'isTeaserPublic': isTeaserPublic,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }
  @override
  String toString() {
    return 'Mission(id: $id, puzzles: [\n  ${puzzles.join(',\n  ')}\n])';
  }
}