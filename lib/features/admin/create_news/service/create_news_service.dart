import 'dart:io';
import '../../../../../backend/repo/stire_repo.dart';
import '../../../../../backend/storage/storage_images.dart';
import '../../../../../model/stire.dart';
import '../../../../../enums/stire_type.dart';
import '../../../../../model/newsCategory.dart'; // Changed from enum import to model import

class CreateStireService {
  StireRepo stireRepo = StireRepo();
  ImageRepo imageRepo = ImageRepo();

  Stire createStire(
      String id,
      String title,
      String description,
      DateTime? publicationDate,
      StireType? type,
      NewsCategory? category, // Changed from StireCategory to NewsCategory
      String? buttonText,
      String? buttonLink,
      String principalImage,
      List<String> secondaryImages,
      ) {
    Stire stire = Stire(
      id: id,
      title: title,
      description: description,
      publicationDate: publicationDate,
      type: type,
      category: category, // Now using NewsCategory instead of StireCategory
      buttonText: buttonText,
      buttonLink: buttonLink,
      principalImage: principalImage,
      secondaryImages: secondaryImages,
    );

    return stire;
  }

  Future<String> getStireId() async {
    return stireRepo.getNewStireId();
  }

  /// Saves the stire with image upload logic similar to event saving
  Future<void> saveStire(Stire stire) async {
    try {
      // Upload principal image if it exists and is a local file
      if (stire.principalImage != null &&
          stire.principalImage!.isNotEmpty &&
          !stire.principalImage!.startsWith('http')) {

        File principalImageFile = File(stire.principalImage!);
        if (await principalImageFile.exists()) {
          String? uploadedUrl = await imageRepo.uploadStireImage(
              principalImageFile,
              stire.id!,
              "principal_image"
          );
          if (uploadedUrl != null) {
            stire.principalImage = uploadedUrl;
            print('Successfully uploaded principal image: $uploadedUrl');
          } else {
            print('Failed to upload principal image');
          }
        } else {
          print('Principal image file does not exist: ${stire.principalImage}');
        }
      }

      // Upload secondary images if they exist and are local files
      if (stire.secondaryImages != null && stire.secondaryImages!.isNotEmpty) {
        List<String> uploadedSecondaryImages = [];

        for (int i = 0; i < stire.secondaryImages!.length; i++) {
          String imagePath = stire.secondaryImages![i];

          // Check if this is a local file path (not a URL)
          if (imagePath.isNotEmpty && !imagePath.startsWith('http')) {
            try {
              File imageFile = File(imagePath);

              if (await imageFile.exists()) {
                String? uploadedUrl = await imageRepo.uploadStireImage(
                    imageFile,
                    stire.id!,
                    "secondary_image_$i"
                );

                if (uploadedUrl != null) {
                  uploadedSecondaryImages.add(uploadedUrl);
                  print('Successfully uploaded secondary image $i: $uploadedUrl');
                } else {
                  print('Failed to upload secondary image $i');
                }
              } else {
                print('Secondary image file does not exist: $imagePath');
              }
            } catch (e) {
              print('Error uploading secondary image $i: $e');
              // Continue processing other images instead of stopping
            }
          } else if (imagePath.startsWith('http')) {
            // If it's already a URL, keep it as is
            uploadedSecondaryImages.add(imagePath);
          }
        }

        // Update the stire with the uploaded URLs
        stire.secondaryImages = uploadedSecondaryImages;
      }

      // Save the stire to the database after all image processing is complete
      await stireRepo.createStire(stire);
      print('Stire saved successfully with ID: ${stire.id}');

    } catch (e) {
      print('Error in saveStire: $e');
      rethrow; // Re-throw to let calling code handle the error
    }
  }
}