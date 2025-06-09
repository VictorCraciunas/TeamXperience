import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:teamxperience/backend/storage/storage_images.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/model/event.dart';

import '../../../../../enums/event_type.dart';
import '../../../../../model/mission.dart';
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
  DateTime? dateStartEnrollement;

  // EventType field
  EventType? selectedType;

  Event? originalEvent;

  CreateEventController(Event? event) {
    if (event != null) {
      originalEvent = event;
      nameController.text = event.name!;
      locationController.text = event.location ?? "";
      descriptionController.text = event.description ?? "";
      startCodeController.text = event.startCode ?? "";
      selectedType = event.type;
      dateEvent = event.dateEvent;
      deadlineEnrollment = event.dateDeadlineEnrollment;
      dateStartEnrollement = event.dateStartEnrollment;
      if (dateEvent != null) {
        dateEventController.text = DateFormat('yyyy-MM-dd HH:mm').format(dateEvent!);
      }
      if (deadlineEnrollment != null) {
        dateDeadlineRegistrationController.text = DateFormat('yyyy-MM-dd HH:mm').format(deadlineEnrollment!);
      }
      if (dateStartEnrollement != null) {
        dateStartRegistrationController.text = DateFormat('yyyy-MM-dd HH:mm').format(dateStartEnrollement!);
      }
      // Assuming image paths are local for simplicity; adjust if URLs
      if (event.landingImageUrl != null) landingImageFile = File(event.landingImageUrl!);
      if (event.taskBackgroundImageUrl != null) taskBackgroundImageFile = File(event.taskBackgroundImageUrl!);
    }
  }



  Future<void> createEvent(BuildContext context, String mode) async {
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

      if (mode == "create" || mode == "blueprint"){
        try {
          String eventId = await createEventService.getEventId();

          Event event =  createEventService.createEvent(
            eventId,
            nameController.text,
            dateEvent!,
            deadlineEnrollment!,
            dateStartEnrollement!,
            locationController.text,
            descriptionController.text,
           // int.parse(nrMissionsController.text),
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
          // initialize with one mission

          // Initialize with one mission
          if (originalEvent == null || originalEvent!.missions.isEmpty) {
            // For new events or events without missions
            event.nrMissions = 1;
            event.missions.add(Mission(id: "0"));
          } else {
            // For blueprint mode where originalEvent exists and has missions
            event.missions = originalEvent!.missions;
            event.nrMissions = originalEvent!.missions.length;
          }

          Navigator.pushNamed(context, Routes.addMissions, arguments: {'event': event, 'mode': mode},);
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to create event: $e')));
        }
      }
      else{
            updateCurrentOriginalEvent();
            Navigator.pushNamed(context, Routes.addMissions, arguments: {'event': originalEvent, 'mode': mode},);

      }

    }
  }

  void updateCurrentOriginalEvent(){
    originalEvent!.name = nameController.text;
    originalEvent!.location = locationController.text;
    originalEvent!.description = descriptionController.text;
    originalEvent!.startCode = startCodeController.text;
    originalEvent!.type = selectedType!;
    originalEvent!.dateEvent = dateEvent!;
    originalEvent!.dateDeadlineEnrollment = deadlineEnrollment!;
    originalEvent!.dateStartEnrollment = dateStartEnrollement!;
    originalEvent!.landingImageUrl = landingImageFile!.path;
    originalEvent!.taskBackgroundImageUrl = taskBackgroundImageFile!.path;
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

  String? getLandingImageToDisplay() {
    // Priority: newly selected file > existing event image URL > null
    if (landingImageFile != null) {
      return landingImageFile!.path; // Return file path as String
    } else if (originalEvent?.landingImageUrl != null && originalEvent!.landingImageUrl!.isNotEmpty) {
      return originalEvent!.landingImageUrl; // Return URL as String
    }
    return null;
  }

// Method to get the image URL/path to display for task background
  String? getTaskBackgroundImageToDisplay() {
    // Priority: newly selected file > existing event image URL > null
    if (taskBackgroundImageFile != null) {
      return taskBackgroundImageFile!.path; // Return file path as String
    } else if (originalEvent?.taskBackgroundImageUrl != null && originalEvent!.taskBackgroundImageUrl!.isNotEmpty) {
      return originalEvent!.taskBackgroundImageUrl; // Return URL as String
    }
    return null;
  }
}
