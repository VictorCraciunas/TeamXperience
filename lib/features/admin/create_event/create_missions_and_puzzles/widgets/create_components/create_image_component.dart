import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageComponentFieldsWidget extends StatefulWidget {
  final TextEditingController imageUrlController;
  final ValueChanged<String?> onImageUrlChanged;

  const ImageComponentFieldsWidget({
    super.key,
    required this.imageUrlController,
    required this.onImageUrlChanged,
  });

  @override
  State<ImageComponentFieldsWidget> createState() => _ImageComponentFieldsWidgetState();
}

class _ImageComponentFieldsWidgetState extends State<ImageComponentFieldsWidget> {
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery); // Can switch to ImageSource.camera if needed
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        widget.imageUrlController.text = pickedFile.path; // Update the controller with the file path
        widget.onImageUrlChanged(pickedFile.path); // Notify parent of the change
      });
    }
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
      ],
    );
  }
}