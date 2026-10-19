import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/features/admin/create_event/common_widgets/upload_image.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/widgets/my_appbar.dart';
import 'package:teamxperience/ui/components/buttons/my_button.dart';
import '../../../../../constants/padding.dart';
import '../../../../../enums/event_type.dart';
import 'package:teamxperience/ui/components/inputs/my_dropdown/dropdown_item.dart';
import 'package:teamxperience/ui/components/inputs/my_dropdown/my_dropdown.dart';
import 'package:teamxperience/ui/components/inputs/my_text_field.dart';
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
      backgroundColor: MyColors.backgroundColor,
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
            padding: const EdgeInsets.symmetric(
              horizontal: MyPaddings.appHorizontalPadding,
            ),
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      print("UploadImage tapped for landing image!");
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
                  MyTextField(
                    controller: controller.nameController,
                    labelText: 'Nume',
                    hintText: 'Numele evenimentului',
                    radius: 20,
                    borderWidth: 1.5,
                    borderColor: MyColors.lightBlue,
                    validator:
                        (v) => v!.isEmpty ? 'Introdu nume eveniment' : null,
                  ),
                  const SizedBox(height: 20),

                  // Locatie
                  MyTextField(
                    controller: controller.locationController,
                    labelText: 'Locație',
                    hintText: 'Locația evenimentului',
                    radius: 20,
                    borderWidth: 1.5,
                    borderColor: MyColors.lightBlue,
                    validator:
                        (v) => v!.isEmpty ? 'Introdu locație eveniment' : null,
                  ),
                  const SizedBox(height: 20),

                  MyTextField(
                    controller: controller.punctDeStartController,
                    labelText: 'Punct de start',
                    hintText: 'Punctul de start al evenimentului',
                    radius: 20,
                    borderWidth: 1.5,
                    borderColor: MyColors.lightBlue,
                    validator:
                        (v) => v!.isEmpty ? 'Introdu Punctul de start' : null,
                  ),
                  const SizedBox(height: 20),

                  // Descriere
                  MyTextField(
                    controller: controller.descriptionController,
                    labelText: 'Descriere',
                    hintText: 'Descrierea evenimentului',
                    radius: 20,
                    borderWidth: 1.5,
                    borderColor: MyColors.lightBlue,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    validator:
                        (v) =>
                            v!.isEmpty ? 'Introdu descriere eveniment' : null,
                  ),
                  const SizedBox(height: 20),

                  // Data și ora evenimentului
                  MyTextField(
                    controller: controller.dateEventController,
                    labelText: 'Data și ora evenimentului',
                    hintText: 'Selectează data și ora',
                    radius: 20,
                    borderWidth: 1.5,
                    borderColor: MyColors.lightBlue,
                    readOnly: true,
                    trailing: SvgPicture.asset(
                      'assets/images/calendar.svg',
                      height: 24,
                      width: 24,
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
                  MyTextField(
                    controller: controller.dateStartRegistrationController,
                    labelText: 'Când se deschid înscrierile?',
                    hintText: 'Selectează data și ora',
                    radius: 20,
                    borderWidth: 1.5,
                    borderColor: MyColors.lightBlue,
                    readOnly: true,
                    trailing: SvgPicture.asset(
                      'assets/images/calendar.svg',
                      height: 24,
                      width: 24,
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
                  MyTextField(
                    controller: controller.dateDeadlineRegistrationController,
                    labelText: 'Când se inchid înscrierile?',
                    hintText: 'Selectează data și ora',
                    radius: 20,
                    borderWidth: 1.5,
                    borderColor: MyColors.lightBlue,
                    readOnly: true,
                    trailing: SvgPicture.asset(
                      'assets/images/calendar.svg',
                      height: 24,
                      width: 24,
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
                  MyDropdownField<EventType>(
                    labelText: 'Tipul de eveniment',
                    items:
                        EventType.values
                            .map(
                              (type) => DropdownItem<EventType>(
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
                    hint: const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        "Selectează tipul de eveniment",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          color: MyColors.greyText,
                        ),
                      ),
                    ),
                    validator:
                        (value) =>
                            value == null
                                ? 'Selectează tipul de eveniment'
                                : null,
                    borderColor: MyColors.lightBlue,
                    borderWidth: 1.5,
                    radius: 20,
                  ),
                  const SizedBox(height: 20),

                  // Cod start
                  MyTextField(
                    controller: controller.startCodeController,
                    labelText: 'Cod start',
                    hintText: 'Introdu codul de start al evenimentului',
                    radius: 20,
                    borderWidth: 1.5,
                    borderColor: MyColors.lightBlue,
                    validator: (v) => v!.isEmpty ? 'Introdu cod start' : null,
                  ),

                  const SizedBox(height: 20),
                  // imagine fundal
                  GestureDetector(
                    onTap: () async {
                      print("UploadImage tapped for task background image!");
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
                  MyTextField(
                    controller: controller.lungimeController,
                    labelText: 'Lungime traseu',
                    hintText: 'Lungimea traseului',
                    radius: 20,
                    borderWidth: 1.5,
                    borderColor: MyColors.lightBlue,
                    validator:
                        (v) => v!.isEmpty ? 'Introdu lungime traseu' : null,
                  ),
                  const SizedBox(height: 20),

                  // Durata
                  MyTextField(
                    controller: controller.durataController,
                    labelText: 'Durata',
                    hintText: 'Durata evenimentului',
                    radius: 20,
                    borderWidth: 1.5,
                    borderColor: MyColors.lightBlue,
                    validator: (v) => v!.isEmpty ? 'Introdu durata' : null,
                  ),
                  const SizedBox(height: 20),

                  // Dificultate
                  MyTextField(
                    controller: controller.dificultateController,
                    labelText: 'Dificultate',
                    hintText: 'Dificultatea evenimentului',
                    radius: 20,
                    borderWidth: 1.5,
                    borderColor: MyColors.lightBlue,
                    validator: (v) => v!.isEmpty ? 'Introdu dificultate' : null,
                  ),

                  const SizedBox(height: 20),
                  MyButton(
                    buttonText:
                        mode == 'edit'
                            ? 'Actualizează eveniment'
                            : 'Creează eveniment',
                    textColor: Colors.white,
                    buttonOnTap: () => controller.createEvent(context, mode),
                    withBorder: false,
                    gradient: MyColors.myGradient,
                    fontWeight: FontWeight.w600,
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
