import 'package:flutter/material.dart';
import 'package:teamxperience/utils/color_conversion.dart';

import '../../../../../../../constants/colors.dart';
import '../../../../../../../enums/component-type.dart';
import '../../../../../../../model/component.dart';
import '../../../../../../../utils/component_conversion/component_to_widget.dart';
import '../../../../../../../widgets/color_picker_dialog.dart';
import '../../../../../../../widgets/my_text_field.dart';
import '../../../controller/add_missions_controller.dart';

class CodeComponentController {
  int? codeLength;
  String? inputType; // "Separated" or "Free"
  String? capsLock; // "CapsLock" or "Fără"
  double radiusChenar = 15.0;
  double radiusChenarInputuri = 15.0;
  String frameBackgroundColor = '#FFFFFF'; // Default white
  String inputBackgroundColor = '#FFFFFF'; // Default white
  String colorBorderInput = '#FFFFFF'; // Default white
  String colorBorderContainer = '#FFFFFF'; // Default white
  bool enableGlow = false;
  String glowColor = '#000000'; // Default black
  double widthInput = 40;
  String textColor = '#000000';
  double fontSize = 16;
  String? fontFamily = 'Poppins';


  ColorConversion colorConversion = ColorConversion();

  Color hexToColor(String? hex) {
    return colorConversion.hexToColor(hex);
  }

  String colorToHex(Color color) {
    return colorConversion.colorToHex(color);
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
      // For "Free" inputType, return the free preview directly without the outer container
      return buildFreePreview();
    }
  }

  Widget _buildSeparatedPreview(BuildContext context) {
    const int maxPerRow = 5;
    final int codeLength = this.codeLength ?? 5;
    final int rowCount = (codeLength + maxPerRow - 1) ~/ maxPerRow;
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
              textCapitalization: capsLock == 'Fără' ? TextCapitalization.none : TextCapitalization.characters,
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
                counterText: '', // Hides the character counter
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

  Widget buildFreePreview() {
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
          textCapitalization: capsLock == 'Fără' ? TextCapitalization.none : TextCapitalization.characters,
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

  void saveComponent(BuildContext context, int missionSelected, int puzzleSelected, AddMissionsController addMissionsController, Function(Widget) refreshUI) {
    if (codeLength == null || inputType == null || capsLock == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    Component component = addMissionsController.addComponent(
      missionSelected,
      puzzleSelected,
      ComponentType.code,
      codeLength: codeLength,
      inputType: inputType,
      capsLock: capsLock,
      frameCornerRadius: radiusChenar,
      inputCornerRadius: radiusChenarInputuri,
      frameBackgroundColor: frameBackgroundColor,
      inputBackgroundColor: inputBackgroundColor,
      enableGlow: enableGlow,
      glowColor: glowColor,
      colorBorderContainer: colorBorderContainer,
      colorBorderInput: colorBorderInput,
      width: widthInput,
      fontSize: fontSize,
      fontFamily: fontFamily,
      textColor: textColor,
    );
    Widget componentWidget = ComponentToWidget().convert(component);
    refreshUI(componentWidget);
    Navigator.pop(context);

  }
}