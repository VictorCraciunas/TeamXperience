import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/misc/app_svg_icon.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/admin/create_event/common_widgets/upload_image.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';
import 'package:teamxperience/enums/stire_type.dart';
import 'package:teamxperience/ui/components/inputs/app_text_field.dart';
import 'package:teamxperience/ui/components/inputs/app_dropdown.dart';
import '../../../../model/newsCategory.dart';
import '../../../../model/stire.dart';
import '../controller/create_news_controller.dart';
import 'dart:io';

class CreateStireScreen extends StatefulWidget {
  const CreateStireScreen({super.key});

  @override
  State<CreateStireScreen> createState() => _CreateStireScreenState();
}

class _CreateStireScreenState extends State<CreateStireScreen> {
  late CreateStireController controller;
  bool _initialized = false;
  late String mode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      final Stire? stire = args?['stire'];

      if (stire == null) {
        mode = 'create';
      } else {
        mode = 'edit';
      }

      controller = CreateStireController(stire);
      _initialized = true;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _selectCategory() async {
    final selectedCategory =
        await Navigator.pushNamed(context, Routes.chooseNewsType)
            as NewsCategory?;

    if (selectedCategory != null && selectedCategory.name.isNotEmpty) {
      setState(() {
        // Assign the name to the text controller
        controller.categoryController.text = selectedCategory.name;

        // Store the entire NewsCategory object
        controller.selectedCategory = selectedCategory;
      });
    }
  }

  // Helper widget to display image (either from file or URL)
  Widget buildImageWidget(String imagePath, int index) {
    if (imagePath.startsWith('http')) {
      // It's a URL, use Image.network
      return GestureDetector(
        onLongPress: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: context.colors.panel,
                content: AppButton(
                  label: "Șterge",
                  onPressed: () {
                    setState(() {
                      controller.removeSecondaryImage(index);
                    });
                    Navigator.pop(context);
                  },
                ),
              );
            },
          );
        },
        child: CachedNetworkImage(
          imageUrl: imagePath,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          placeholder:
              (context, url) => Container(
                width: 60,
                height: 60,
                color: context.colors.inset,
                child: const CircularProgressIndicator(),
              ),
          errorWidget:
              (context, url, error) => Container(
                width: 60,
                height: 60,
                color: context.colors.inset,
                child: const Icon(Icons.error, color: Colors.red),
              ),
        ),
      );
    } else {
      // It's a local file path, use Image.file
      return Image.file(
        File(imagePath),
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 60,
            height: 60,
            color: context.colors.inset,
            child: const Icon(Icons.error, color: Colors.red),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.page,
      appBar: const MyAppBar(appBarText: 'Adaugă știre'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: Column(
              children: [
                Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      Row(
                        children: [
                          // Display existing secondary images
                          if (controller
                              .getSecondaryImagePaths()
                              .isNotEmpty) ...[
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children:
                                  controller
                                      .getSecondaryImagePaths()
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                        int index = entry.key;
                                        String imagePath = entry.value;

                                        return Stack(
                                          children: [
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: buildImageWidget(
                                                  imagePath,
                                                  index,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      })
                                      .toList(),
                            ),
                            const SizedBox(width: 10),
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
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: context.colors.iconButtonBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.add,
                                color: context.colors.text,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Title
                      AppTextField(
                        controller: controller.titleController,
                        label: 'Titlu știre',
                        hint: 'Titlul știrii',
                        validator:
                            (v) => v!.isEmpty ? 'Introdu titlul știrii' : null,
                      ),
                      const SizedBox(height: 20),

                      // Description
                      AppTextField(
                        controller: controller.descriptionController,
                        label: 'Descriere',
                        hint: 'Descrierea știrii',
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        validator:
                            (v) =>
                                v!.isEmpty ? 'Introdu descrierea știrii' : null,
                      ),
                      const SizedBox(height: 20),

                      // Publication Date
                      AppTextField(
                        controller: controller.dateController,
                        label: 'Data publicării',
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
                              controller.publicationDate = picked;
                              controller.dateController.text =
                                  '${picked.day}/${picked.month}/${picked.year} ${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                            });
                          }
                        },
                        validator:
                            (v) =>
                                (v ?? '').isEmpty
                                    ? 'Selectează data publicării'
                                    : null,
                      ),
                      const SizedBox(height: 20),

                      // News Type Dropdown
                      AppDropdown<StireType>(
                        label: 'Tip de știre',
                        items:
                            StireType.values
                                .map(
                                  (type) => AppDropdownItem<StireType>(
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
                        hint: "Selectează tipul de știre",
                        validator:
                            (value) =>
                                value == null
                                    ? 'Selectează tipul de știre'
                                    : null,
                      ),
                      const SizedBox(height: 20),

                      // Category Selection (now using NewsCategory instead of dropdown)
                      AppTextField(
                        controller: controller.categoryController,
                        label: 'Categorie',
                        hint: 'Selectează categoria',
                        readOnly: true,
                        onTap: () async {
                          _selectCategory();
                        },
                        validator:
                            (v) =>
                                (v ?? '').isEmpty
                                    ? 'Selectează categoria'
                                    : null,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                // Button Text
                AppTextField(
                  controller: controller.textButtonController,
                  label: 'Buton',
                  hint: 'Text buton',
                  validator: requiredValidator('Buton'),
                ),
                const SizedBox(height: 20),

                // Button Link
                AppTextField(
                  controller: controller.linkButtonController,
                  label: 'Link',
                  hint: 'Link buton',
                  validator: requiredValidator('Link'),
                ),
                const SizedBox(height: 30),

                // Publish Button
                AppButton(
                  label: 'Publică știre',
                  onPressed: () => controller.createStire(context, mode),
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
