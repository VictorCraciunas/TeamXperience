import 'package:flutter/material.dart';

import '../../../../../../../constants/colors.dart';
import '../../../../../../../widgets/my_button.dart';
import '../../../../common_widgets/upload_image.dart';
import '../../../controller/add_missions_controller.dart';
import 'create_image_controller.dart';

class ImageComponentFieldsWidget extends StatefulWidget {
  final AddMissionsController addMissionsController;
  final int missionSelected;
  final int puzzleSelected;
  final Function(Widget) refreshUI;

  const ImageComponentFieldsWidget({
    super.key,
    required this.addMissionsController,
    required this.missionSelected,
    required this.puzzleSelected,
    required this.refreshUI,
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
        // Uncomment if you want to show the image preview
        // if (controller.image != null)
        //   Padding(
        //     padding: const EdgeInsets.all(10),
        //     child: Image.file(
        //       controller.image!,
        //       height: 150,
        //       width: double.infinity,
        //       fit: BoxFit.cover,
        //     ),
        //   ),
        const SizedBox(height: 20),
        Center(
          child: MyButton(
            buttonText: 'Salveaza componenta',
            textColor: Colors.white,
            buttonOnTap: () => controller.saveComponent(
              context,
              widget.missionSelected,
              widget.puzzleSelected,
              widget.addMissionsController,
              widget.refreshUI,
            ),
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