import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teamxperience/backend/storage/storage_images.dart';
import 'package:teamxperience/model/event.dart';

import '../../../../../enums/event_type.dart';
import '../service/create_event_service.dart';

class CreateEventController {
  final CreateEventService createEventService = CreateEventService();
  final ImageRepo imageRepo = ImageRepo();
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  final nrMissionsController = TextEditingController();
  final startCodeController = TextEditingController();
  final dateEventController = TextEditingController(); // Controller for start time
  final dateDeadlineRegistrationController = TextEditingController();
  final dateStartRegistrationController = TextEditingController();

  File? landingImageFile;
  File? taskBackgroundImageFile;

  // Date fields
  DateTime? dateEvent;
  DateTime? deadlineEnrollment;
  DateTime? dateStartEnrollemnt;

  // EventType field
  EventType? selectedType;

  Future<void> createEvent(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      if (landingImageFile == null || taskBackgroundImageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please select both landing and task background images',
            ),
          ),
        );
        return;
      }

      try {
        String eventId = await createEventService.getEventId();

        Event event = await createEventService.createEvent(
          eventId,
          nameController.text,
          dateEvent!,
          deadlineEnrollment!,
          dateStartEnrollemnt!,
          locationController.text,
          descriptionController.text,
          int.parse(nrMissionsController.text),
          selectedType!,
          landingImageFile!.path,
          taskBackgroundImageFile!.path,
          // 'test',
          // 'test',
          startCodeController.text,
        );
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event created successfully')),
        );
        // Clear form after success
        // formKey.currentState!.reset();
        Navigator.pushNamed(context, '/add_missions', arguments: event);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to create event: $e')));
      }
    }
  }

  Future<DateTime?> selectDate(BuildContext context) async {
    // Pick the date (or null if they cancel)
    final pickedDate = await showDatePicker(
      context:  context,
      initialDate: DateTime.now(),
      firstDate:   DateTime.now(),
      lastDate:    DateTime(2100),
    );

    if (pickedDate == null) {
      // user tapped “Cancel” on the date picker
      return null;
    }

    // Now pick a time (or null if they cancel)
    final pickedTime = await showTimePicker(
      context:context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) {
      // user tapped “Cancel” on the time picker
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

  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }
}
