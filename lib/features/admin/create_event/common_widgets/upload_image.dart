import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UploadImage extends StatelessWidget {
  final String labelText;
  final File? imageFile;

  const UploadImage({
    super.key,
    required this.labelText,
    this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: imageFile == null ? const Color(0xFFE7F7F7) : null,
        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
        image: imageFile != null
            ? DecorationImage(
          image: FileImage(imageFile!),
          fit: BoxFit.cover,
        )
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/upload_image.svg',
            width: 64,
            height: 64,
          ),
          Text(
            labelText,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}