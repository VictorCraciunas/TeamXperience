import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/enums/difficulty.dart';
import 'package:teamxperience/enums/screen_animation.dart';
import 'package:teamxperience/features/admin/create_event/logic/coordinates.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/service/event_service/event_completeness.dart';
import 'package:teamxperience/state_management/events_state_management.dart';
import 'package:teamxperience/ui/components/feedback/snackbars.dart';
import 'package:teamxperience/utils/calendar_helper.dart';
import 'package:teamxperience/utils/event_formats.dart';
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

  // The fields of the event page.
  final areaController = TextEditingController();
  final finishPointController = TextEditingController();

  /// Kilometres; a comma works as a decimal point.
  final routeKmController = TextEditingController();

  /// Minutes.
  final durationController = TextEditingController();
  final teamSizeMinController = TextEditingController(text: '2');
  final teamSizeMaxController = TextEditingController(text: '6');

  /// Empty means no limit.
  final maxTeamsController = TextEditingController();

  /// "45.7971, 24.1520", as Google Maps copies it.
  final startPinController = TextEditingController();
  final meetingNoteController = TextEditingController();
  final arriveBeforeController = TextEditingController(text: '15');

  /// One item per line.
  final whatToBringController = TextEditingController();
  final storyController = TextEditingController();

  /// Empty means TeamXperience.
  final organiserController = TextEditingController();

  // "Începutul jocului".
  final introLetterController = TextEditingController();
  final introSignatureController = TextEditingController();

  // "Sfârșitul jocului".
  final finishTitleController = TextEditingController();
  final finishMessageController = TextEditingController();

  /// 0 to 5; empty or anything else means 1.
  final hintsPerMissionController = TextEditingController(text: '1');

  /// 10 to 180 minutes; empty or anything else means 60.
  final enterWindowController = TextEditingController(text: '60');
  Difficulty? difficulty;

  File? landingImageFile;
  File? taskBackgroundImageFile;

  // Date fields
  DateTime? dateEvent;
  DateTime? deadlineEnrollment;
  DateTime? dateStartEnrollement;

  // EventType field
  EventType? selectedType;

  /// How the components of a puzzle appear when it opens.
  ScreenAnimation screenAnimation = ScreenAnimation.fade;

  /// How long one component takes to come in and the pause before the next one,
  /// in milliseconds; null means automatic.
  int? animationDuration;
  int? animationDelay;

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
      screenAnimation = event.screenAnimation;
      animationDuration = event.animationDuration;
      animationDelay = event.animationDelay;
      dateEvent = event.dateEvent;
      deadlineEnrollment = event.dateDeadlineEnrollment;
      dateStartEnrollement = event.dateStartEnrollment;
      punctDeStartController.text = event.punctDeStart ?? "";
      _loadPageFields(event);
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

  void _loadPageFields(Event event) {
    final km = event.effectiveRouteKm;
    final minutes = event.effectiveDurationMinutes;
    final max = event.maxTeams;
    final lat = event.startLatitude;
    final lng = event.startLongitude;
    areaController.text = event.area ?? '';
    finishPointController.text = event.finishPoint ?? '';
    routeKmController.text = km == null ? '' : formatKm(km).replaceAll(' km', '');
    durationController.text = minutes == null ? '' : '$minutes';
    difficulty = event.effectiveDifficulty;
    teamSizeMinController.text = '${event.teamSizeMin}';
    teamSizeMaxController.text = '${event.teamSizeMax}';
    maxTeamsController.text = max == null ? '' : '$max';
    startPinController.text = lat == null || lng == null ? '' : formatCoordinates(lat, lng);
    meetingNoteController.text = event.meetingPointNote ?? '';
    arriveBeforeController.text = '${event.arriveMinutesBefore}';
    whatToBringController.text = event.whatToBring.join('\n');
    storyController.text = event.story ?? '';
    organiserController.text = event.organiserName ?? '';
    introLetterController.text = event.introLetter ?? '';
    introSignatureController.text = event.introSignature ?? '';
    finishTitleController.text = event.finishTitle ?? '';
    finishMessageController.text = event.finishMessage ?? '';
    hintsPerMissionController.text = '${event.hintsPerMission}';
    enterWindowController.text = '${event.enterWindowMinutes}';
  }

  /// The message for a start pin that cannot be read, or null.
  static String? startPinProblem(String text) =>
      text.trim().isEmpty || parseCoordinates(text) != null ? null : 'Coordonate greșite';

  static int? _inRange(String text, int min, int max) {
    final value = int.tryParse(text.trim());
    return value != null && value >= min && value <= max ? value : null;
  }

  /// The message for a hint count that is not 0 to 5, or null.
  static String? hintsProblem(String text) =>
      text.trim().isEmpty || _inRange(text, 0, 5) != null ? null : 'Între 0 și 5';

  /// The message for minutes that are not 10 to 180, or null.
  static String? enterWindowProblem(String text) =>
      text.trim().isEmpty || _inRange(text, 10, 180) != null ? null : 'Între 10 și 180 de minute';

  static String? _textOrNull(TextEditingController c) {
    final text = c.text.trim();
    return text.isEmpty ? null : text;
  }

  static int? _whole(TextEditingController c) => int.tryParse(c.text.trim());

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
      ..type = selectedType
      ..screenAnimation = screenAnimation
      ..animationDuration = animationDuration
      ..animationDelay = animationDelay
      ..dateEvent = dateEvent
      ..dateDeadlineEnrollment = deadlineEnrollment
      ..dateStartEnrollment = dateStartEnrollement
      ..landingImageUrl = landingImageFile?.path
      ..taskBackgroundImageUrl = taskBackgroundImageFile?.path;
    _fillPageFields(event);
  }

  void _fillPageFields(Event event) {
    final km = double.tryParse(routeKmController.text.trim().replaceAll(',', '.'));
    final minutes = _whole(durationController);
    final level = difficulty;
    final pin = parseCoordinates(startPinController.text);
    event
      ..area = _textOrNull(areaController)
      ..finishPoint = _textOrNull(finishPointController)
      ..routeLengthKm = km
      ..durationMinutes = minutes
      ..difficulty = level
      ..teamSizeMin = _whole(teamSizeMinController) ?? 2
      ..teamSizeMax = _whole(teamSizeMaxController) ?? 6
      ..maxTeams = _whole(maxTeamsController)
      ..startLatitude = pin?.lat
      ..startLongitude = pin?.lng
      ..meetingPointNote = _textOrNull(meetingNoteController)
      ..arriveMinutesBefore = _whole(arriveBeforeController) ?? 15
      ..whatToBring = [
        for (final line in whatToBringController.text.split('\n'))
          if (line.trim().isNotEmpty) line.trim(),
      ]
      ..story = _textOrNull(storyController)
      ..organiserName = _textOrNull(organiserController)
      ..introLetter = _textOrNull(introLetterController)
      ..introSignature = _textOrNull(introSignatureController)
      ..finishTitle = _textOrNull(finishTitleController)
      ..finishMessage = _textOrNull(finishMessageController)
      ..hintsPerMission = _inRange(hintsPerMissionController.text, 0, 5) ?? 1
      ..enterWindowMinutes = _inRange(enterWindowController.text, 10, 180) ?? 60
      // Cards and older screens still read the text fields. An empty number
      // keeps the old text, so text the form could not read is not lost.
      ..lungimeTraseu = km == null ? (event.lungimeTraseu ?? '') : formatKm(km)
      ..durata = minutes == null ? (event.durata ?? '') : formatDuration(minutes)
      ..dificultate = level == null ? (event.dificultate ?? '') : difficultyLabel(level);
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
