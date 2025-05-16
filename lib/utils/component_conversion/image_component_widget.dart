import 'package:flutter/material.dart';

class ImageComponentWidget extends StatelessWidget {
  final String? imageUrl;

  const ImageComponentWidget({
    super.key,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return imageUrl != null && imageUrl!.isNotEmpty
        ? Image.network(
      imageUrl!,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
    )
        : const Icon(Icons.image_not_supported);
  }
}