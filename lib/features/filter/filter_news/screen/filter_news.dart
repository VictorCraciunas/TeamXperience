import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';
import 'package:teamxperience/ui/components/inputs/app_text_field.dart';
import 'package:teamxperience/ui/components/inputs/my_dropdown/my_dropdown.dart';
import '../../../../model/newsCategory.dart';
import '../../../../constants/routes.dart';
import '../../../../enums/stire_type.dart';
import '../../../../utils/calendar_helper.dart';
import 'package:teamxperience/ui/components/inputs/my_dropdown/dropdown_item.dart';
import '../controller/filter_news_controller.dart';

class FilterStiriScreen extends StatefulWidget {
  const FilterStiriScreen({super.key});

  @override
  State<FilterStiriScreen> createState() => _FilterStiriScreenState();
}

class _FilterStiriScreenState extends State<FilterStiriScreen> {
  late FilterStiriController controller;
  final CalendarHelper calendarHelper = CalendarHelper();
  late TextEditingController _periodController;

  @override
  void initState() {
    super.initState();
    controller = FilterStiriController();
    _periodController = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
    _periodController.dispose();
  }

  Future<void> _selectCategory() async {
    final selectedCategory =
        await Navigator.pushNamed(
              context,
              Routes.chooseNewsType,
              arguments: controller.selectedCategory,
            )
            as NewsCategory?;

    if (selectedCategory != null) {
      controller.setCategory(selectedCategory);
    }
  }

  void _applyFilters() {
    Navigator.of(context).pop(controller.getFilterData());
  }

  void _clearFilters() {
    controller.clearFilters();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  void _updatePeriodText() {
    _periodController.text =
        controller.startDate != null && controller.endDate != null
            ? '${_formatDate(controller.startDate!)} - ${_formatDate(controller.endDate!)}'
            : '';
  }

  void _navigateToPeriodSelection() async {
    final result =
        await Navigator.pushNamed(context, Routes.calendar)
            as Map<String, DateTime?>?;

    if (result != null) {
      controller.setDateRange(result['startDate'], result['endDate']);
      _updatePeriodText(); // Update the text field
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.page,
      appBar: const MyAppBar(appBarText: "Filtrare Știri"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),

                  // Stire Type Dropdown
                  MyDropdownField<StireType>(
                    labelText: 'Tipul știrii',
                    items:
                        StireType.values
                            .map(
                              (type) => DropdownItem<StireType>(
                                value: type,
                                label: type.displayName,
                              ),
                            )
                            .toList(),
                    value: controller.selectedStireType,
                    onChanged: (value) {
                      controller.setStireType(value);
                    },
                    hint: Text(
                      "Selectează tipul știrii",
                      style: TextStyle(
                        fontSize: 14,
                        color: context.colors.muted,
                      ),
                    ),
                    borderColor: context.colors.accent,
                    borderWidth: 1.5,
                    radius: 15,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category Selection
                  Text(
                    'Categorie',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.colors.text,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppTextField(
                    controller: TextEditingController(
                      text: controller.selectedCategory?.name ?? '',
                    ),
                    hint: "Selectează categoria",
                    readOnly: true,
                    onTap: _selectCategory,
                    validator: requiredValidator('a value'),
                  ),
                  const SizedBox(height: 20),

                  // Start Date
                  AppTextField(
                    label: 'Perioada',
                    hint: 'Selectează perioadă',
                    readOnly: true,
                    onTap: _navigateToPeriodSelection,
                    trailing: Icon(
                      Icons.chevron_right,
                      color: context.colors.accent,
                    ),
                    controller: _periodController,
                    validator: requiredValidator('Perioada'),
                  ),

                  SizedBox(height: 10),

                  // Action Buttons
                  AppButton(label: "Aplică filtrele", onPressed: _applyFilters),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
