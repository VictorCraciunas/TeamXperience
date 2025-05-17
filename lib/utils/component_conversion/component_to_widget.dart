import 'package:flutter/material.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/utils/component_conversion/text_component_widget.dart';

import 'button_component_widget.dart';
import 'code_component_widget.dart';
import 'image_component_widget.dart';


class ComponentToWidget {
  Widget convert(Component component) {
    switch (component.type) {
      case ComponentType.text:
        return Center(
          child: TextComponentWidget(
            text: component.text ?? '',
            textColor: component.textColor, // Pass hex string directly
            animation: component.animation,
            fontSize: component.fontSize,
            fontWeight: component.fontWeight,
          ),
        );
      case ComponentType.image:
        return Center(
          child: ImageComponentWidget(
            imageUrl: component.imageUrl,
          ),
        );
      case ComponentType.button:
        return Center(
          child: ButtonComponentWidget(
            buttonLabel: component.buttonLabel,
            buttonColor: component.buttonColor,
            buttonColorOnTap: component.buttonColorOnTap,
            buttonTextColor: component.buttonTextColor,
            buttonTextColorOnTap: component.buttonTextColorOnTap,
            borderColor: component.borderColor,
          ),
        );
      case ComponentType.code:
        return Center(child: CodeComponentWidget(component: component));
    }
  }
}