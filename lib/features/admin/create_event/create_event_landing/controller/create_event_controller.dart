import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/utils/calendar_helper.dart';
import 'package:teamxperience/utils/image_helper.dart';

import '../../../../../enums/event_type.dart';
import '../../../../../model/mission.dart';

class CreateEventController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final punctDeStartController = TextEditingController();
  final descriptionController = TextEditingController();
  final startCodeController = TextEditingController();
  final dateEventController = TextEditingController(); // Controller for start time
  final dateDeadlineRegistrationController = TextEditingController();
  final dateStartRegistrationController = TextEditingController();

  final lungimeController = TextEditingController();
  final durataController = TextEditingController();
  final dificultateController = TextEditingController();

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
      punctDeStartController.text = event.punctDeStart ?? "";
      lungimeController.text = event.lungimeTraseu ?? "";
      durataController.text = event.durata ?? "";
      dificultateController.text = event.dificultate ?? "";
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
            content: Text('Please select both landing and task background images'),
          ),
        );
        return;
      }

      try {
        if (mode == "create" || mode == "blueprint") {
          // Create new event object
          Event event = Event(
            eventId: '', // Let EventService generate this
            name: nameController.text,
            dateEvent: dateEvent!,
            dateDeadlineEnrollment: deadlineEnrollment!,
            dateStartEnrollment: dateStartEnrollement!,
            location: locationController.text,
            description: descriptionController.text,
            type: selectedType!,
            landingImageUrl: landingImageFile!.path,
            taskBackgroundImageUrl: taskBackgroundImageFile!.path,
            startCode: startCodeController.text,
            punctDeStart: punctDeStartController.text,
            lungimeTraseu: lungimeController.text,
            durata: durataController.text,
            dificultate: dificultateController.text,
          );

          // Initialize missions
          if (originalEvent == null || originalEvent!.missions.isEmpty) {
            event.nrMissions = 1;
            event.missions.add(Mission(id: "0"));
          } else {
            event.missions = originalEvent!.missions;
            event.nrMissions = originalEvent!.missions.length;
          }

          if (!context.mounted) return;
          Navigator.pushNamed(
            context,
            Routes.addMissions,
            arguments: {'event': event, 'mode': mode},
          );
        } else {
          // Edit mode - update existing event
          updateCurrentOriginalEvent();
          Navigator.pushNamed(
            context,
            Routes.addMissions,
            arguments: {'event': originalEvent, 'mode': mode},
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to prepare event: $e')),
        );
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
    originalEvent!.punctDeStart = punctDeStartController.text;
    originalEvent!.lungimeTraseu = lungimeController.text;
    originalEvent!.durata = durataController.text;
    originalEvent!.dificultate = dificultateController.text;
  }

  Future<DateTime?> selectDate(BuildContext context) async {
    CalendarHelper calendarHelper = CalendarHelper();
    return calendarHelper.selectDate(context);
  }

  Future<File?> pickImage() async {
      return ImageHelper.pickImage();
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
