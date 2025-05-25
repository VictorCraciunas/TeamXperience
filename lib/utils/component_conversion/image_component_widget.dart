import 'dart:io';
import 'package:flutter/material.dart';

class ImageComponentWidget extends StatelessWidget {
  final String? imageUrl;
  final double height; // Added height parameter
  final double radius; // Added radius parameter for border radius

  const ImageComponentWidget({
    super.key,
    this.imageUrl,
    required this.height, // Require height
    required this.radius, // Require radius
  });

  // Helper to determine if the URL is a local file path or a network URL
  bool _isNetworkUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: const Placeholder(
            fallbackHeight: 150,
            fallbackWidth: double.infinity,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        height: height, // Use the provided height
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius), // Apply custom radius
          image: DecorationImage(
            image: _isNetworkUrl(imageUrl)
                ? NetworkImage(imageUrl!) // Network image
                : FileImage(File(imageUrl!)) as ImageProvider, // Local file image
            fit: BoxFit.cover, // Fill the entire box to show the corners
            onError: (exception, stackTrace) {
              // Handle errors by showing a placeholder
              // Note: DecorationImage doesn't have a built-in errorBuilder,
              // so you might need to handle this differently if errors are common
            },
          ),
        ),
      ),
    );
  }
}