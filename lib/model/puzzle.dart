import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/model/component.dart';

class Puzzle {
  final String id;
  PuzzleType? type;
  List<Component> components;
  String? code;
  double? latitude;
  double? longitude;
  String? indiciu;

  /// How many wrong answers a team gets before a 60 s pause; null = no limit.
  int? maxAttempts;

  /// What players read after a wrong answer; null = "Nu e corect. Mai încearcă."
  String? wrongAnswerMessage;

  /// How close a location puzzle's team must get, in metres (10 to 200).
  int radiusMeters;

  static const int defaultRadius = 20;

  Puzzle({
    required this.id,
    List<Component>? components,
    this.type,
    this.code,
    this.latitude,
    this.longitude,
    this.indiciu,
    this.maxAttempts,
    this.wrongAnswerMessage,
    this.radiusMeters = defaultRadius,
  }) : components = components ?? [];

  int get componentsCount => components.length;

  /// The same puzzle under another number.
  Puzzle withId(String newId) => Puzzle(
    id: newId,
    components: components,
    type: type,
    code: code,
    latitude: latitude,
    longitude: longitude,
    indiciu: indiciu,
    maxAttempts: maxAttempts,
    wrongAnswerMessage: wrongAnswerMessage,
    radiusMeters: radiusMeters,
  );

  Component addComponent(Component component) {
    components.add(component);
    return component;
  }


  void deleteComponents(){
    components.clear();
  }

  void removeComponent(int index){
    components.removeAt(index);
  }


  /// A whole number of at least one; anything else means no limit.
  static int? _limit(Object? value) {
    if (value is! num || value != value.roundToDouble() || value < 1) return null;
    return value.toInt();
  }

  /// A whole number of at least 10 metres; anything else is the default.
  static int _radius(Object? value) {
    if (value is! num || value != value.roundToDouble() || value < 10) return defaultRadius;
    return value.toInt();
  }

  factory Puzzle.fromMap(Map<String, dynamic> data) {
    final rawList = data['components'] as List<dynamic>? ?? [];
    final comps = rawList.map((e) => Component.fromMap(e as Map<String, dynamic>)).toList();
    final rawType = data['type'] as String? ;

    final puzzle = Puzzle(
      id: data['id'] as String? ?? '',
      components: comps,
      type: rawType != null ? PuzzleType.values.byName(rawType) : null,
      code: data['code'] as String?,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      indiciu: data['indiciu'] as String?,
      maxAttempts: _limit(data['maxAttempts']),
      wrongAnswerMessage: data['wrongAnswerMessage'] as String?,
      radiusMeters: _radius(data['radiusMeters']),
    );
    return puzzle;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'components': components.map((c) => c.toJson()).toList(),
        if (type != null) 'type': type!.name,
       if (code != null) 'code': code,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (indiciu != null) 'indiciu': indiciu,
      if (maxAttempts != null) 'maxAttempts': maxAttempts,
      if (wrongAnswerMessage != null) 'wrongAnswerMessage': wrongAnswerMessage,
      if (radiusMeters != defaultRadius) 'radiusMeters': radiusMeters,

    };
  }
  @override
  String toString() {
    return 'Puzzle(type: ${type != null ? type!.name : null.toString()},id: $id, components: [${components.join(', ')}], code: $code, latitude: $latitude, longitude: $longitude, indiciu: $indiciu)';
  }

}
