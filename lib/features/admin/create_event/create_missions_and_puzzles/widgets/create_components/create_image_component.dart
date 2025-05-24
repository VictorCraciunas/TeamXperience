import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/utils/component_conversion/component_to_widget.dart';

import '../../../../../../constants/colors.dart';
import '../../../../../../model/component.dart';
import '../../../../../../widgets/my_button.dart';
import '../../../common_widgets/upload_image.dart';
import '../../controller/add_missions_controller.dart';

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
  File? _image;
  ComponentToWidget componentToWidget =ComponentToWidget();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _saveComponent() {
    if (_image != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      Component component = widget.addMissionsController.addComponent(
        widget.missionSelected,
        widget.puzzleSelected,
        ComponentType.image,
        imageUrl: _image!.path
      );
      Widget componentWidget = componentToWidget.convert(component);
      widget.refreshUI(componentWidget);
      Navigator.pop(context);
      return;
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
            await _pickImage();
          },
          child: UploadImage(
            labelText: 'Adauga imagine',
            imageFile: _image,
          ),
        ),
        // if (_image != null)
        //   Padding(
        //     padding: const EdgeInsets.all(10),
        //     child: Image.file(
        //       _image!,
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
            buttonOnTap: _saveComponent,
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