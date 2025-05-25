import 'package:flutter/material.dart';
import 'package:teamxperience/model/component.dart';

import 'package:teamxperience/utils/color_conversion.dart';

import '../../../../../../../constants/colors.dart';
import '../../../../../../../enums/component-type.dart';
import '../../../../../../../utils/component_conversion/component_to_widget.dart';
import '../../../../../../../widgets/color_picker_dialog.dart';
import '../../../../../../../widgets/my_text_field.dart';
import '../../../controller/add_missions_controller.dart';

class ButtonComponentController {
  bool isTapped = false;
  String buttonColor = '#FFFFFF'; // Default white
  String buttonColorOnTap = '#CCCCCC'; // Default gray
  String buttonTextColor = '#000000'; // Default black
  String buttonTextColorOnTap = '#FFFFFF'; // Default white
  String borderColor = '#000000'; // Default black
  String glowColor = '#000000';
  String? fontWeight;
  String? fontFamily;
  double cornerRadius = 15.0;
  bool enableFlicker = false;
  bool enableGlow = false;

  final TextEditingController labelController = TextEditingController();
  final TextEditingController controller = TextEditingController();

  final ColorConversion colorConversion = ColorConversion();

  // Convert hex string to Color
  Color hexToColor(String? hex) {
    return colorConversion.hexToColor(hex);
  }

  // Convert Color to hex string
  String colorToHex(Color color) {
    return colorConversion.colorToHex(color);
  }

  Widget buildColorPickerField({
    required String title,
    required String colorHex,
    required Function(String) onColorChanged,
    required BuildContext context,
  }) {
    Color currentColor = hexToColor(colorHex);
    return MyTextField(
      hinttextWeight: FontWeight.w500,
      hintTextSize: 15,
      hintTextColor: MyColors.blackColor,
      controller: controller,
      hintText: title,
      borderColor: MyColors.lightBlue,
      radius: 15,
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
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
  // Save the component
  void saveComponent(
      BuildContext context,
      int missionSelected,
      int puzzleSelected,
      AddMissionsController addMissionsController,
      Function(Widget) refreshUI) {
    if (labelController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a button label')),
      );
      return;
    }

    Component component = addMissionsController.addComponent(
      missionSelected,
      puzzleSelected,
      ComponentType.button,
      buttonLabel: labelController.text,
      buttonColor: buttonColor,
      buttonColorOnTap: buttonColorOnTap,
      buttonTextColor: buttonTextColor,
      buttonTextColorOnTap: buttonTextColorOnTap,
      borderColor: borderColor,
      fontWeight: fontWeight,
      fontFamily: fontFamily,
      cornerRadius: cornerRadius,
      enableFlicker: enableFlicker,
      enableGlow: enableGlow,
      glowColor: glowColor,
    );
    Widget componentWidget = ComponentToWidget().convert(component);
    refreshUI(componentWidget);
    Navigator.pop(context);
  }
}