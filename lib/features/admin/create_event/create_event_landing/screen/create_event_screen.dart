import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/misc/app_svg_icon.dart';
import 'package:teamxperience/ui/components/inputs/color_swatch_row.dart';
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

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

/// Colours offered for the look of the game. The first row is for backgrounds,
/// the second for buttons, links and highlights.
const _backgroundSwatches = [
  '#050805',
  '#0B0A24',
  '#2B0F12',
  '#E8D5A8',
  '#FFFFFF',
];
const _accentSwatches = ['#33FF66', '#3FD0FF', '#FFE94A', '#FF3EA5', '#2AA5A9'];

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

                  // Aspectul jocului: what new components start with.
                  ColorSwatchRow(
                    label: 'Culoare de fundal',
                    swatches: _backgroundSwatches,
                    selected: controller.backgroundColor,
                    onChanged:
                        (hex) =>
                            setState(() => controller.backgroundColor = hex),
                  ),
                  const SizedBox(height: 16),
                  ColorSwatchRow(
                    label: 'Culoare accent',
                    swatches: _accentSwatches,
                    selected: controller.accentColor,
                    onChanged:
                        (hex) => setState(() => controller.accentColor = hex),
                  ),
                  const SizedBox(height: 16),
                  AppDropdown<String>(
                    label: 'Font',
                    hint: 'Implicit',
                    items: const [
                      AppDropdownItem<String>(
                        value: 'Poppins',
                        label: 'Poppins',
                      ),
                      AppDropdownItem<String>(
                        value: 'Monospace',
                        label: 'Monospace',
                      ),
                    ],
                    value: controller.fontFamily,
                    onChanged:
                        (value) =>
                            setState(() => controller.fontFamily = value),
                  ),
                  const SizedBox(height: 20),

                  // Lungime traseu
                  AppTextField(
                    controller: controller.lungimeController,
                    label: 'Lungime traseu',
                    hint: 'Lungimea traseului',
                    validator:
                        (v) =>
                            (v ?? '').trim().isEmpty
                                ? 'Introdu lungime traseu'
                                : null,
                  ),
                  const SizedBox(height: 20),

                  // Durata
                  AppTextField(
                    controller: controller.durataController,
                    label: 'Durata',
                    hint: 'Durata evenimentului',
                    validator:
                        (v) =>
                            (v ?? '').trim().isEmpty ? 'Introdu durata' : null,
                  ),
                  const SizedBox(height: 20),

                  // Dificultate
                  AppTextField(
                    controller: controller.dificultateController,
                    label: 'Dificultate',
                    hint: 'Dificultatea evenimentului',
                    validator:
                        (v) =>
                            (v ?? '').trim().isEmpty
                                ? 'Introdu dificultate'
                                : null,
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
