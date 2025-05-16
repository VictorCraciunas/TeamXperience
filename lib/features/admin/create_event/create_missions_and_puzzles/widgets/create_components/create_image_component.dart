import 'package:flutter/material.dart';

class ImageComponentFieldsWidget extends StatelessWidget {
  final TextEditingController imageUrlController;
  final ValueChanged<String?> onImageUrlChanged;

  const ImageComponentFieldsWidget({
    super.key,
    required this.imageUrlController,
    required this.onImageUrlChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        TextField(
          controller: imageUrlController,
          decoration: const InputDecoration(labelText: 'Image URL'),
          onChanged: onImageUrlChanged,
        ),
      ],
    );
  }
}