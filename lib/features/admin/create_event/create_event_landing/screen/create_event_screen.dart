import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/misc/app_svg_icon.dart';
import 'package:teamxperience/enums/difficulty.dart';
import 'package:teamxperience/enums/screen_animation.dart';
import 'package:teamxperience/utils/event_formats.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/create_components/optional_slider.dart';
import 'package:teamxperience/features/admin/create_event/common_widgets/pin_field_button.dart';
import 'package:teamxperience/features/admin/create_event/logic/coordinates.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:intl/intl.dart';
import 'package:teamxperience/features/admin/create_event/common_widgets/upload_image.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';
import '../../../../../enums/event_type.dart';
import 'package:teamxperience/ui/components/inputs/app_dropdown.dart';
import 'package:teamxperience/ui/components/inputs/app_text_field.dart';
import '../controller/create_event_controller.dart';
import '../widgets/game_start_section.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  late CreateEventController controller;
  late String mode;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (!_initialized) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      final Event? event = args?['event'];
      final bool isBlueprint = args?['isBlueprint'] ?? false;
      final bool isDraft = args?['isDraft'] ?? false;

      if (event == null) {
        mode = 'create';
      } else if (isDraft) {
        mode = 'draft';
      } else if (isBlueprint) {
        mode = 'blueprint';
      } else {
        mode = 'edit';
      }

      controller = CreateEventController(event);
      _initialized = true;
    }
  }

  @override
  void dispose() {
    controller.nameController.dispose();
    controller.locationController.dispose();
    controller.descriptionController.dispose();
    controller.startCodeController.dispose();
    for (final c in [
      controller.areaController,
      controller.finishPointController,
      controller.routeKmController,
      controller.durationController,
      controller.teamSizeMinController,
      controller.teamSizeMaxController,
      controller.maxTeamsController,
      controller.startPinController,
      controller.meetingNoteController,
      controller.arriveBeforeController,
      controller.whatToBringController,
      controller.storyController,
      controller.organiserController,
      controller.introLetterController,
      controller.introSignatureController,
      controller.hintsPerMissionController,
      controller.enterWindowController,
      controller.finishTitleController,
      controller.finishMessageController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.page,
      appBar: MyAppBar(
        appBarText:
            mode == 'edit'
                ? 'Editează Eveniment'
                : mode == 'draft'
                ? 'Continuă ciorna'
                : mode == 'blueprint'
                ? 'Din eveniment vechi'
                : 'Eveniment Nou',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      final pickedFile = await controller.pickImage();
                      if (pickedFile == null) {
                        return;
                      }
                      setState(() {
                        controller.landingImageFile = pickedFile;
                      });
                    },
                    child: UploadImage(
                      labelText: 'Adaugă imagine eveniment (opțional)',
                      imageUrl: controller.getLandingImageToDisplay(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Nume
                  AppTextField(
                    controller: controller.nameController,
                    label: 'Nume',
                    hint: 'Numele evenimentului',
                    validator:
                        (v) =>
                            (v ?? '').trim().isEmpty
                                ? 'Introdu nume eveniment'
                                : null,
                  ),
                  const SizedBox(height: 20),

                  // Locatie
                  AppTextField(
                    controller: controller.locationController,
                    label: 'Locație',
                    hint: 'Locația evenimentului',
                    validator:
                        (v) =>
                            (v ?? '').trim().isEmpty
                                ? 'Introdu locație eveniment'
                                : null,
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: controller.areaController,
                    label: 'Zonă',
                    hint: 'Ex. Orașul de Sus',
                  ),
                  const SizedBox(height: 20),

                  AppTextField(
                    controller: controller.punctDeStartController,
                    label: 'Punct de start',
                    hint: 'Punctul de start al evenimentului',
                    validator:
                        (v) =>
                            (v ?? '').trim().isEmpty
                                ? 'Introdu Punctul de start'
                                : null,
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: controller.finishPointController,
                    label: 'Punct de final',
                    hint: 'Unde se termină traseul',
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: controller.startPinController,
                    label: 'Coordonate start',
                    hint: '45.7971, 24.1520',
                    helper: 'Copiază din Google Maps, ex. 45.7971, 24.1520',
                    validator: (v) => CreateEventController.startPinProblem(v ?? ''),
                  ),
                  const SizedBox(height: 8),
                  PinFieldButton(
                    current: () => parseCoordinates(controller.startPinController.text),
                    onPicked: (place) =>
                        controller.startPinController.text = formatCoordinates(place.lat, place.lng),
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: controller.meetingNoteController,
                    label: 'Unde vă strângeți',
                    hint: 'Ex. Piața Mare, lângă fântână',
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: controller.arriveBeforeController,
                    label: 'Veniți cu câte minute înainte',
                    hint: '15',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),

                  // Descriere
                  AppTextField(
                    controller: controller.descriptionController,
                    label: 'Descriere',
                    hint: 'Descrierea evenimentului',
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    validator:
                        (v) =>
                            (v ?? '').trim().isEmpty
                                ? 'Introdu descriere eveniment'
                                : null,
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: controller.storyController,
                    label: 'Povestea',
                    hint: 'Textul lung de pe pagina evenimentului',
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 20),

                  // Data și ora evenimentului
                  AppTextField(
                    controller: controller.dateEventController,
                    label: 'Data și ora evenimentului',
                    hint: 'Selectează data și ora',
                    readOnly: true,
                    trailing: AppSvgIcon(
                      'assets/images/calendar.svg',
                      width: 24,
                      height: 24,
                      color: context.colors.accent,
                    ),
                    onTap: () async {
                      final picked = await controller.selectDate(context);
                      if (picked != null) {
                        setState(() {
                          controller.dateEvent = picked;
                          controller.dateEventController.text = DateFormat(
                            'yyyy-MM-dd HH:mm',
                          ).format(picked);
                        });
                      }
                    },
                    validator:
                        (v) =>
                            (v ?? '').isEmpty
                                ? 'Introdu data și ora eveniment'
                                : null,
                  ),

                  //Start inscrieri
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: controller.dateStartRegistrationController,
                    label: 'Când se deschid înscrierile?',
                    hint: 'Selectează data și ora',
                    readOnly: true,
                    trailing: AppSvgIcon(
                      'assets/images/calendar.svg',
                      width: 24,
                      height: 24,
                      color: context.colors.accent,
                    ),
                    onTap: () async {
                      final picked = await controller.selectDate(context);
                      if (picked != null) {
                        setState(() {
                          controller.dateStartEnrollement = picked;
                          controller.dateStartRegistrationController.text =
                              DateFormat('yyyy-MM-dd HH:mm').format(picked);
                        });
                      }
                    },
                    validator:
                        (v) =>
                            (v ?? '').isEmpty
                                ? 'Introdu dată deschidere'
                                : null,
                  ),
                  const SizedBox(height: 20),

                  // Deadline înscriere
                  AppTextField(
                    controller: controller.dateDeadlineRegistrationController,
                    label: 'Când se inchid înscrierile?',
                    hint: 'Selectează data și ora',
                    readOnly: true,
                    trailing: AppSvgIcon(
                      'assets/images/calendar.svg',
                      width: 24,
                      height: 24,
                      color: context.colors.accent,
                    ),
                    onTap: () async {
                      final picked = await controller.selectDate(context);
                      if (picked != null) {
                        setState(() {
                          controller.deadlineEnrollment = picked;
                          controller.dateDeadlineRegistrationController.text =
                              DateFormat('yyyy-MM-dd HH:mm').format(picked);
                        });
                      }
                    },
                    validator:
                        (v) =>
                            (v ?? '').isEmpty ? 'Introdu dată închidere' : null,
                  ),
                  const SizedBox(height: 20),

                  // Tip de eveniment
                  AppDropdown<EventType>(
                    label: 'Tipul de eveniment',
                    items:
                        EventType.values
                            .map(
                              (type) => AppDropdownItem<EventType>(
                                value: type,
                                label: type.toString().split('.').last,
                              ),
                            )
                            .toList(),
                    value: controller.selectedType,
                    onChanged: (value) {
                      setState(() {
                        controller.selectedType = value;
                      });
                    },
                    hint: "Selectează tipul de eveniment",
                    validator:
                        (value) =>
                            value == null
                                ? 'Selectează tipul de eveniment'
                                : null,
                  ),
                  const SizedBox(height: 20),

                  // Cod start
                  AppTextField(
                    controller: controller.startCodeController,
                    label: 'Cod start',
                    hint: 'Introdu codul de start al evenimentului',
                    validator:
                        (v) =>
                            (v ?? '').trim().isEmpty
                                ? 'Introdu cod start'
                                : null,
                  ),

                  const SizedBox(height: 20),
                  // imagine fundal
                  GestureDetector(
                    onTap: () async {
                      final pickedFile = await controller.pickImage();
                      setState(() {
                        controller.taskBackgroundImageFile = pickedFile;
                      });
                    },
                    child: UploadImage(
                      labelText: 'Adaugă imagine fundal misiuni (opțional)',
                      imageUrl: controller.getTaskBackgroundImageToDisplay(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Animatia la deschiderea unui puzzle
                  AppDropdown<ScreenAnimation>(
                    label: 'Animație la deschiderea puzzle-ului',
                    items: [
                      for (final animation in ScreenAnimation.values)
                        AppDropdownItem<ScreenAnimation>(
                          value: animation,
                          label: animation.label,
                        ),
                    ],
                    value: controller.screenAnimation,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => controller.screenAnimation = value);
                    },
                  ),
                  if (controller.screenAnimation != ScreenAnimation.none) ...[
                    const SizedBox(height: 20),
                    OptionalSlider(
                      title: 'Durata unei componente',
                      min: 200,
                      max: 1500,
                      divisions: 26,
                      unit: 'ms',
                      value: controller.animationDuration?.toDouble(),
                      automaticValue: 600,
                      automaticNote: 'automat',
                      onChanged:
                          (value) => setState(
                            () => controller.animationDuration = value.round(),
                          ),
                    ),
                    const SizedBox(height: 20),
                    OptionalSlider(
                      title: 'Pauza până la următoarea',
                      min: 0,
                      max: 600,
                      divisions: 12,
                      unit: 'ms',
                      value: controller.animationDelay?.toDouble(),
                      automaticValue: 250,
                      automaticNote: 'automat',
                      onChanged:
                          (value) => setState(
                            () => controller.animationDelay = value.round(),
                          ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  AppTextField(
                    controller: controller.routeKmController,
                    label: 'Lungime traseu (km)',
                    hint: 'Ex. 4,5',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => double.tryParse((v ?? '').trim().replaceAll(',', '.')) == null ? 'Introdu lungimea în km' : null,
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: controller.durationController,
                    label: 'Durata (minute)',
                    hint: 'Ex. 120',
                    keyboardType: TextInputType.number,
                    validator: (v) => int.tryParse((v ?? '').trim()) == null ? 'Introdu durata în minute' : null,
                  ),
                  const SizedBox(height: 20),
                  AppDropdown<Difficulty>(
                    label: 'Dificultate',
                    items: [
                      for (final d in Difficulty.values) AppDropdownItem<Difficulty>(value: d, label: difficultyLabel(d)),
                    ],
                    value: controller.difficulty,
                    validator: (v) => v == null ? 'Alege dificultatea' : null,
                    onChanged: (value) => setState(() => controller.difficulty = value),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: controller.teamSizeMinController,
                          label: 'Membri pe echipă, minim',
                          hint: '2',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppTextField(
                          controller: controller.teamSizeMaxController,
                          label: 'maxim',
                          hint: '6',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: controller.maxTeamsController,
                    label: 'Număr maxim de echipe',
                    hint: 'Gol = fără limită',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: controller.whatToBringController,
                    label: 'Ce să aducă',
                    hint: 'Câte unul pe rând',
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: controller.organiserController,
                    label: 'Organizator',
                    hint: 'Gol = TeamXperience',
                  ),
                  const SizedBox(height: 28),
                  GameStartSection(
                    letter: controller.introLetterController,
                    signature: controller.introSignatureController,
                    hintsPerMission: controller.hintsPerMissionController,
                    enterWindow: controller.enterWindowController,
                    finishTitle: controller.finishTitleController,
                    finishMessage: controller.finishMessageController,
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    label:
                        mode == 'edit'
                            ? 'Actualizează eveniment'
                            : 'Continuă la misiuni',
                    onPressed: () => controller.createEvent(context, mode),
                  ),
                  if (mode != 'edit') ...[
                    const SizedBox(height: 10),
                    AppButton(
                      label: 'Salvează ca ciornă',
                      variant: AppButtonVariant.secondary,
                      foregroundColor: context.colors.text,
                      onPressed: () => controller.saveDraft(context, mode),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
