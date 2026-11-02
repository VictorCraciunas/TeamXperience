import 'package:flutter/material.dart';
import 'package:teamxperience/enums/animation_type.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/utils/color_conversion.dart';
import '../../../../../../../enums/component-type.dart';
import '../../../../../../../model/puzzle.dart';
import '../../../../../../../utils/component_conversion/component_to_widget.dart';

class TextComponentController {
  String textColor = '#000000';
  AnimationType? animation;
  double fontSize = 16.0;
  String? fontWeight;
  String? fontFamily;
  int typewriterSpeed = 100; // ms per character
  String textAlign = 'center';

  // Extras. Each starts as "nothing added", so a text stays as it always was.
  double letterSpacing = 0;

  /// A multiple of the font size; null means the font's own.
  double? lineHeight;
  bool italic = false;
  bool uppercase = false;
  bool enableGlow = false;
  String glowColor = '#000000';
  double shadowBlur = 0;
  double shadowDistance = 0;
  String shadowColor = '#000000';

  final TextEditingController textColorController = TextEditingController();
  final TextEditingController textController = TextEditingController();
  final ColorConversion colorConversion = ColorConversion();

  // Convert hex string to Color
  Color hexToColor(String? hex) {
    return colorConversion.hexToColor(hex);
  }

  // Convert Color to hex string
  String colorToHex(Color color) {
    return colorConversion.colorToHex(color);
  }

  // Validation method
  String? validateComponent() {
    if (textController.text.isEmpty) {
      return 'Please enter text content';
    }
    if (animation == null || fontWeight == null || fontFamily == null) {
      return 'Please select all required fields';
    }
    return null;
  }

  // Update component with current field values
  void updateComponentFields(Component component) {
    component.type = ComponentType.text;
    component.text = textController.text;
    component.textColor = textColor;
    component.animation = animation;
    component.fontSize = fontSize;
    component.fontWeight = fontWeight;
    component.fontFamily = fontFamily;
    component.textAlign = textAlign;

    // Only what was chosen is written, so a plain text stays plain.
    component.letterSpacing = letterSpacing > 0 ? letterSpacing : null;
    component.lineHeight = lineHeight;
    component.italic = italic ? true : null;
    component.uppercase = uppercase ? true : null;
    component.enableGlow = enableGlow ? true : null;
    component.glowColor = enableGlow ? glowColor : null;
    final hasShadow = shadowBlur > 0 || shadowDistance > 0;
    component.shadowBlur = shadowBlur > 0 ? shadowBlur : null;
    component.shadowDistance = shadowDistance > 0 ? shadowDistance : null;
    component.shadowColor = hasShadow ? shadowColor : null;
    if (animation == AnimationType.typewriter) {
      component.typewriterSpeed = typewriterSpeed;
    }
  }

  // Save component (handles both create and edit modes)
  void saveComponent({
    required BuildContext context,
    required Puzzle puzzle,
    required Component component,
    required Function(Widget) refreshUI,
    required bool isEditMode,
  }) {
    // Validate first
    final validationError = validateComponent();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }

    // Update component fields
    updateComponentFields(component);

    // Add to puzzle if it's create mode (not edit mode)
    if (!isEditMode) {
      puzzle.addComponent(component);
    }

    // Convert to widget and refresh UI
    final componentWidget = ComponentToWidget().convert(component);
    refreshUI(componentWidget);
    Navigator.pop(context);
  }

  // Initialize controller with existing component data (for edit mode)
  void initializeFromComponent(Component component) {
    if (component.type == ComponentType.text) {
      textController.text = component.text ?? '';
      textColor = component.textColor ?? textColor;
      animation = component.animation;
      fontSize = component.fontSize ?? fontSize;
      fontWeight = component.fontWeight;
      fontFamily = component.fontFamily;
      typewriterSpeed = component.typewriterSpeed ?? 100;
      textAlign = component.textAlign ?? 'center';
      letterSpacing = component.letterSpacing ?? 0;
      lineHeight = component.lineHeight;
      italic = component.italic ?? false;
      uppercase = component.uppercase ?? false;
      enableGlow = component.enableGlow ?? false;
      glowColor = component.glowColor ?? glowColor;
      shadowBlur = component.shadowBlur ?? 0;
      shadowDistance = component.shadowDistance ?? 0;
      shadowColor = component.shadowColor ?? shadowColor;
    }
  }

  // Dispose method to clean up controllers
  void dispose() {
    textController.dispose();
    textColorController.dispose();
  }
}