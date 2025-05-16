import '../enums/component-type.dart';

class Component {
  final ComponentType type;
  final String? text;
  final String? imageUrl;
  final String? buttonLabel;

  Component({
    required this.type,
    this.text,
    this.imageUrl,
    this.buttonLabel,
  });

  factory Component.fromMap(Map<String, dynamic> map) {
    final rawType = map['type'] as String;
    return Component(
      type: ComponentType.values.byName(rawType),
      text: map['text'] as String?,
      imageUrl: map['imageUrl'] as String?,
      buttonLabel: map['buttonLabel'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      if (text != null) 'text': text,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (buttonLabel != null) 'buttonLabel': buttonLabel,
    };
  }
  @override
  String toString() {
    return 'Component(type: ${type.name}, text: $text, imageUrl: $imageUrl, buttonLabel: $buttonLabel)';
  }

}
