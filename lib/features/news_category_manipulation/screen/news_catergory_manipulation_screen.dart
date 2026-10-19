import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teamxperience/constants/padding.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';
import 'package:teamxperience/ui/components/inputs/my_text_field.dart';
import 'package:teamxperience/ui/components/buttons/my_button.dart';
import '../../../model/newsCategory.dart';
import '../controller/news_category_controller.dart';

class NewsCategoryManipulationScreen extends StatefulWidget {
  final NewsCategory? initialSelectedCategory;

  const NewsCategoryManipulationScreen({
    super.key,
    this.initialSelectedCategory,
  });

  @override
  State<NewsCategoryManipulationScreen> createState() =>
      _NewsCategoryManipulationScreenState();
}

class _NewsCategoryManipulationScreenState
    extends State<NewsCategoryManipulationScreen> {
  late NewsCategoryController controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = NewsCategoryController();
    _loadData();
  }

  Future<void> _loadData() async {
    await controller.loadCategories();

    // Set initial selected category if provided
    if (widget.initialSelectedCategory != null) {
      controller.selectCategory(widget.initialSelectedCategory!);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const MyAppBar(appBarText: "Categorii"),
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: MyPaddings.appHorizontalPadding,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Search Field
                      MyTextField(
                        controller: controller.searchController,
                        hintText: "Caută categorie ...",
                        trailing: SvgPicture.asset(
                          'assets/images/search.svg',
                          height: 24,
                          width: 24,
                          colorFilter: ColorFilter.mode(
                            context.colors.accent,
                            BlendMode.srcIn,
                          ),
                        ),
                        radius: 15,
                        borderColor: context.colors.accent,
                        borderWidth: 1.5,
                        onChanged: (value) {
                          controller.filterCategories(value);
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 20),

                      // Categories List
                      Expanded(
                        child:
                            controller.filteredCategories.isEmpty
                                ? Center(
                                  child: Text(
                                    'Nu există categorii',
                                    style: TextStyle(
                                      color: context.colors.muted,
                                    ),
                                  ),
                                )
                                : ListView.separated(
                                  itemCount:
                                      controller.filteredCategories.length,
                                  separatorBuilder:
                                      (context, index) => Divider(
                                        color: context.colors.accent,
                                        thickness: 1,
                                        height: 1,
                                      ),
                                  itemBuilder: (context, index) {
                                    final category =
                                        controller.filteredCategories[index];
                                    final isSelected = controller
                                        .isCategorySelected(category);

                                    return ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 5,
                                          ),
                                      leading: Transform.scale(
                                        scale: 1.3,
                                        child: Checkbox(
                                          value: isSelected,
                                          onChanged: (value) {
                                            setState(() {
                                              if (value == true) {
                                                controller.selectCategory(
                                                  category,
                                                );
                                              } else {
                                                controller.selectCategory(
                                                  NewsCategory(name: ''),
                                                ); // Deselect
                                              }
                                            });
                                          },
                                          activeColor: context.colors.accent,
                                          checkColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          side: BorderSide(
                                            width: 1.5,
                                            color: context.colors.accent,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        category.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color:
                                              isSelected
                                                  ? context.colors.accent
                                                  : Colors.black,
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          if (isSelected) {
                                            controller.selectCategory(
                                              NewsCategory(name: ''),
                                            ); // Deselect
                                          } else {
                                            controller.selectCategory(category);
                                          }
                                        });
                                      },
                                    );
                                  },
                                ),
                      ),
                      MyTextField(
                        controller: controller.newCategoryController,
                        labelText: 'Adaugă categorie',
                        hintText: 'Categorie noua',
                        borderColor: context.colors.accent,
                        radius: 15,
                        borderWidth: 1.5,
                        trailing: Icon(
                          Icons.add,
                          color: context.colors.accent,
                          size: 24,
                        ),
                        onTap: () async {
                          if (controller.newCategoryController.text
                              .trim()
                              .isNotEmpty) {
                            await controller.addNewCategory(
                              controller.newCategoryController.text,
                            );
                            controller.newCategoryController.clear();
                            controller.filterCategories(
                              controller.searchController.text,
                            );
                            setState(() {});
                          }
                        },
                      ),
                      SizedBox(height: 30),
                      MyButton(
                        buttonText: "Selecteaza categorie",
                        textColor: Colors.white,
                        buttonOnTap: (){
                          Navigator.of(context).pop(controller.selectedCategory);
                        },
                        withBorder: false,
                        gradient: context.colors.ctaGradient,
                        buttonTextSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
      ),
    );
  }
}
