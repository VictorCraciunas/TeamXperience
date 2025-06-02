import 'package:flutter/material.dart';
import 'package:teamxperience/utils/color_conversion.dart';
import '../../../../../../../constants/colors.dart';
import '../../../../../../../enums/component-type.dart';
import '../../../../../../../model/component.dart';
import '../../../../../../../model/puzzle.dart';
import '../../../../../../../utils/component_conversion/component_to_widget.dart';
import '../../../../../../../widgets/color_picker_dialog.dart';
import '../../../../../../../widgets/my_text_field.dart';

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
  String textColor = _defaultBlack;
  double fontSize = _defaultFontSize;
  String? fontFamily = _defaultPoppins;

  final ColorConversion _colorConversion = ColorConversion();
  final ComponentToWidget _componentToWidget = ComponentToWidget();

  // Getters
  bool get canShowPreview => codeLength != null && inputType != null;
  bool get isFormValid => codeLength != null && inputType != null && capsLock != null;

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
    frameBackgroundColor = component.frameBackgroundColor ?? frameBackgroundColor;
    inputBackgroundColor = component.inputBackgroundColor ?? inputBackgroundColor;
    colorBorderContainer = component.colorBorderContainer ?? colorBorderContainer;
    colorBorderInput = component.colorBorderInput ?? colorBorderInput;
    enableGlow = component.enableGlow ?? enableGlow;
    glowColor = component.glowColor ?? glowColor;
    widthInput = component.width ?? widthInput;
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
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

  // Build the custom preview widget
  Widget buildCodePreview(BuildContext context) {
    final frameColor = hexToColor(frameBackgroundColor);
    final glow = hexToColor(glowColor);

    // Only wrap in the outer Container if inputType is "Separated"
    if (inputType == 'Separated') {
      return IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: frameColor,
            borderRadius: BorderRadius.circular(radiusChenar),
            border: Border.all(color: hexToColor(colorBorderContainer), width: 1.5),
            boxShadow: enableGlow
                ? [
              BoxShadow(
                color: glow.withValues(alpha: 0.6),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 0),
              ),
            ]
                : null,
          ),
          child: _buildSeparatedPreview(context),
        ),
      );
    } else {
      return _buildFreePreview();
    }
  }

  Widget _buildSeparatedPreview(BuildContext context) {
    final int codeLength = this.codeLength ?? 5;
    final int rowCount = (codeLength + _maxCharactersPerRow - 1) ~/ _maxCharactersPerRow;
    final int basePerRow = codeLength ~/ rowCount;
    final int extra = codeLength % rowCount;

    // Create focus nodes for each text field
    final List<FocusNode> focusNodes = List.generate(codeLength, (_) => FocusNode());

    int currentIndex = 0;
    final rows = List<Widget>.generate(rowCount, (rowIndex) {
      final countInRow = basePerRow + (rowIndex < extra ? 1 : 0);
      final rowCells = List<Widget>.generate(countInRow, (_) {
        final index = currentIndex;
        currentIndex++;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: SizedBox(
            width: widthInput,
            height: 1.5 * fontSize,
            child: TextField(
              focusNode: focusNodes[index],
              textAlign: TextAlign.center,
              textCapitalization: capsLock == 'Fără'
                  ? TextCapitalization.none
                  : TextCapitalization.characters,
              textAlignVertical: TextAlignVertical.center,
              maxLength: 1,
              decoration: InputDecoration(
                filled: true,
                fillColor: hexToColor(inputBackgroundColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(radiusChenarInputuri),
                  borderSide: BorderSide(color: hexToColor(colorBorderInput), width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(radiusChenarInputuri),
                  borderSide: BorderSide(color: hexToColor(colorBorderInput), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(radiusChenarInputuri),
                  borderSide: BorderSide(color: hexToColor(colorBorderInput), width: 1),
                ),
                contentPadding: EdgeInsets.zero,
                counterText: '',
                hintText: '-',
                hintStyle: const TextStyle(color: Colors.grey),
              ),
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: fontSize,
                color: hexToColor(textColor),
              ),
              onChanged: (value) {
                if (value.length == 1 && index < codeLength - 1) {
                  FocusScope.of(context).requestFocus(focusNodes[index + 1]);
                } else if (value.isEmpty && index > 0) {
                  FocusScope.of(context).requestFocus(focusNodes[index - 1]);
                }
              },
            ),
          ),
        );
      });

      return Padding(
        padding: EdgeInsets.only(bottom: rowIndex == rowCount - 1 ? 0 : 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: rowCells,
        ),
      );
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rows,
    );
  }

  Widget _buildFreePreview() {
    return Container(
      width: widthInput,
      height: 1.5 * fontSize,
      decoration: BoxDecoration(
        color: hexToColor(inputBackgroundColor),
        borderRadius: BorderRadius.circular(radiusChenarInputuri),
        border: Border.all(color: hexToColor(colorBorderInput), width: 1),
      ),
      child: Center(
        child: TextField(
          textAlign: TextAlign.center,
          textCapitalization: capsLock == 'Fără'
              ? TextCapitalization.none
              : TextCapitalization.characters,
          textAlignVertical: TextAlignVertical.center,
          maxLength: codeLength,
          decoration: InputDecoration(
            filled: true,
            fillColor: hexToColor(inputBackgroundColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radiusChenarInputuri),
              borderSide: BorderSide(color: hexToColor(colorBorderInput), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radiusChenarInputuri),
              borderSide: BorderSide(color: hexToColor(colorBorderInput), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radiusChenarInputuri),
              borderSide: BorderSide(color: hexToColor(colorBorderInput), width: 1),
            ),
            contentPadding: EdgeInsets.zero,
            counterText: '',
            hintText: '-',
            hintStyle: const TextStyle(color: Colors.grey),
          ),
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: fontSize,
            color: hexToColor(textColor),
          ),
        ),
      ),
    );
  }

  Widget buildColorPickerField(
      String title,
      String colorHex,
      Function(String) onColorChanged,
      BuildContext context,
      ) {
    Color currentColor = hexToColor(colorHex);
    return MyTextField(
      hinttextWeight: FontWeight.w500,
      hintTextSize: 15,
      hintTextColor: MyColors.blackColor,
      controller: TextEditingController(),
      hintText: title,
      borderColor: MyColors.lightBlue,
      radius: 15,
      readOnly: true,
      onTap: () => ColorPickerDialog.show(context, title, currentColor, onColorChanged),
      trailing: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          color: currentColor,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}