import 'package:flutter/material.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/utils/component_conversion/text_component_widget.dart';

import 'button_component_widget.dart';
import 'package:teamxperience/utils/color_conversion.dart';

import 'answer_feedback.dart';
import 'box_effects.dart';
import 'full_width.dart';
import 'loop_effect_widget.dart';
import 'text_effects.dart';
import 'code_component_widget.dart';
import 'image_component_widget.dart';


class ComponentToWidget {
  /// The widget for [component], with its opacity applied.
  Widget convert(Component component, {
    Function(String)? onTextChanged,
    VoidCallback? onButtonPressed,
    AnswerFeedback? feedback,
  }) {
    final built = _build(component, onTextChanged: onTextChanged, onButtonPressed: onButtonPressed, feedback: feedback);
    final moving = component.loopEffect == null ? built : LoopEffectWidget(effect: component.loopEffect, child: built);
    return BoxEffects.fromComponent(component).withOpacity(moving);
  }

  Widget _build(Component component, {
    Function(String)? onTextChanged,
    VoidCallback? onButtonPressed,
    AnswerFeedback? feedback,
  }) {
    final box = BoxEffects.fromComponent(component);
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
            effects: TextEffects.fromComponent(component),
          ),
        );
      case ComponentType.image:
        return Center(
          child: ImageComponentWidget(
            imageUrl: component.imageUrl,
            radius: component.cornerRadius ?? 10,
            height: component.height ?? 150,
            shadows: box.shadowAndGlow,
            borderWidth: component.borderWidth,
            borderColor: component.borderColor == null ? null : ColorConversion().hexToColor(component.borderColor),
          ),
        );
      case ComponentType.button:
        return Center(
            child: box.shadowAround(ButtonComponentWidget(
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
              letterSpacing: component.letterSpacing,
              paddingY: component.paddingY,
              borderWidth: component.borderWidth,
              onPressed: onButtonPressed, // Pass the callback
            ), component.cornerRadius ?? 10)
        );
      case ComponentType.code:
        final separated = component.inputType == 'Separated';
        final radius = separated ? (component.frameCornerRadius ?? 15.0) : (component.inputCornerRadius ?? 25.0);
        return Center(
          child: box.shadowAround(CodeComponentWidget(component: component, onTextChanged: onTextChanged, feedback: feedback), radius),
        );
    }
  }
}