import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/service/event_service/event_completeness.dart';
import 'package:teamxperience/state_management/events_state_management.dart';
import 'package:teamxperience/ui/components/feedback/snackbars.dart';
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
  final dateEventController =
      TextEditingController(); // Controller for start time
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

  /// The draft saved from this form, so saving again updates it instead of
  /// creating another one.
  Event? _savedDraft;

  CreateEventController(Event? event) {
    if (event != null) {
      originalEvent = event;
      nameController.text = event.name ?? '';
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
        dateEventController.text = _format(dateEvent!);
      }
      if (deadlineEnrollment != null) {
        dateDeadlineRegistrationController.text = _format(deadlineEnrollment!);
      }
      if (dateStartEnrollement != null) {
        dateStartRegistrationController.text = _format(dateStartEnrollement!);
      }
      // Assuming image paths are local for simplicity; adjust if URLs
      final landing = event.landingImageUrl;
      if (landing != null && landing.isNotEmpty)
        landingImageFile = File(landing);
      final background = event.taskBackgroundImageUrl;
      if (background != null && background.isNotEmpty)
        taskBackgroundImageFile = File(background);
    }
  }

  static String _format(DateTime date) =>
      DateFormat('yyyy-MM-dd HH:mm').format(date);

  /// Copies what the form holds onto [event]. Nothing is required: empty fields
  /// stay empty, so a half filled form can be saved as a draft.
  void _fill(Event event) {
    event
      ..name = nameController.text.trim()
      ..location = locationController.text.trim()
      ..description = descriptionController.text.trim()
      ..startCode = startCodeController.text.trim()
      ..punctDeStart = punctDeStartController.text.trim()
      ..lungimeTraseu = lungimeController.text.trim()
      ..durata = durataController.text.trim()
      ..dificultate = dificultateController.text.trim()
      ..type = selectedType
      ..dateEvent = dateEvent
      ..dateDeadlineEnrollment = deadlineEnrollment
      ..dateStartEnrollment = dateStartEnrollement
      ..landingImageUrl = landingImageFile?.path
      ..taskBackgroundImageUrl = taskBackgroundImageFile?.path;
  }

  /// A new event from the form (it gets an id when saved). If the form was
  /// opened from another event, its missions come along.
  Event buildNewEvent() {
    final event = Event(eventId: '');
    _fill(event);

    final source = originalEvent;
    if (source == null || source.missions.isEmpty) {
      event.nrMissions = 1;
      event.missions.add(Mission(id: "0"));
    } else {
      event.missions = source.missions;
      event.nrMissions = source.missions.length;
    }
    return event;
  }

  /// Writes the form onto the event it was opened with (editing, or resuming a
  /// draft) and returns it, with its id, missions and status untouched.
  Event applyToOriginal() {
    final event = originalEvent;
    if (event == null) {
      throw StateError('There is no event to apply the form to');
    }
    _fill(event);
    return event;
  }

  /// A draft needs at least a name, so its card has a title.
  bool get canSaveDraft => nameController.text.trim().isNotEmpty;

  /// A message when the enrolment dates do not make sense together, else null.
  /// Dates that are not set yet are not a problem here.
  String? enrollmentProblem() {
    final opens = dateStartEnrollement;
    final closes = deadlineEnrollment;
    if (opens == null || closes == null) return null;

    final probe = Event(
      eventId: '',
      dateEvent: dateEvent,
      dateStartEnrollment: opens,
      dateDeadlineEnrollment: closes,
    );
    final issues = eventIssues(probe);
    if (issues.contains(EventIssue.enrollmentOrder)) {
      return EventIssue.enrollmentOrder.label;
    }
    if (issues.contains(EventIssue.enrollmentAfterEvent)) {
      return EventIssue.enrollmentAfterEvent.label;
    }
    return null;
  }

  /// Continue to the missions. [mode] is 'create', 'blueprint' (copied from
  /// another event), 'edit' (a published event) or 'draft' (resuming a draft).
  Future<void> createEvent(BuildContext context, String mode) async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final problem = enrollmentProblem();
    if (problem != null) {
      MySnackBars.warningSnackBar(context, title: problem);
      return;
    }

    try {
      if (mode == "create" || mode == "blueprint") {
        final event = buildNewEvent();
        if (!context.mounted) return;
        Navigator.pushNamed(
          context,
          Routes.addMissions,
          arguments: {'event': event, 'mode': mode},
        );
      } else {
        // 'edit' updates a published event, 'draft' carries on with a draft.
        // Both show the missions they already have as they are.
        final event = applyToOriginal();
        Navigator.pushNamed(
          context,
          Routes.addMissions,
          arguments: {
            'event': event,
            'mode': 'edit',
            'isDraft': mode == 'draft',
          },
        );
      }
    } catch (e) {
      MySnackBars.errorSnackBar(
        context,
        title: 'Nu am putut pregăti evenimentul',
        message: '$e',
      );
    }
  }

  /// Saves what is filled in as a draft and leaves the form. Skips the form
  /// validation on purpose, a draft can be saved half way.
  Future<void> saveDraft(BuildContext context, String mode) async {
    if (!canSaveDraft) {
      MySnackBars.warningSnackBar(
        context,
        title: 'Dă un nume evenimentului ca să-l salvezi',
      );
      return;
    }

    final list = context.read<EventList>();
    final navigator = Navigator.of(context);

    try {
      final resuming = mode == 'draft' || _savedDraft != null;
      final saved = _savedDraft;
      final Event event;
      if (saved != null) {
        event = saved;
        _fill(event);
      } else if (resuming) {
        event = applyToOriginal();
      } else {
        event = buildNewEvent();
      }

      _savedDraft = await list.saveDraft(event, wizardStep: 1);

      if (!context.mounted) return;
      MySnackBars.successSnackBar(context, title: 'Ciorna a fost salvată');
      navigator.pop();
    } catch (e) {
      if (!context.mounted) return;
      MySnackBars.errorSnackBar(
        context,
        title: 'Nu am putut salva ciorna',
        message: '$e',
      );
    }
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
    } else if (originalEvent?.landingImageUrl != null &&
        originalEvent!.landingImageUrl!.isNotEmpty) {
      return originalEvent!.landingImageUrl; // Return URL as String
    }
    return null;
  }

  // Method to get the image URL/path to display for task background
  String? getTaskBackgroundImageToDisplay() {
    // Priority: newly selected file > existing event image URL > null
    if (taskBackgroundImageFile != null) {
      return taskBackgroundImageFile!.path; // Return file path as String
    } else if (originalEvent?.taskBackgroundImageUrl != null &&
        originalEvent!.taskBackgroundImageUrl!.isNotEmpty) {
      return originalEvent!.taskBackgroundImageUrl; // Return URL as String
    }
    return null;
  }
}
