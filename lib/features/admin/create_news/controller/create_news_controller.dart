import 'dart:io';
import 'package:flutter/material.dart';
import 'package:teamxperience/model/stire.dart';
import 'package:teamxperience/enums/stire_type.dart';
import 'package:teamxperience/enums/stire_category.dart';
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

  File? mainImageFile;
  List<File> secondaryImageFiles = []; // Changed to support multiple secondary images

  DateTime? publicationDate;
  StireType? selectedType;
  StireCategory? selectedCategory;

  CreateStireController();

  Future<void> createStire(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      if (mainImageFile == null) {
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

        String stireId = await createStireService.getStireId();

        // Convert secondary image files to paths
        List<String> secondaryImagePaths = secondaryImageFiles
            .map((file) => file.path)
            .toList();

        Stire stire = createStireService.createStire(
          stireId,
          titleController.text,
          descriptionController.text,
          publicationDate!,
          selectedType!,
          selectedCategory!,
          textButtonController.text,
          linkButtonController.text,
          mainImageFile!.path,
          secondaryImagePaths,
        );

        // Save the stire with image upload logic
        await createStireService.saveStire(stire);

        if (!context.mounted) return;

        // Hide loading indicator
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Știrea a fost publicată cu succes!')),
        );
        Navigator.pop(context);
      } catch (e) {
        if (!context.mounted) return;

        // Hide loading indicator
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eroare la crearea știrii: $e')),
        );
      }
    }
  }

  Future<DateTime?> selectDate(BuildContext context) async {
    CalendarHelper calendarHelper = CalendarHelper();
    return calendarHelper.selectDate(context);
  }

  Future<File?> pickImage() async {
    return ImageHelper.pickImage();
  }

  /// Add a secondary image file
  void addSecondaryImage(File imageFile) {
    secondaryImageFiles.add(imageFile);
  }

  /// Remove a secondary image file at specific index
  void removeSecondaryImage(int index) {
    if (index >= 0 && index < secondaryImageFiles.length) {
      secondaryImageFiles.removeAt(index);
    }
  }

  /// Get all secondary image paths for display
  List<String> getSecondaryImagePaths() {
    return secondaryImageFiles.map((file) => file.path).toList();
  }

  String? getMainImageToDisplay() {
    if (mainImageFile != null) {
      return mainImageFile!.path;
    }
    return null;
  }

  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    textButtonController.dispose();
    linkButtonController.dispose();
  }
}