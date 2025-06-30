import 'dart:io';

import '../../backend/storage/storage_images.dart';
import '../../model/stire.dart';

class UploadNewsImagesHelper {
  final ImageRepo _imageRepo = ImageRepo();

  // Helper methods for news images
  Future<Stire> uploadNewsImages(Stire stire) async {
    // Upload principal image if it's a local file
    if (stire.principalImage != null &&
        !isNetworkUrl(stire.principalImage!)) {
      final file = File(stire.principalImage!);
      if (await file.exists()) {
        final url = await _imageRepo.uploadStireImage(file, stire.id!, "principal");
        if (url != null) stire.principalImage = url;
      }
    }

    // Upload secondary images
    await uploadSecondaryImages(stire);

    return stire;
  }

  Future<void> uploadSecondaryImages(Stire stire) async {
    if (stire.secondaryImages == null || stire.secondaryImages!.isEmpty) return;

    List<String> uploadedUrls = [];

    for (int index = 0; index < stire.secondaryImages!.length; index++) {
      final imagePath = stire.secondaryImages![index];

      if (!isNetworkUrl(imagePath)) {
        // It's a local file, upload it
        final file = File(imagePath);
        if (await file.exists()) {
          final identifier = "secondary_$index";
          final url = await _imageRepo.uploadStireImage(file, stire.id!, identifier);
          if (url != null) {
            uploadedUrls.add(url);
          }
        }
      } else {
        // It's already a URL, keep it
        uploadedUrls.add(imagePath);
      }
    }

    stire.secondaryImages = uploadedUrls;
  }

  bool isNetworkUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }
}