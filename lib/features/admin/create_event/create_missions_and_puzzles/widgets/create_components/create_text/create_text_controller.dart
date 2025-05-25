import 'package:flutter/material.dart';
import 'package:teamxperience/enums/animation_type.dart';
import 'package:teamxperience/model/component.dart';

import 'package:teamxperience/utils/color_conversion.dart';

import '../../../../../../../enums/component-type.dart';
import '../../../../../../../utils/component_conversion/component_to_widget.dart';
import '../../../controller/add_missions_controller.dart';

class TextComponentController {
  String textColor = '#000000';
  AnimationType? animation;
  double fontSize = 16.0;
  String? fontWeight;
  String? fontFamily;
  final TextEditingController textColorController = TextEditingController();
  final TextEditingController fontController = TextEditingController();
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

  // Save the component
  void saveComponent(BuildContext context, int missionSelected, int puzzleSelected, AddMissionsController addMissionsController, Function(Widget) refreshUI) {
    if (textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text content')),
      );
      return;
    }
    if (animation == null || fontWeight == null || fontFamily == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select all required fields')),
      );
      return;
    }

    Component component = addMissionsController.addComponent(
      missionSelected,
      puzzleSelected,
      ComponentType.text,
      text: textController.text,
      textColor: textColor,
      animation: animation,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontFamily: fontFamily,
    );
    Widget componentWidget = ComponentToWidget().convert(component);
    refreshUI(componentWidget);
    Navigator.pop(context);
  }
}