import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';

/// The camera was refused for this app. image_picker asks again by itself
/// while the phone still allows a prompt; after "don't ask again" (Android) or
/// a refusal (iOS) only the phone's settings can turn it back on.
class CameraAccessDenied implements Exception {
  const CameraAccessDenied();

  /// image_picker's error code for it, on Android and iOS.
  static const String code = 'camera_access_denied';
}

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
  /// null when the player cancels. Throws [CameraAccessDenied] when the camera
  /// is refused (Android declares CAMERA, so image_picker asks for it first).
  static Future<File?> takePhoto() async {
    final picker = ImagePicker();
    try {
      final taken = await picker.pickImage(source: ImageSource.camera, maxWidth: 1600, imageQuality: 75);
      return taken == null ? null : File(taken.path);
    } on PlatformException catch (e) {
      if (e.code == CameraAccessDenied.code) throw const CameraAccessDenied();
      rethrow;
    }
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

