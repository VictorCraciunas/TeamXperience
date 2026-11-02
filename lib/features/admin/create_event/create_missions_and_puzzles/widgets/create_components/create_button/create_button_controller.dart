import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/utils/color_conversion.dart';
import '../../../../../../../enums/component-type.dart';
import '../../../../../../../model/puzzle.dart';
import '../../../../../../../utils/component_conversion/component_to_widget.dart';
import 'package:teamxperience/ui/components/misc/color_picker_dialog.dart';
import 'package:teamxperience/ui/components/inputs/app_text_field.dart';

class ButtonComponentController {
  // UI State
  bool isTapped = false;

  // Button Properties
  String buttonColor = '#FFFFFF';
  String buttonColorOnTap = '#CCCCCC';
  String buttonTextColor = '#000000';
  String buttonTextColorOnTap = '#FFFFFF';
  String borderColor = '#000000';
  String glowColor = '#000000';
  String? fontWeight;
  String? fontFamily;
  double cornerRadius = 15.0;
  bool enableFlicker = false;
  bool enableGlow = false;
  double fontSize = 15;
  double letterSpacing = 8;
  double paddingY = 5;

  // Controllers
  final TextEditingController labelController = TextEditingController();
  final TextEditingController controller = TextEditingController();
  final ColorConversion colorConversion = ColorConversion();
  final ComponentToWidget componentToWidget = ComponentToWidget();

  // Convert hex string to Color
  Color hexToColor(String? hex) {
    return colorConversion.hexToColor(hex);
  }

  // Convert Color to hex string
  String colorToHex(Color color) {
    return colorConversion.colorToHex(color);
  }

  // Build color picker field widget
  Widget buildColorPickerField({
    required String title,
    required String colorHex,
    required Function(String) onColorChanged,
    required BuildContext context,
  }) {
    Color currentColor = hexToColor(colorHex);

    return AppTextField(
      controller: controller,
      hint: title,
      readOnly: true,
      onTap: () {
        ColorPickerDialog.show(
          context,
          title,
          currentColor,
          (color) => onColorChanged(color),
        );
      },
      trailing: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          color: currentColor,
          border: Border.all(color: context.colors.border),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      validator: requiredValidator('a value'),
    );
  }

  // Validation method
  String? validateComponent() {
    if (labelController.text.isEmpty) {
      return 'Please enter a button label';
    }
    return null;
  }

  // Update component with current field values
  void updateComponentFields(Component component) {
    component.type = ComponentType.button;
    component.buttonLabel = labelController.text;
    component.buttonColor = buttonColor;
    component.buttonColorOnTap = buttonColorOnTap;
    component.buttonTextColor = buttonTextColor;
    component.buttonTextColorOnTap = buttonTextColorOnTap;
    component.borderColor = borderColor;
    component.glowColor = glowColor;
    component.fontWeight = fontWeight;
    component.fontFamily = fontFamily;
    component.cornerRadius = cornerRadius;
    component.enableFlicker = enableFlicker;
    component.enableGlow = enableGlow;
    component.fontSize = fontSize;
    component.letterSpacing = letterSpacing;
    component.paddingY = paddingY;
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validationError)));
      return;
    }

    // Update component fields
    updateComponentFields(component);

    // Add to puzzle if it's create mode (not edit mode)
    if (!isEditMode) {
      puzzle.addComponent(component);
    }

    // Convert to widget and refresh UI
    final componentWidget = componentToWidget.convert(component);
    refreshUI(componentWidget);
    Navigator.pop(context);
  }

  // Initialize controller with existing component data (for edit mode)
  void initializeFromComponent(Component component) {
    if (component.type == ComponentType.button) {
      labelController.text = component.buttonLabel ?? '';
      buttonColor = component.buttonColor ?? '#FFFFFF';
      buttonColorOnTap = component.buttonColorOnTap ?? '#CCCCCC';
      buttonTextColor = component.buttonTextColor ?? '#000000';
      buttonTextColorOnTap = component.buttonTextColorOnTap ?? '#FFFFFF';
      borderColor = component.borderColor ?? '#000000';
      glowColor = component.glowColor ?? '#000000';
      fontWeight = component.fontWeight;
      fontFamily = component.fontFamily;
      cornerRadius = component.cornerRadius ?? 15.0;
      enableFlicker = component.enableFlicker ?? false;
      enableGlow = component.enableGlow ?? false;
      fontSize = component.fontSize ?? 15;
      letterSpacing = component.letterSpacing ?? 8;
      paddingY = component.paddingY ?? 5;
    }
  }
}
