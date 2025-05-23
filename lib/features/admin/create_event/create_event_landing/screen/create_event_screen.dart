import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/features/admin/create_event/common_widgets/upload_image.dart';
import 'package:teamxperience/widgets/my_appbar.dart';
import 'package:teamxperience/widgets/my_button.dart';
import '../../../../../constants/padding.dart';
import '../../../../../enums/event_type.dart';
import '../../../../../widgets/my_text_field.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: const MyAppBar(appBarText: 'Eveniment Nou'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: MyPaddings.appHorizontalPadding),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                const SizedBox(height: 30,),
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
                    labelText: 'Adauga imagine eveniment',
                    imageFile: controller.landingImageFile,
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
                  validator: (v) => v!.isEmpty ? 'Introdu nume eveniment' : null,
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

                // Descriere
                MyTextField(
                  controller: controller.descriptionController,
                  labelText: 'Descriere',
                  hintText: 'Descrierea evenimentului',
                  radius: 20,
                  borderWidth: 1.5,
                  borderColor: MyColors.lightBlue,
                  maxLines: null,
                  validator:
                      (v) => v!.isEmpty ? 'Introdu descriere eveniment' : null,
                ),
                const SizedBox(height: 20),

                // Numar misiuni
                MyTextField(
                  controller: controller.nrMissionsController,
                  labelText: 'Numărul de misiuni',
                  hintText: 'Introdu numărul de misiuni',
                  radius: 20,
                  borderWidth: 1.5,
                  borderColor: MyColors.lightBlue,
                  keyboardType: TextInputType.number,
                  validator:
                      (v) => v!.isEmpty ? 'Introdu numărul de misiuni' : null,
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
                        controller.dateStartEnrollemnt = picked;
                        controller
                            .dateStartRegistrationController
                            .text = DateFormat('yyyy-MM-dd HH:mm').format(picked);
                      });
                    }
                  },
                  validator:
                      (v) => (v ?? '').isEmpty ? 'Introdu dată deschidere' : null,
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
                        controller
                            .dateDeadlineRegistrationController
                            .text = DateFormat('yyyy-MM-dd HH:mm').format(picked);
                      });
                    }
                  },
                  validator:
                      (v) => (v ?? '').isEmpty ? 'Introdu dată inchidere' : null,
                ),
                const SizedBox(height: 20),

                // Tip de eveniment
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label styled like MyTextField
                    const Text(
                      'Tip de eveniment',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<EventType>(
                      hint: const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          "Selecteaza tipul de eveniment",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            color: MyColors.greyText,
                          ),
                        ),
                      ),
                      value: controller.selectedType,
                      items:
                          EventType.values
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(
                                    type.toString().split('.').last,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Poppins',
                                      color:
                                          Colors.black, // Adjust color as needed
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          controller.selectedType = value;
                        });
                      },
                      validator:
                          (value) =>
                              value == null
                                  ? 'Selecteaza tipul de eveniment'
                                  : null,
                      // Style for the selected item
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        color: Colors.black, // Adjust color as needed
                      ),
                      decoration: InputDecoration(
                        // Border styling to match MyTextField
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: MyColors.lightBlue,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: MyColors.lightBlue,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: MyColors.lightBlue,
                            width: 3,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                      ),
                    ),
                  ],
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
                    labelText: 'Adauga imagine fundal misiuni',
                    imageFile: controller.taskBackgroundImageFile,
                  ),
                ),

                const SizedBox(height: 20),
                MyButton(
                  buttonText: 'Creeza eveniment',
                  textColor: Colors.white,
                  buttonOnTap: () => controller.createEvent(context),
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
    );
  }
}
