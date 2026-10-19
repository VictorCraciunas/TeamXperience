import 'dart:io';
import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:flutter_svg/svg.dart';

class UploadImage extends StatelessWidget {
  final String labelText;
  final String? imageUrl; // Changed to String? to handle both file paths and URLs

  const UploadImage({
    super.key,
    required this.labelText,
    this.imageUrl,
  });

  // Helper to determine if the URL is a network URL or a local file path
  bool _isNetworkUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: context.colors.text,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: imageUrl == null ? context.colors.iconButtonBg : null,
            borderRadius: const BorderRadius.all(Radius.circular(20.0)),
            image: imageUrl != null ? _getDecorationImage() : null,
          ),
          child: imageUrl == null ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/upload_image.svg',
                width: 64,
                height: 64,
              ),
              const Text(
                "Încarcă imaginea",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ) : null,
        ),
      ],
    );
  }

  DecorationImage? _getDecorationImage() {
    if (imageUrl == null || imageUrl!.isEmpty) return null;

    return DecorationImage(
      image: _isNetworkUrl(imageUrl)
          ? NetworkImage(imageUrl!) // Network image for URLs
          : FileImage(File(imageUrl!)) as ImageProvider, // Local file for paths
      fit: BoxFit.cover,
    );
  }
}