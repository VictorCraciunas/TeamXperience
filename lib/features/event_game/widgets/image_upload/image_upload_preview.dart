import 'dart:io';

import 'package:flutter/material.dart';

class ImageUploadPreview extends StatelessWidget {
  final File file;

  const ImageUploadPreview({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Image.file(
        file,
        fit: BoxFit.cover,
        width: double.infinity,
      ),
    );
  }
}
