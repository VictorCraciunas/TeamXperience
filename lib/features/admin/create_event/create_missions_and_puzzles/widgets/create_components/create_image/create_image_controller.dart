import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teamxperience/model/component.dart';
import '../../../../../../../enums/component-type.dart';
import '../../../../../../../model/puzzle.dart';
import '../../../../../../../utils/component_conversion/component_to_widget.dart';

class ImageComponentController {
  double radius = 15.0;
  double height = 150;
  File? image;

  // Extras. Each starts as "nothing added", so an image stays as it always was.
  double borderWidth = 0;
  String borderColor = '#000000';
  bool enableGlow = false;
  String glowColor = '#000000';

  final ComponentToWidget componentToWidget = ComponentToWidget();

  // Pick an image from the gallery
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      image = File(pickedFile.path);
    }
  }

  // Validation method
  String? validateComponent() {
    if (image == null) {
      return 'Please select an image';
    }
    return null;
  }

  // Update component with current field values
  void updateComponentFields(Component component) {
    component.type = ComponentType.image;
    component.imageUrl = image!.path;
    component.cornerRadius = radius;
    component.height = height;

    // Only what was chosen is written, so a plain image stays plain.
    component.borderWidth = borderWidth > 0 ? borderWidth : null;
    component.borderColor = borderWidth > 0 ? borderColor : null;
    component.enableGlow = enableGlow ? true : null;
    component.glowColor = enableGlow ? glowColor : null;
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
    final componentWidget = componentToWidget.convert(component);
    refreshUI(componentWidget);
    Navigator.pop(context);
  }

  // Initialize controller with existing component data (for edit mode)
  void initializeFromComponent(Component component) {
    if (component.type == ComponentType.image) {
      radius = component.cornerRadius ?? radius;
      height = component.height ?? height;
      borderWidth = component.borderWidth ?? 0;
      borderColor = component.borderColor ?? borderColor;
      enableGlow = component.enableGlow ?? false;
      glowColor = component.glowColor ?? glowColor;
      if (component.imageUrl != null) {
        image = File(component.imageUrl!);
      }
    }
  }
}