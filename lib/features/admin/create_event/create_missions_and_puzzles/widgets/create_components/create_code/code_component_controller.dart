import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/utils/color_conversion.dart';
import '../../../../../../../enums/component-type.dart';
import '../../../../../../../model/component.dart';
import '../../../../../../../model/puzzle.dart';
import '../../../../../../../utils/component_conversion/component_to_widget.dart';
import 'package:teamxperience/ui/components/misc/color_picker_dialog.dart';
import 'package:teamxperience/ui/components/inputs/app_text_field.dart';

class CodeComponentController {
  static const String _defaultWhite = '#FFFFFF';
  static const String _defaultBlack = '#000000';
  static const String _defaultPoppins = 'Poppins';
  static const double _defaultRadius = 15.0;
  static const double _defaultWidth = 40.0;
  static const double _defaultFontSize = 16.0;
  static const int _maxCharactersPerRow = 5;

  // Core properties
  int? codeLength;
  String? inputType;
  String? capsLock;

  // Styling properties
  double radiusChenar = _defaultRadius;
  double radiusChenarInputuri = _defaultRadius;
  String frameBackgroundColor = _defaultWhite;
  String inputBackgroundColor = _defaultWhite;
  String colorBorderInput = _defaultWhite;
  String colorBorderContainer = _defaultWhite;
  bool enableGlow = false;
  String glowColor = _defaultBlack;
  double widthInput = _defaultWidth;

  /// The height of a box; null means automatic (1.5 times the text size).
  double? boxHeight;
  bool boldText = true;

  /// Where the glow is: "frame" or "boxes".
  String glowOn = 'frame';
  String textColor = _defaultBlack;
  double fontSize = _defaultFontSize;
  String? fontFamily = _defaultPoppins;

  final ColorConversion _colorConversion = ColorConversion();
  final ComponentToWidget _componentToWidget = ComponentToWidget();

  // Getters
  bool get canShowPreview => codeLength != null && inputType != null;
  bool get isFormValid =>
      codeLength != null && inputType != null && capsLock != null;

  // Color conversion methods
  Color hexToColor(String? hex) => _colorConversion.hexToColor(hex);
  String colorToHex(Color color) => _colorConversion.colorToHex(color);

  // Initialize controller from existing component
  void initializeFromComponent(Component component) {
    if (component.type != ComponentType.code) return;

    codeLength = component.codeLength;
    inputType = component.inputType;
    capsLock = component.capsLock;
    radiusChenar = component.frameCornerRadius ?? radiusChenar;
    radiusChenarInputuri = component.inputCornerRadius ?? radiusChenarInputuri;
    frameBackgroundColor =
        component.frameBackgroundColor ?? frameBackgroundColor;
    inputBackgroundColor =
        component.inputBackgroundColor ?? inputBackgroundColor;
    colorBorderContainer =
        component.colorBorderContainer ?? colorBorderContainer;
    colorBorderInput = component.colorBorderInput ?? colorBorderInput;
    enableGlow = component.enableGlow ?? enableGlow;
    glowColor = component.glowColor ?? glowColor;
    widthInput = component.width ?? widthInput;
    boxHeight = component.boxHeight;
    boldText = component.boldText ?? true;
    glowOn = component.glowOn ?? 'frame';
    fontSize = component.fontSize ?? fontSize;
    fontFamily = component.fontFamily ?? fontFamily;
    textColor = component.textColor ?? textColor;
  }

  // Validation method
  String? validateComponent() {
    if (codeLength == null) return 'Please select number of characters';
    if (inputType == null) return 'Please select input type';
    if (capsLock == null) return 'Please select caps lock setting';
    return null;
  }

  // Update component with current values
  void updateComponent(Component component) {
    component.type = ComponentType.code;
    component.codeLength = codeLength;
    component.inputType = inputType;
    component.capsLock = capsLock;
    component.frameCornerRadius = radiusChenar;
    component.inputCornerRadius = radiusChenarInputuri;
    component.frameBackgroundColor = frameBackgroundColor;
    component.inputBackgroundColor = inputBackgroundColor;
    component.colorBorderContainer = colorBorderContainer;
    component.colorBorderInput = colorBorderInput;
    component.enableGlow = enableGlow;
    component.glowColor = glowColor;
    component.width = widthInput;
    component.boxHeight = boxHeight;
    component.boldText = boldText;
    component.glowOn = glowOn;
    component.fontSize = fontSize;
    component.fontFamily = fontFamily;
    component.textColor = textColor;
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
    updateComponent(component);

    // Add to puzzle if it's create mode (not edit mode)
    if (!isEditMode) {
      puzzle.addComponent(component);
    }

    // Convert to widget and refresh UI
    final componentWidget = _componentToWidget.convert(component);
    refreshUI(componentWidget);
    Navigator.pop(context);
  }

  Widget buildColorPickerField(
    String title,
    String colorHex,
    Function(String) onColorChanged,
    BuildContext context,
  ) {
    Color currentColor = hexToColor(colorHex);
    return AppTextField(
      controller: TextEditingController(),
      hint: title,
      readOnly: true,
      onTap:
          () => ColorPickerDialog.show(
            context,
            title,
            currentColor,
            onColorChanged,
          ),
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
}
