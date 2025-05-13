import 'dart:io';

import 'package:flutter/material.dart';
import 'package:teamxperience/backend/storage/storage_images.dart';
import 'package:teamxperience/model/event.dart';

import '../../../../../enums/event_type.dart';
import '../service/create_event_service.dart';

class CreateEventController{
  final CreateEventService createEventService = CreateEventService();
  final ImageRepo imageRepo = ImageRepo();
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  final nrMissionsController = TextEditingController();
  final landingImageUrlController = TextEditingController();
  final taskBackgroundImageUrlController = TextEditingController();
  final startCodeController = TextEditingController();

  File? landingImageFile;
  File? taskBackgroundImageFile;

  // Date fields
  DateTime? startTime;
  DateTime? deadlineEnrollment;

  // EventType field
  EventType? selectedType;

  Future<void> createEvent(BuildContext context, Function refreshUI) async {
    if (formKey.currentState!.validate()) {
      if (startTime == null || deadlineEnrollment == null || selectedType == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select start time, enrollment deadline, and event type')),
        );
        return;
      }
      // if (landingImageFile == null || taskBackgroundImageFile == null) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Please select both landing and task background images')),
      //   );
      //   return;
      // }

      try {

        String eventId = await createEventService.getEventId();

        // String? landingImageUrl = await imageRepo.uploadImage(landingImageFile!, eventId, 'landing');
        // String? taskBackgroundImageUrl = await imageRepo.uploadImage(taskBackgroundImageFile!, eventId,'task_background');

        // if (landingImageUrl == null || taskBackgroundImageUrl == null) {
        //   if (!context.mounted) return;
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(content: Text('Failed to upload images')),
        //   );
        //   return;
        // }

            Event event = await createEventService.createEvent(
              eventId,
          nameController.text,
          startTime!,
          deadlineEnrollment!,
          locationController.text,
          descriptionController.text,
          int.parse(nrMissionsController.text),
          selectedType!,
              // landingImageUrl,
              // taskBackgroundImageUrl,
              "test",
              "test",
          startCodeController.text,
        );
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event created successfully')),
        );
        // Clear form after success
        formKey.currentState!.reset();
        refreshUI();
        Navigator.pushNamed(context, '/add_missions',arguments: event);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create event: $e')),
        );
      }
    }
  }


}