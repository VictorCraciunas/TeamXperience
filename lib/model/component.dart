import '../enums/animation_type.dart';
import '../enums/component-type.dart';

class Component {
  final ComponentType type;
  final String? text;
  final String? imageUrl;
  final String? buttonLabel;
  final String? buttonColor; // New: Initial button background color
  final String? buttonColorOnTap; // New: Button background color on tap
  final String? buttonTextColor; // New: Initial button text color
  final String? buttonTextColorOnTap; // New: Button text color on tap
  final String? textColor; // Hex color (e.g., '#FF0000' for red)
  final String? borderColor; // Already present for border color
  final AnimationType? animation;
  final double? fontSize;
  final String? fontWeight;
  final int? codeLength; // New: Number of letters for the code component

  Component({
    required this.type,
    this.text,
    this.imageUrl,
    this.buttonLabel,
    this.buttonColor,
    this.buttonColorOnTap,
    this.buttonTextColor,
    this.buttonTextColorOnTap,
    this.borderColor,
    this.textColor,
    this.animation,
    this.fontSize,
    this.fontWeight,
    this.codeLength,
  });

  factory Component.fromMap(Map<String, dynamic> map) {
    final rawType = map['type'] as String;
    return Component(
      type: ComponentType.values.byName(rawType),
      text: map['text'] as String?,
      imageUrl: map['imageUrl'] as String?,
      buttonLabel: map['buttonLabel'] as String?,
      buttonColor: map['buttonColor'] as String?,
      buttonColorOnTap: map['buttonColorOnTap'] as String?,
      buttonTextColor: map['buttonTextColor'] as String?,
      buttonTextColorOnTap: map['buttonTextColorOnTap'] as String?,
      borderColor: map['borderColor'] as String?,
      textColor: map['textColor'] as String?,
      animation: map['animation'] != null ? AnimationType.values.byName(map['animation'] as String) : null,
      fontSize: map['fontSize'] as double?,
      fontWeight: map['fontWeight'] as String?,
      codeLength: map['codeLength'] as int
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
      if(codeLength != null) 'codeLength' : codeLength,

    };
  }
  @override
  String toString() {
    return 'Component(type: ${type.name}, text: $text, imageUrl: $imageUrl, buttonLabel: $buttonLabel, textColor: $textColor, animation: ${animation?.name}, buttonColor: $buttonColor, buttonColorOnTap: $buttonColorOnTap, buttonTextColor: $buttonTextColor, buttonTextColorOnTap: $buttonTextColorOnTap, borderColor: $borderColor, fontSize: $fontSize, fontWeight: $fontWeight, codeLength: $codeLength)';
  }

}
