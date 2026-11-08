import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';
import 'package:teamxperience/ui/components/inputs/app_text_field.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';
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
      backgroundColor: context.colors.page,
      appBar: const MyAppBar(appBarText: "Categorii"),
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.page,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Search Field
                      AppTextField(
                        controller: controller.searchController,
                        hint: "Caută categorie ...",
                        trailing: SvgPicture.asset(
                          'assets/images/search.svg',
                          height: 24,
                          width: 24,
                          colorFilter: ColorFilter.mode(
                            context.colors.accent,
                            BlendMode.srcIn,
                          ),
                        ),
                        onChanged: (value) {
                          controller.filterCategories(value);
                          setState(() {});
                        },
                        validator: requiredValidator('a value'),
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
                                          checkColor: context.colors.onTick,
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
                                                  : context.colors.text,
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
                      AppTextField(
                        controller: controller.newCategoryController,
                        label: 'Adaugă categorie',
                        hint: 'Categorie noua',
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
                        validator: requiredValidator('Adaugă categorie'),
                      ),
                      SizedBox(height: 30),
                      AppButton(
                        label: "Selecteaza categorie",
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pop(controller.selectedCategory);
                        },
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
      ),
    );
  }
}
