import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateNewsController {
  // Form key
  final formKey = GlobalKey<FormState>();

  // Text editing controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();
  final categoryController = TextEditingController();
  final textButtonController = TextEditingController();
  final linkButtonController = TextEditingController();

  // Image files
  File? mainImageFile;
  File? secondaryImageFile;

  // Date field
  DateTime? publicationDate;

  // Dropdown selections
  String? selectedNewsType;
  String? selectedCategory;

  // Dropdown options
  final List<String> newsTypes = [
    'Știri generale',
    'Evenimente',
    'Anunțuri',
    'Promoții',
    'Actualizări'
  ];

  final List<String> categories = [
    'Sport',
    'Tehnologie',
    'Cultură',
    'Business',
    'Educație',
    'Sănătate',
    'Travel'
  ];

  // Method to select date and time
  Future<DateTime?> selectDate(BuildContext context) async {
    // Pick the date (or null if they cancel)
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) {
      // User tapped "Cancel" on the date picker
      return null;
    }

    // Now pick a time (or null if they cancel)
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) {
      // User tapped "Cancel" on the time picker
      return null;
    }

    // Both non-null ⇒ build and return the combined DateTime
    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }

  // Method to pick image from gallery
  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Method to get main image to display
  String? getMainImageToDisplay() {
    if (mainImageFile != null) {
      return mainImageFile!.path;
    }
    return null;
  }

  // Method to get secondary image to display
  String? getSecondaryImageToDisplay() {
    if (secondaryImageFile != null) {
      return secondaryImageFile!.path;
    }
    return null;
  }

  // Method to publish news (placeholder for logic)
  Future<void> publishNews(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      // Validate images
      if (mainImageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Te rog selectează imaginea principală'),
          ),
        );
        return;
      }

      // TODO: Add your publish news logic here
      print('Publishing news...');
      print('Title: ${titleController.text}');
      print('Description: ${descriptionController.text}');
      print('Publication Date: $publicationDate');
      print('News Type: $selectedNewsType');
      print('Category: $selectedCategory');
      print('Button Text: ${textButtonController.text}');
      print('Button Link: ${linkButtonController.text}');
      print('Main Image: ${mainImageFile?.path}');
      print('Secondary Image: ${secondaryImageFile?.path}');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Știrea a fost publicată cu succes!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back or to another screen
      // Navigator.pop(context);
    }
  }

  // Dispose method to clean up controllers
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    categoryController.dispose();
    textButtonController.dispose();
    linkButtonController.dispose();
  }
}