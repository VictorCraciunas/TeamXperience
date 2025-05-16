import '../enums/animation_type.dart';
import '../enums/component-type.dart';

class Component {
  final ComponentType type;
  final String? text;
  final String? imageUrl;
  final String? buttonLabel;
  final String? textColor; // Hex color (e.g., '#FF0000' for red)
  final AnimationType? animation;
  final double? fontSize;
  final String? fontWeight;

  Component({
    required this.type,
    this.text,
    this.imageUrl,
    this.buttonLabel,
    this.textColor,
    this.animation,
    this.fontSize,
    this.fontWeight,
  });

  factory Component.fromMap(Map<String, dynamic> map) {
    final rawType = map['type'] as String;
    return Component(
      type: ComponentType.values.byName(rawType),
      text: map['text'] as String?,
      imageUrl: map['imageUrl'] as String?,
      buttonLabel: map['buttonLabel'] as String?,
      textColor: map['textColor'] as String?,
      animation: map['animation'] != null ? AnimationType.values.byName(map['animation'] as String) : null,
      fontSize: map['fontSize'] as double?,
      fontWeight: map['fontWeight'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      if (text != null) 'text': text,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (buttonLabel != null) 'buttonLabel': buttonLabel,
      if (textColor != null) 'textColor': textColor,
      if (animation != null) 'animation': animation!.name,
      if(fontSize != null) 'fontSize' : fontSize,
      if(fontWeight != null) 'fontWeight' : fontWeight,
    };
  }
  @override
  String toString() {
    return 'Component(type: ${type.name}, text: $text, imageUrl: $imageUrl, buttonLabel: $buttonLabel, textColor: $textColor, animation: ${animation?.name},fontSize: $fontSize, fontWeight: $fontWeight)';
  }

}
