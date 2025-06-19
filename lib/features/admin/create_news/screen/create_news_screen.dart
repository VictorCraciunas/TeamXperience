import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/features/admin/create_event/common_widgets/upload_image.dart';
import 'package:teamxperience/widgets/my_appbar.dart';
import 'package:teamxperience/widgets/my_button.dart';
import '../../../../../constants/padding.dart';
import '../../../../../widgets/my_dropdown.dart';
import '../../../../../widgets/my_text_field.dart';
import '../controller/create_news_controller.dart';

class CreateNewsScreen extends StatefulWidget {
  const CreateNewsScreen({super.key});

  @override
  State<CreateNewsScreen> createState() => _CreateNewsScreen();
}

class _CreateNewsScreen extends State<CreateNewsScreen> {
  late CreateNewsController controller;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      controller = CreateNewsController();
      _initialized = true;
    }
  }

  @override
  void dispose() {
    controller.titleController.dispose();
    controller.descriptionController.dispose();
    controller.dateController.dispose();
    controller.categoryController.dispose();
    controller.textButtonController.dispose();
    controller.linkButtonController.dispose();
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

                // Secondary Image Upload (smaller one shown in the design)
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        print("UploadImage tapped for secondary image!");
                        final pickedFile = await controller.pickImage();
                        if (pickedFile == null) {
                          return;
                        }
                        setState(() {
                          controller.secondaryImageFile = pickedFile;
                        });
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: MyColors.lightBlue,
                            width: 1.5,
                          ),
                        ),
                        child: controller.secondaryImageFile != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            controller.secondaryImageFile!,
                            fit: BoxFit.cover,
                          ),
                        )
                            : const Icon(
                          Icons.add,
                          color: Colors.grey,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
                const SizedBox(height: 20),

                // Title
                MyTextField(
                  controller: controller.titleController,
                  labelText: 'Titlu6',
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
                MyDropdownField<String>(
                  labelText: 'Tip de știre',
                  items: controller.newsTypes
                      .map(
                        (type) => DropdownMenuItem(
                      value: type,
                      child: Text(
                        type,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          color: Colors.black,
                        ),
                      ),
                    ),
                  )
                      .toList(),
                  value: controller.selectedNewsType,
                  onChanged: (value) {
                    setState(() {
                      controller.selectedNewsType = value;
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
                MyDropdownField<String>(
                  labelText: 'Categorie',
                  items: controller.categories
                      .map(
                        (category) => DropdownMenuItem(
                      value: category,
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          color: Colors.black,
                        ),
                      ),
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
                  labelText: '',
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
                  buttonOnTap: () => controller.publishNews(context),
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