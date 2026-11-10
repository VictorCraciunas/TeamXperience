import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';

class ImageHelper{
  static final CacheManager eventImageCache = CacheManager(
    Config(
      'eventImagesCache',
      maxNrOfCacheObjects: 200, // Increased for better caching
      stalePeriod: const Duration(days: 30),
      // Optional: Add repo for better performance
      repo: JsonCacheInfoRepository(databaseName: 'eventImagesCache'),
    ),
  );

  /// A new photo from the camera, kept small enough to send from the street;
  /// null when the player cancels.
  static Future<File?> takePhoto() async {
    final picker = ImagePicker();
    final taken = await picker.pickImage(source: ImageSource.camera, maxWidth: 1600, imageQuality: 75);
    return taken == null ? null : File(taken.path);
  }

  static Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }
}

