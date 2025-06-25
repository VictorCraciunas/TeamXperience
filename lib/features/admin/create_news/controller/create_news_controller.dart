import 'dart:io';
import 'package:flutter/material.dart';
import 'package:teamxperience/model/stire.dart';
import 'package:teamxperience/enums/stire_type.dart';
import 'package:teamxperience/model/newsCategory.dart'; // Import NewsCategory instead of enum
import '../../../../utils/calendar_helper.dart';
import '../../../../utils/image_helper.dart';
import '../service/create_news_service.dart';

class CreateStireController {
  final CreateStireService createStireService = CreateStireService();
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();
  final textButtonController = TextEditingController();
  final linkButtonController = TextEditingController();
  final categoryController = TextEditingController();

  File? mainImageFile;
  List<File> secondaryImageFiles = [];

  // Store existing URLs for images that haven't been changed
  List<String> existingSecondaryImageUrls = [];

  DateTime? publicationDate;
  StireType? selectedType;
  NewsCategory? selectedCategory; // Changed from StireCategory to NewsCategory

  Stire? originalStire;

  CreateStireController(Stire? stire) {
    if (stire != null) {
      originalStire = stire;
      titleController.text = stire.title ?? "";
      descriptionController.text = stire.description ?? "";
      textButtonController.text = stire.buttonText ?? "";
      linkButtonController.text = stire.buttonLink ?? "";
      selectedType = stire.type;
      selectedCategory = stire.category;
      publicationDate = stire.publicationDate;

      // Set category controller text if category exists
      if (stire.category != null) {
        categoryController.text = stire.category!.name;
      }

      if (publicationDate != null) {
        dateController.text =
        '${publicationDate!.day}/${publicationDate!.month}/${publicationDate!.year} ${publicationDate!.hour.toString().padLeft(2, '0')}:${publicationDate!.minute.toString().padLeft(2, '0')}';
      }

      // Handle existing secondary images - store URLs separately from file paths
      if (stire.secondaryImages != null && stire.secondaryImages!.isNotEmpty) {
        existingSecondaryImageUrls = List.from(stire.secondaryImages!);
      }
    }
  }

  Future<void> createStire(BuildContext context, String mode) async {
    if (formKey.currentState!.validate()) {
      // Updated validation for edit mode
      if (mainImageFile == null && (originalStire?.principalImage == null || originalStire!.principalImage!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Te rog selectează imaginea principală'),
          ),
        );
        return;
      }

      if (selectedType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Te rog selectează tipul de știre'),
          ),
        );
        return;
      }

      if (selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Te rog selectează categoria'),
          ),
        );
        return;
      }

      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        if (mode == "create") {
          // Create new stire
          String stireId = await createStireService.getStireId();

          List<String> secondaryImagePaths = secondaryImageFiles
              .map((file) => file.path)
              .toList();

          Stire stire = createStireService.createStire(
            stireId,
            titleController.text,
            descriptionController.text,
            publicationDate,
            selectedType,
            selectedCategory!, // Now passing NewsCategory instead of StireCategory
            textButtonController.text,
            linkButtonController.text,
            mainImageFile!.path,
            secondaryImagePaths,
          );

          await createStireService.saveStire(stire);

          if (!context.mounted) return;
          Navigator.of(context).pop(); // Hide loading indicator

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Știrea a fost publicată cu succes!')),
          );
        } else if (mode == "edit") {
          // Update existing stire
          updateCurrentOriginalStire();
          await createStireService.saveStire(originalStire!);

          if (!context.mounted) return;
          Navigator.of(context).pop(); // Hide loading indicator

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Știrea a fost actualizată cu succes!')),
          );
        }

        Navigator.pop(context);
      } catch (e) {
        if (!context.mounted) return;

        Navigator.of(context).pop(); // Hide loading indicator

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eroare la salvarea știrii: $e')),
        );
      }
    }
  }

  void updateCurrentOriginalStire() {
    originalStire!.title = titleController.text;
    originalStire!.description = descriptionController.text;
    originalStire!.buttonText = textButtonController.text;
    originalStire!.buttonLink = linkButtonController.text;
    originalStire!.type = selectedType!;
    originalStire!.category = selectedCategory!; // Now using NewsCategory
    originalStire!.publicationDate = publicationDate!;

    // Update main image only if a new one was selected
    if (mainImageFile != null) {
      originalStire!.principalImage = mainImageFile!.path;
    }
    // If no new image selected, keep the existing URL

    // Combine existing URLs with new file paths
    List<String> allSecondaryImages = [];
    allSecondaryImages.addAll(existingSecondaryImageUrls);
    allSecondaryImages.addAll(secondaryImageFiles.map((file) => file.path));

    originalStire!.secondaryImages = allSecondaryImages;
  }

  Future<DateTime?> selectDate(BuildContext context) async {
    CalendarHelper calendarHelper = CalendarHelper();
    return calendarHelper.selectDate(context);
  }

  Future<File?> pickImage() async {
    return ImageHelper.pickImage();
  }

  /// Add a secondary image file (always a new File)
  void addSecondaryImage(File imageFile) {
    secondaryImageFiles.add(imageFile);
  }

  /// Remove a secondary image at specific index
  void removeSecondaryImage(int index) {
    int existingUrlCount = existingSecondaryImageUrls.length;

    if (index < existingUrlCount) {
      // Removing an existing URL
      existingSecondaryImageUrls.removeAt(index);
    } else {
      // Removing a newly added file
      int fileIndex = index - existingUrlCount;
      if (fileIndex >= 0 && fileIndex < secondaryImageFiles.length) {
        secondaryImageFiles.removeAt(fileIndex);
      }
    }
  }

  /// Get all secondary image paths for display (both URLs and file paths)
  List<String> getSecondaryImagePaths() {
    List<String> allPaths = [];
    allPaths.addAll(existingSecondaryImageUrls);
    allPaths.addAll(secondaryImageFiles.map((file) => file.path));
    return allPaths;
  }

  String? getMainImageToDisplay() {
    // Priority: newly selected file > existing stire image URL > null
    if (mainImageFile != null) {
      return mainImageFile!.path; // Return file path as String
    } else if (originalStire?.principalImage != null && originalStire!.principalImage!.isNotEmpty) {
      return originalStire!.principalImage; // Return URL as String
    }
    return null;
  }

  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    textButtonController.dispose();
    linkButtonController.dispose();
    categoryController.dispose();
  }
}