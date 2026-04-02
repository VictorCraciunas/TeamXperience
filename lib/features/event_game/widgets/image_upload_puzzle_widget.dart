import 'dart:io';

import 'package:flutter/material.dart';
import 'package:teamxperience/backend/storage/storage_images.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/utils/image_helper.dart';
import 'package:teamxperience/widgets/my_button.dart';

class ImageUploadPuzzleWidget extends StatefulWidget {
  final String eventId;
  final String teamName;
  final int missionIndex;
  final int puzzleIndex;
  final VoidCallback onSolved;
  final bool isMissionCompleted;

  const ImageUploadPuzzleWidget({
    super.key,
    required this.eventId,
    required this.teamName,
    required this.missionIndex,
    required this.puzzleIndex,
    required this.onSolved,
    this.isMissionCompleted = false,
  });

  @override
  State<ImageUploadPuzzleWidget> createState() => _ImageUploadPuzzleWidgetState();
}

class _ImageUploadPuzzleWidgetState extends State<ImageUploadPuzzleWidget> {
  final ImageRepo _imageRepo = ImageRepo();
  File? _selectedImage;
  bool _isUploading = false;
  bool _isUploaded = false;

  Future<void> _pickAndUploadImage() async {
    final file = await ImageHelper.pickImage();
    if (file == null) return;

    setState(() {
      _selectedImage = file;
      _isUploading = true;
    });

    final path = 'team_photos/${widget.teamName}_mission_${widget.missionIndex}_puzzle_${widget.puzzleIndex}';
    final url = await _imageRepo.uploadImage(file, widget.eventId, path);

    if (mounted) {
      setState(() {
        _isUploading = false;
        _isUploaded = url != null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_selectedImage != null)
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            )
          else
            Expanded(
              child: GestureDetector(
                onTap: _pickAndUploadImage,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 64,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Apasă pentru a încărca o poză',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (_isUploading)
            const CircularProgressIndicator(color: MyColors.lightBlue),
          if (!_isUploading && !_isUploaded && _selectedImage != null)
            MyButton(
              buttonText: 'Încarcă poza',
              textColor: Colors.white,
              buttonOnTap: _pickAndUploadImage,
              withBorder: false,
              gradient: MyColors.myGradient,
              buttonTextSize: 15,
            ),
          if (_isUploaded || widget.isMissionCompleted)
            MyButton(
              buttonText: 'Continuă',
              textColor: Colors.white,
              buttonOnTap: widget.onSolved,
              withBorder: false,
              gradient: MyColors.myGradient,
              buttonTextSize: 15,
            ),
        ],
      ),
    );
  }
}
