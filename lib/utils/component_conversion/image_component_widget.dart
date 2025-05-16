import 'dart:io';
import 'package:flutter/material.dart';

class ImageComponentWidget extends StatelessWidget {
  final String? imageUrl;

  const ImageComponentWidget({
    super.key,
    this.imageUrl,
  });

  // Helper to determine if the URL is a local file path or a network URL
  bool _isNetworkUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const Placeholder(
        fallbackHeight: 150,
        fallbackWidth: double.infinity,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(10),
      child: _isNetworkUrl(imageUrl)
          ? Image.network(
        imageUrl!,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Placeholder(
          fallbackHeight: 150,
          fallbackWidth: double.infinity,
        ),
      )
          : Image.file(
        File(imageUrl!),
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Placeholder(
          fallbackHeight: 150,
          fallbackWidth: double.infinity,
        ),
      ),
    );
  }
}