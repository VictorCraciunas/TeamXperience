import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/misc/app_svg_icon.dart';
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

      if (event == null) {
        mode = 'create';
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
                : mode == 'blueprint'
                ? 'Crează din Șablon'
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
                      labelText: 'Adaugă imagine eveniment',
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
                        (v) => v!.isEmpty ? 'Introdu nume eveniment' : null,
                  ),
                  const SizedBox(height: 20),

                  // Locatie
                  AppTextField(
                    controller: controller.locationController,
                    label: 'Locație',
                    hint: 'Locația evenimentului',
                    validator:
                        (v) => v!.isEmpty ? 'Introdu locație eveniment' : null,
                  ),
                  const SizedBox(height: 20),

                  AppTextField(
                    controller: controller.punctDeStartController,
                    label: 'Punct de start',
                    hint: 'Punctul de start al evenimentului',
                    validator:
                        (v) => v!.isEmpty ? 'Introdu Punctul de start' : null,
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
                            v!.isEmpty ? 'Introdu descriere eveniment' : null,
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
                    validator: (v) => v!.isEmpty ? 'Introdu cod start' : null,
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
                      labelText: 'Adaugă imagine fundal misiuni',
                      imageUrl: controller.getTaskBackgroundImageToDisplay(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Lungime traseu
                  AppTextField(
                    controller: controller.lungimeController,
                    label: 'Lungime traseu',
                    hint: 'Lungimea traseului',
                    validator:
                        (v) => v!.isEmpty ? 'Introdu lungime traseu' : null,
                  ),
                  const SizedBox(height: 20),

                  // Durata
                  AppTextField(
                    controller: controller.durataController,
                    label: 'Durata',
                    hint: 'Durata evenimentului',
                    validator: (v) => v!.isEmpty ? 'Introdu durata' : null,
                  ),
                  const SizedBox(height: 20),

                  // Dificultate
                  AppTextField(
                    controller: controller.dificultateController,
                    label: 'Dificultate',
                    hint: 'Dificultatea evenimentului',
                    validator: (v) => v!.isEmpty ? 'Introdu dificultate' : null,
                  ),

                  const SizedBox(height: 20),
                  AppButton(
                    label:
                        mode == 'edit'
                            ? 'Actualizează eveniment'
                            : 'Creează eveniment',
                    onPressed: () => controller.createEvent(context, mode),
                  ),
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
