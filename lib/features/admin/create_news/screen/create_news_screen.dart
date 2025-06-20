import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/features/admin/create_event/common_widgets/upload_image.dart';
import 'package:teamxperience/widgets/my_appbar.dart';
import 'package:teamxperience/widgets/my_button.dart';
import 'package:teamxperience/enums/stire_type.dart';
import 'package:teamxperience/enums/stire_category.dart';
import '../../../../../constants/padding.dart';
import '../../../../../widgets/my_text_field.dart';
import '../../../../../widgets/my_dropdown/dropdown_item.dart';
import '../../../../../widgets/my_dropdown/my_dropdown.dart';
import '../controller/create_news_controller.dart';

class CreateStireScreen extends StatefulWidget {
  const CreateStireScreen({super.key});

  @override
  State<CreateStireScreen> createState() => _CreateStireScreenState();
}

class _CreateStireScreenState extends State<CreateStireScreen> {
  late CreateStireController controller;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      controller = CreateStireController();
      _initialized = true;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: const MyAppBar(appBarText: 'Adaugă știre'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MyPaddings.appHorizontalPadding,
          ),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),

                // Main Image Upload
                GestureDetector(
                  onTap: () async {
                    print("UploadImage tapped for main image!");
                    final pickedFile = await controller.pickImage();
                    if (pickedFile == null) {
                      return;
                    }
                    setState(() {
                      controller.mainImageFile = pickedFile;
                    });
                  },
                  child: UploadImage(
                    labelText: 'Adaugă imagine principală',
                    imageUrl: controller.getMainImageToDisplay(),
                  ),
                ),
                const SizedBox(height: 20),

                // Secondary Images Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Imagini secundare',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: MyColors.blackColor,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Display existing secondary images
                    if (controller.secondaryImageFiles.isNotEmpty) ...[
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: controller.secondaryImageFiles.asMap().entries.map((entry) {
                          int index = entry.key;
                          var imageFile = entry.value;

                          return Stack(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: MyColors.lightBlue,
                                    width: 1.5,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    imageFile,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              // Remove button
                              Positioned(
                                top: -5,
                                right: -5,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      controller.removeSecondaryImage(index);
                                    });
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Add new secondary image button
                    GestureDetector(
                      onTap: () async {
                        print("Adding secondary image!");
                        final pickedFile = await controller.pickImage();
                        if (pickedFile == null) {
                          return;
                        }
                        setState(() {
                          controller.addSecondaryImage(pickedFile);
                        });
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: MyColors.lightBlue,
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.grey,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Title
                MyTextField(
                  controller: controller.titleController,
                  labelText: 'Titlu știre',
                  hintText: 'Titlul știrii',
                  radius: 20,
                  borderWidth: 1.5,
                  borderColor: MyColors.lightBlue,
                  validator: (v) => v!.isEmpty ? 'Introdu titlul știrii' : null,
                ),
                const SizedBox(height: 20),

                // Description
                MyTextField(
                  controller: controller.descriptionController,
                  labelText: 'Descriere',
                  hintText: 'Descrierea știrii',
                  radius: 20,
                  borderWidth: 1.5,
                  borderColor: MyColors.lightBlue,
                  maxLines: null,
                  validator: (v) => v!.isEmpty ? 'Introdu descrierea știrii' : null,
                ),
                const SizedBox(height: 20),

                // Publication Date
                MyTextField(
                  controller: controller.dateController,
                  labelText: 'Data publicării',
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
                        controller.publicationDate = picked;
                        controller.dateController.text =
                        '${picked.day}/${picked.month}/${picked.year} ${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                      });
                    }
                  },
                  validator: (v) => (v ?? '').isEmpty ? 'Selectează data publicării' : null,
                ),
                const SizedBox(height: 20),

                // News Type Dropdown
                MyDropdownField<StireType>(
                  labelText: 'Tip de știre',
                  items: StireType.values
                      .map(
                        (type) => DropdownItem<StireType>(
                      value: type,
                      label: type.displayName,
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
                      "Selectează tipul de știre",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        color: MyColors.greyText,
                      ),
                    ),
                  ),
                  validator: (value) => value == null ? 'Selectează tipul de știre' : null,
                  borderColor: MyColors.lightBlue,
                  borderWidth: 1.5,
                  radius: 20,
                ),
                const SizedBox(height: 20),

                // Category Dropdown
                MyDropdownField<StireCategory>(
                  labelText: 'Categorie',
                  items: StireCategory.values
                      .map(
                        (category) => DropdownItem<StireCategory>(
                      value: category,
                      label: category.displayName,
                    ),
                  )
                      .toList(),
                  value: controller.selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      controller.selectedCategory = value;
                    });
                  },
                  hint: const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      "Selectează categoria",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        color: MyColors.greyText,
                      ),
                    ),
                  ),
                  validator: (value) => value == null ? 'Selectează categoria' : null,
                  borderColor: MyColors.lightBlue,
                  borderWidth: 1.5,
                  radius: 20,
                ),
                const SizedBox(height: 20),

                // Button Text
                MyTextField(
                  controller: controller.textButtonController,
                  labelText: 'Buton',
                  hintText: 'Text buton',
                  radius: 20,
                  borderWidth: 1.5,
                  borderColor: MyColors.lightBlue,
                  validator: (v) => v!.isEmpty ? 'Introdu textul butonului' : null,
                ),
                const SizedBox(height: 20),

                // Button Link
                MyTextField(
                  controller: controller.linkButtonController,
                  labelText: 'Link',
                  hintText: 'Link buton',
                  radius: 20,
                  borderWidth: 1.5,
                  borderColor: MyColors.lightBlue,
                  validator: (v) => v!.isEmpty ? 'Introdu link-ul butonului' : null,
                ),
                const SizedBox(height: 30),

                // Publish Button
                MyButton(
                  buttonText: 'Publică știre',
                  textColor: Colors.white,
                  buttonOnTap: () => controller.createStire(context),
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