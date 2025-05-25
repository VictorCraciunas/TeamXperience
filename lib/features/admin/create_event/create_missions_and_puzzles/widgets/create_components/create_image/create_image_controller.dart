import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teamxperience/model/component.dart';

import '../../../../../../../enums/component-type.dart';
import '../../../../../../../utils/component_conversion/component_to_widget.dart';
import '../../../controller/add_missions_controller.dart';


class ImageComponentController {
  double radius = 15.0;
  double height = 150;
  File? image;
  final ComponentToWidget componentToWidget = ComponentToWidget();

  // Pick an image from the gallery
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      image = File(pickedFile.path);
    }
  }

  // Save the component
  void saveComponent(
      BuildContext context,
      int missionSelected,
      int puzzleSelected,
      AddMissionsController addMissionsController,
      Function(Widget) refreshUI) {
    if (image == null) { // Fixed logic: Show error if image is null
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    Component component = addMissionsController.addComponent(
      missionSelected,
      puzzleSelected,
      ComponentType.image,
      imageUrl: image!.path,
      cornerRadius: radius,
      height: height
    );
    Widget componentWidget = componentToWidget.convert(component);
    refreshUI(componentWidget);
    Navigator.pop(context);
  }
}