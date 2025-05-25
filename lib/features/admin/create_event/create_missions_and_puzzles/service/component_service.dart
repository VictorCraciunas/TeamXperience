import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/model/component.dart';

import '../../../../../enums/animation_type.dart';

class ComponentService{
  Component createTextComponent({
    required String text,
    String? textColor,
    AnimationType? animation,
    double? fontSize,
    String? fontWeight,
    String? fontFamily
  }) {
    return Component(
      type: ComponentType.text,
      text: text,
      textColor: textColor,
      animation: animation ?? AnimationType.none,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontFamily: fontFamily
    );
  }

  Component createImageComponent({
    required String imageUrl,
    double? radius,
    double? height,
  }) {
    return Component(
      type: ComponentType.image,
      imageUrl: imageUrl,
      cornerRadius: radius,
      height: height
    );
  }

  Component createButtonComponent({
    required String buttonLabel,
    String? buttonColor, // Initial button background color
    String? buttonColorOnTap, // Button background color on tap
    String? buttonTextColor, // Initial button text color
    String? buttonTextColorOnTap, // Button text color on tap
    String? borderColor,
    String? fontFamily,
    String? fontWeight,
    double? cornerRadius, // New
    bool? enableFlicker, // New
    bool? enableGlow, // New
    String? glowColor, // New
  }) {
    return Component(
      type: ComponentType.button,
      buttonLabel: buttonLabel,
      buttonColor: buttonColor,
      buttonColorOnTap: buttonColorOnTap,
      buttonTextColor: buttonTextColor,
      buttonTextColorOnTap: buttonTextColorOnTap,
      borderColor: borderColor,
      cornerRadius: cornerRadius, // New
      enableFlicker: enableFlicker, // New
      enableGlow: enableGlow, // New
      glowColor: glowColor, // New
      fontFamily: fontFamily,
      fontWeight: fontWeight
    );
  }
  Component createCodeComponent({
    int? codeLength,
    String? inputType, // "Separated" or "Free"
    String? capsLock, // "CapsLock" or "Fără"
    double? frameCornerRadius,
    double? inputCornerRadius,
    String? frameBackgroundColor,
    String? inputBackgroundColor,
    String? colorBorderInput,
    String? colorBorderContainer,
    bool? enableGlow,
    String? glowColor,
    double? width,
    double? fontSize,
    String? textColor,
    String? fontFamily
  }) {
    return Component(
      type: ComponentType.code,
      codeLength: codeLength,
      inputType: inputType,
      capsLock: capsLock,
      frameCornerRadius: frameCornerRadius,
      inputCornerRadius: inputCornerRadius,
      frameBackgroundColor: frameBackgroundColor,
      inputBackgroundColor: inputBackgroundColor,
      colorBorderInput: colorBorderInput,
      colorBorderContainer: colorBorderContainer,
      enableGlow: enableGlow,
      glowColor: glowColor,
      width: width,
        fontSize: fontSize,
        textColor: textColor,
        fontFamily: fontFamily
    );
  }
}