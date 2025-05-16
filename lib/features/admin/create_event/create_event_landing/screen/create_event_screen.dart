import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../../enums/event_type.dart';
import '../controller/create_event_controller.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  late CreateEventController controller;

  @override
  void initState() {
    super.initState();
    controller = CreateEventController();
  }

  @override
  void dispose() {
    controller.nameController.dispose();
    controller.locationController.dispose();
    controller.descriptionController.dispose();
    controller.nrMissionsController.dispose();
    controller.startCodeController.dispose();
    super.dispose();
  }

  Future<void> selectDate(BuildContext context, bool isStartTime) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          if (isStartTime) {
            controller.startTime = selectedDateTime;
          } else {
            controller.deadlineEnrollment = selectedDateTime;
          }
        });
      }
    }
  }
  Future<void> pickImage(bool isLandingImage) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery); // or ImageSource.camera
    if (pickedFile != null) {
      setState(() {
        if (isLandingImage) {
          controller.landingImageFile = File(pickedFile.path);
        } else {
          controller.taskBackgroundImageFile = File(pickedFile.path);
        }
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: controller.nameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
                validator: (value) => value!.isEmpty ? 'Please enter an event name' : null,
              ),
              TextFormField(
                controller: controller.locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) => value!.isEmpty ? 'Please enter a Location' : null,
              ),
              TextFormField(
                controller: controller.descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => value!.isEmpty ? 'Please enter a Description' : null,
              ),
              TextFormField(
                controller: controller.nrMissionsController,
                decoration: const InputDecoration(labelText: 'Number of Missions'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter the number of missions';
                  if (int.tryParse(value) == null) return 'Please enter a valid number';
                  return null;
                },
              ),
              ListTile(
                title: Text(
                  controller.startTime == null
                      ? 'Select Start Time'
                      : 'Start Time: ${DateFormat('yyyy-MM-dd HH:mm').format(controller.startTime!)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => selectDate(context, true),
              ),
              ListTile(
                title: Text(
                  controller.deadlineEnrollment == null
                      ? 'Select Enrollment Deadline'
                      : 'Deadline: ${DateFormat('yyyy-MM-dd HH:mm').format(controller.deadlineEnrollment!)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => selectDate(context, false),
              ),
              DropdownButtonFormField<EventType>(
                decoration: const InputDecoration(labelText: 'Event Type'),
                value: controller.selectedType,
                items: EventType.values
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    controller.selectedType = value;
                  });
                },
                validator: (value) => value == null ? 'Please select an event type' : null,
              ),
              ListTile(
                title: Text(controller.landingImageFile == null
                    ? 'Select Landing Image'
                    : 'Landing Image: ${controller.landingImageFile!.path.split('/').last}'),
                trailing: const Icon(Icons.image),
                onTap: () => pickImage(true),
              ),
              ListTile(
                title: Text(controller.taskBackgroundImageFile == null
                    ? 'Select Task Background Image'
                    : 'Task Background: ${controller.taskBackgroundImageFile!.path.split('/').last}'),
                trailing: const Icon(Icons.image),
                onTap: () => pickImage(false),
              ),
              TextFormField(
                controller: controller.startCodeController,
                decoration: const InputDecoration(labelText: 'Start Code'),
                validator: (value) => value!.isEmpty ? 'Please enter a code ' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => controller.createEvent(context, () => {
                  setState(() {
                    controller.startTime = null;
                    controller.deadlineEnrollment = null;
                    controller.selectedType = null;
                  })
                }),
                child: const Text('Create Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}