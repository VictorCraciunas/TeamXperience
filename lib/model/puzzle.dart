import 'package:teamxperience/model/component.dart';

class Puzzle {
  final String id;
  List<Component> components;

  Puzzle({
    required this.id,
    List<Component>? components,
  }) : components = components ?? []; // if the no list is given, initialize with empty list

  int get componentsCount => components.length;

  Component addComponent(Component component) {
    components.add(component);
    return component;
  }

  void deleteComponents(){
    components.clear();
  }


  factory Puzzle.fromMap(Map<String, dynamic> data) {
    final rawList = data['components'] as List<dynamic>? ?? [];
    final comps = rawList.map((e) => Component.fromMap(e as Map<String, dynamic>)).toList();
    return Puzzle(
      id: data['id'] as String? ?? '',
      components: comps,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'components': components.map((c) => c.toJson()).toList(),
    };
  }
  @override
  String toString() {
    return 'Puzzle(id: $id, components: [${components.join(', ')}])';
  }

}
