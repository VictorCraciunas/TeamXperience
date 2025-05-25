import 'package:teamxperience/enums/puzzle_type.dart';
import 'package:teamxperience/model/component.dart';

class Puzzle {
  final String id;
  PuzzleType type;
  List<Component> components;
  String? code;
  String? coordinates;
  String? indiciu;

  Puzzle({
    required this.id,
    List<Component>? components,
    PuzzleType? type,
    this.code,
    this.coordinates,
    this.indiciu
  }) : components = components ?? [],
        type = type ?? PuzzleType.code;

  int get componentsCount => components.length;

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
    final rawType = data['type'] as String;

    return Puzzle(
      id: data['id'] as String? ?? '',
      components: comps,
      type: PuzzleType.values.byName(rawType),
      code: data['code'] as String?,
      coordinates: data['coordinates'] as String?,
      indiciu: data['indiciu'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'components': components.map((c) => c.toJson()).toList(),
      'type': type.name,
       if (code != null) 'text': code,
      if (coordinates != null) 'text': coordinates,
      if (indiciu != null) 'text': indiciu,

    };
  }
  @override
  String toString() {
    return 'Puzzle(type: ${type.name},id: $id, components: [${components.join(', ')}], code: $code, coordinates" $coordinates, indiciu: $indiciu)';
  }

}
