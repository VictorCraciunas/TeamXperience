import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constants/colors.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: MyColors.blackColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
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
          child: imageFile == null ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/upload_image.svg',
                width: 64,
                height: 64,
              ),
              const Text(
                "Incarca imaginea",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ) : null
        ),
      ],
    );
  }
}