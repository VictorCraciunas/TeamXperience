import 'package:flutter/material.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/utils/component_conversion/text_component_widget.dart';

import 'button_component_widget.dart';
import 'full_width.dart';
import 'code_component_widget.dart';
import 'image_component_widget.dart';


class ComponentToWidget {
  Widget convert(Component component, {
    Function(String)? onTextChanged,
    VoidCallback? onButtonPressed,
  }) {
    switch (component.type!) {
      case ComponentType.text:
        return FullWidth(
          child: TextComponentWidget(
            text: component.text ?? '',
            textColor: component.textColor,
            animation: component.animation,
            fontSize: component.fontSize,
            fontWeight: component.fontWeight,
            fontFamily: component.fontFamily,
            typewriterSpeed: component.typewriterSpeed,
            textAlign: component.textAlign,
          ),
        );
      case ComponentType.image:
        return Center(
          child: ImageComponentWidget(
            imageUrl: component.imageUrl,
            radius: component.cornerRadius ?? 10,
            height: component.height ?? 150,
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
              enableGlow: component.enableGlow,
              // New: Enable glow effect
              glowColor: component.glowColor,
              // New: Glow color
              enableFlicker: component.enableFlicker,
              // New: Enable flicker animation
              fontFamily: component.fontFamily,
              // New: Font family
              fontWeight: component.fontWeight,
              // New: Font weight
              fontSize: component.fontSize,
              radius: component.cornerRadius,
              onPressed: onButtonPressed, // Pass the callback
            )
        );
      case ComponentType.code:
        return Center
        (child: CodeComponentWidget(component: component, onTextChanged: onTextChanged)); // Pass the callback));
    }
  }
}