import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../../../constants/colors.dart';
import '../../../../../../../enums/component-type.dart';
import '../../../../../../../model/component.dart';
import '../../../../../../../widgets/my_button.dart';
import '../../../../../../../widgets/slider_widget.dart';
import '../../../../common_widgets/upload_image.dart';
import '../../../controller/add_missions_controller.dart';
import 'create_image_controller.dart';

class ImageComponentFieldsWidget extends StatefulWidget {
  final AddMissionsController addMissionsController;
  final int missionSelected;
  final int puzzleSelected;
  final Function(Widget) refreshUI;
  final Component? componentToEdit;


  const ImageComponentFieldsWidget({
    super.key,
    required this.addMissionsController,
    required this.missionSelected,
    required this.puzzleSelected,
    required this.refreshUI,
    this.componentToEdit
  });

  @override
  State<ImageComponentFieldsWidget> createState() => _ImageComponentFieldsWidgetState();
}

class _ImageComponentFieldsWidgetState extends State<ImageComponentFieldsWidget> {
  late final ImageComponentController controller;

  @override
  void initState() {
    super.initState();
    controller = ImageComponentController();

    final c = widget.componentToEdit;
    if (c != null && c.type == ComponentType.image) {
      // seed from existing component
      controller.radius = c.cornerRadius ?? controller.radius;
      controller.height = c.height       ?? controller.height;
      if (c.imageUrl != null) {
        controller.image = File(c.imageUrl!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () async {
            await controller.pickImage();
            setState(() {}); // Update the UI after picking an image
          },
          child: UploadImage(
            labelText: 'Adauga imagine',
            imageFile: controller.image,
          ),
        ),
        const SizedBox(height: 20),

        if (controller.image != null)
          Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              height: controller.height,
              width: double.infinity,
              decoration: BoxDecoration(

                borderRadius: BorderRadius.circular(controller.radius),

                image: DecorationImage(
                  image: FileImage(controller.image!),
                  fit: BoxFit.cover,   // fill the entire box so you really see the corners
                ),
              ),
            ),
          ),



        const SizedBox(height: 20),
        SliderWidget(
          title: 'Rotunjire imagine',
          min: 0,
          max: 50,
          divisions: 50,
          value: controller.radius,
          label: controller.radius.toStringAsFixed(0),
          onChanged: (value) => setState(() => controller.radius = value),
        ),
        const SizedBox(height: 20),

        SliderWidget(
          title: 'Inaltime imagine',
          min: 150,
          max: 500,
          divisions: 500,
          value: controller.height,
          label: controller.height.toStringAsFixed(0),
          onChanged: (value) => setState(() => controller.height = value),
        ),
        const SizedBox(height: 20),

        Center(
          child: MyButton(
            buttonText: 'Salveaza componenta',
            textColor: Colors.white,
            buttonOnTap: () {
              // EDIT vs CREATE
              final c = widget.componentToEdit;
              if (c != null && c.type == ComponentType.image) {
                // -- EDIT FLOW --
                if (controller.image == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select an image')),
                  );
                  return;
                }

                // update in-place
                c.imageUrl      = controller.image!.path;
                c.cornerRadius  = controller.radius;
                c.height        = controller.height;

                // rebuild and pop
                final updatedWidget = controller.componentToWidget.convert(c);
                widget.refreshUI(updatedWidget);
                Navigator.pop(context);

              } else {
                // -- CREATE FLOW --
                controller.saveComponent(
                  context,
                  widget.missionSelected,
                  widget.puzzleSelected,
                  widget.addMissionsController,
                  widget.refreshUI,
                );
              }
            },
            withBorder: false,
            buttonColor: MyColors.lightBlue,
            fontWeight: FontWeight.w500,
            buttonTextSize: 14,
            buttonWidth: 270,
          ),
        ),
      ],
    );
  }
}