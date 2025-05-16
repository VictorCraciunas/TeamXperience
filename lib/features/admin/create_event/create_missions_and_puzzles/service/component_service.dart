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
  }) {
    return Component(
      type: ComponentType.text,
      text: text,
      textColor: textColor,
      animation: animation ?? AnimationType.none,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  Component createImageComponent({
    required String imageUrl,
  }) {
    return Component(
      type: ComponentType.image,
      imageUrl: imageUrl,
    );
  }

  Component createButtonComponent({
    required String buttonLabel,
  }) {
    return Component(
      type: ComponentType.button,
      buttonLabel: buttonLabel,
    );
  }
}