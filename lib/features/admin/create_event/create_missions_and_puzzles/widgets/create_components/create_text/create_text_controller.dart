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
    }
  }

  // Dispose method to clean up controllers
  void dispose() {
    textController.dispose();
    textColorController.dispose();
  }
}