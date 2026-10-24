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

  /// What players are told after a wrong answer; null means the game's standard message.
  String? wrongAnswerMessage;

  Puzzle({
    required this.id,
    List<Component>? components,
    this.type,
    this.code,
    this.latitude,
    this.longitude,
    this.indiciu,
    this.wrongAnswerMessage,
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
    wrongAnswerMessage: wrongAnswerMessage,
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
      wrongAnswerMessage: data['wrongAnswerMessage'] as String?,
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
      if (wrongAnswerMessage != null) 'wrongAnswerMessage': wrongAnswerMessage,

    };
  }
  @override
  String toString() {
    return 'Puzzle(type: ${type != null ? type!.name : null.toString()},id: $id, components: [${components.join(', ')}], code: $code, latitude: $latitude, longitude: $longitude, indiciu: $indiciu)';
  }

}
