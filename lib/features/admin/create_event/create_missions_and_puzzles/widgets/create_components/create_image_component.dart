import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/utils/component_conversion/component_to_widget.dart';

import '../../../../../../model/component.dart';
import '../../controller/add_missions_controller.dart';

class ImageComponentFieldsWidget extends StatefulWidget {
  final TextEditingController imageUrlController;
  final AddMissionsController addMissionsController;
  final int missionSelected;
  final int puzzleSelected;
  final Function(Widget) refreshUI;

  const ImageComponentFieldsWidget({
    super.key,
    required this.imageUrlController,
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        widget.imageUrlController.text = pickedFile.path;
      });
    }
  }

  void _saveComponent() {
    if (widget.imageUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    Component component = widget.addMissionsController.addComponent(
      widget.missionSelected,
      widget.puzzleSelected,
      ComponentType.image,
      imageUrl: widget.imageUrlController.text,
    );
    Widget componentWidget = ComponentToWidget().convert(component);
    widget.refreshUI(componentWidget);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        ListTile(
          title: Text(
            _image == null
                ? 'Select Task Background Image'
                : 'Task Background: ${_image!.path.split('/').last}',
          ),
          trailing: const Icon(Icons.image),
          onTap: _pickImage,
        ),
        if (_image != null)
          Padding(
            padding: const EdgeInsets.all(10),
            child: Image.file(
              _image!,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _saveComponent,
          child: const Text('Save Component'),
        ),
      ],
    );
  }
}