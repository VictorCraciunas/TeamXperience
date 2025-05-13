import 'package:teamxperience/model/component.dart';

class Puzzle {
  final String id;
  final List<Component> components;
  bool isDone;

  Puzzle({
    required this.id,
    List<Component>? components,
    this.isDone = false,
  }) : components = components ?? []; // if the no list is given, initialize with empty list

  int get componentsCount => components.length;

  void addComponent(Component component) => components.add(component);


  factory Puzzle.fromMap(Map<String, dynamic> data) {
    final rawList = data['components'] as List<dynamic>? ?? [];
    final comps = rawList.map((e) => Component.fromMap(e as Map<String, dynamic>)).toList();
    return Puzzle(
      id: data['id'] as String? ?? '',
      components: comps,
      isDone: data['isDone'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'components': components.map((c) => c.toJson()).toList(),
      'isDone': isDone,
    };
  }

}
