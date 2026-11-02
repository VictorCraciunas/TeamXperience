import '../enums/animation_type.dart';
import '../enums/component-type.dart';

class Component {
   ComponentType? type;
   String? text;
  String? imageUrl;
   String? buttonLabel;
   String? buttonColor; // New: Initial button background color
   String? buttonColorOnTap; // New: Button background color on tap
   String? buttonTextColor; // New: Initial button text color
   String? buttonTextColorOnTap; // New: Button text color on tap
   String? textColor; // Hex color (e.g., '#FF0000' for red)
   String? borderColor; // Already present for border color
   double? cornerRadius; // New: Corner radius for button
   bool? enableFlicker; // New: Enable flicker animation
   bool? enableGlow; // New: Enable glow effect
   String? glowColor;
   AnimationType? animation;
   double? fontSize;
   String? fontWeight;
   String? fontFamily;
   int? codeLength;
   String? inputType; // "Separated" or "Free"
   String? capsLock; // "CapsLock" or "Fără"
   double? frameCornerRadius; // Corner radius for the frame
   double? inputCornerRadius; // Corner radius for input fields
   String? frameBackgroundColor; // Background color for the frame
   String? inputBackgroundColor; // Background color for input fields
   String? colorBorderInput; // Border color for input fields
   String? colorBorderContainer; // Border color for the container
   double? width;
   double? height;
   int? typewriterSpeed; // ms per character
   String? textAlign;

   /// Space under this component in the game, from 0 to 120. When missing the
   /// usual 40 is used.
   double? spaceBelow;

  Component({
    this.type,
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
    this.fontFamily,
    this.codeLength,
    this.cornerRadius, // New
    this.enableFlicker, // New
    this.enableGlow, // New
    this.glowColor,
    this.inputType,
    this.capsLock,
    this.frameCornerRadius,
    this.inputCornerRadius,
    this.frameBackgroundColor,
    this.inputBackgroundColor,
    this.colorBorderInput,
    this.colorBorderContainer,
    this.height,
    this.width,
    this.typewriterSpeed,
    this.textAlign,
    this.spaceBelow,
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
       animation:
       map['animation'] != null
           ? AnimationType.values.byName(map['animation'] as String)
           : null,
       fontSize: map['fontSize'] as double?,
       fontWeight: map['fontWeight'] as String?,
       fontFamily: map['fontFamily'] as String?,
       codeLength: map['codeLength'] as int?, // FIXED: Added nullable cast
       cornerRadius: map['cornerRadius'] as double?, // New
       enableFlicker: map['enableFlicker'] as bool?, // New
       enableGlow: map['enableGlow'] as bool?, // New
       glowColor: map['glowColor'] as String?, // New
       inputType: map['inputType'] as String?,
       capsLock: map['capsLock'] as String?,
       frameCornerRadius: map['frameCornerRadius'] as double?,
       inputCornerRadius: map['inputCornerRadius'] as double?,
       frameBackgroundColor: map['frameBackgroundColor'] as String?,
       inputBackgroundColor: map['inputBackgroundColor'] as String?,
       colorBorderInput: map['colorBorderInput'] as String?,
       colorBorderContainer: map['colorBorderContainer'] as String?,
       width: map['width'] as double?,
       height: map['height'] as double?,
       typewriterSpeed: map['typewriterSpeed'] as int?,
       textAlign: map['textAlign'] as String?,
       spaceBelow: (map['spaceBelow'] as num?)?.toDouble(),
     );
   }

   Map<String, dynamic> toJson() {
     return {
       if(type != null) 'type': type!.name,
       if (text != null) 'text': text,
       if (imageUrl != null) 'imageUrl': imageUrl,
       if (buttonLabel != null) 'buttonLabel': buttonLabel,
       if (buttonColor != null) 'buttonColor': buttonColor, // FIXED: Added missing fields
       if (buttonColorOnTap != null) 'buttonColorOnTap': buttonColorOnTap,
       if (buttonTextColor != null) 'buttonTextColor': buttonTextColor,
       if (buttonTextColorOnTap != null) 'buttonTextColorOnTap': buttonTextColorOnTap,
       if (borderColor != null) 'borderColor': borderColor,
       if (textColor != null) 'textColor': textColor,
       if (animation != null) 'animation': animation!.name,
       if (fontSize != null) 'fontSize': fontSize,
       if (fontWeight != null) 'fontWeight': fontWeight,
       if (fontFamily != null) 'fontFamily': fontFamily,
       if (codeLength != null) 'codeLength': codeLength,
       if (cornerRadius != null) 'cornerRadius': cornerRadius, // New
       if (enableFlicker != null) 'enableFlicker': enableFlicker, // New
       if (enableGlow != null) 'enableGlow': enableGlow, // New
       if (glowColor != null) 'glowColor': glowColor, // New
       if (inputType != null) 'inputType': inputType,
       if (capsLock != null) 'capsLock': capsLock,
       if (frameCornerRadius != null) 'frameCornerRadius': frameCornerRadius,
       if (inputCornerRadius != null) 'inputCornerRadius': inputCornerRadius,
       if (frameBackgroundColor != null) 'frameBackgroundColor': frameBackgroundColor,
       if (inputBackgroundColor != null) 'inputBackgroundColor': inputBackgroundColor,
       if (colorBorderInput != null) 'colorBorderInput': colorBorderInput,
       if (colorBorderContainer != null) 'colorBorderContainer': colorBorderContainer,
       if (width != null) 'width': width,
       if (height != null) 'height': height,
       if (typewriterSpeed != null) 'typewriterSpeed': typewriterSpeed,
       if (textAlign != null) 'textAlign': textAlign,
       if (spaceBelow != null) 'spaceBelow': spaceBelow,
     };
   }

  @override
  String toString() {
    return 'Component(type: ${type != null ? type!.name : null.toString()}, text: $text, imageUrl: $imageUrl, buttonLabel: $buttonLabel, textColor: $textColor, animation: ${animation?.name}, buttonColor: $buttonColor, buttonColorOnTap: $buttonColorOnTap, buttonTextColor: $buttonTextColor, buttonTextColorOnTap: $buttonTextColorOnTap, borderColor: $borderColor, fontSize: $fontSize, fontWeight: $fontWeight, fontFamily: $fontFamily, codeLength: $codeLength, cornerRadius: $cornerRadius, enableFlicker: $enableFlicker, enableGlow: $enableGlow, glowColor: $glowColor, inputType: $inputType, capsLock: $capsLock, frameCornerRadius: $frameCornerRadius, inputCornerRadius: $inputCornerRadius, frameBackgroundColor: $frameBackgroundColor, inputBackgroundColor: $inputBackgroundColor, colorBorderInput: $colorBorderInput, colorBorderContainer: $colorBorderContainer, width: $width, height: $height)';
  }
}
