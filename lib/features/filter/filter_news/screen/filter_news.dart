import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/constants/padding.dart';
import 'package:teamxperience/widgets/my_appbar.dart';
import 'package:teamxperience/widgets/my_button.dart';
import 'package:teamxperience/widgets/my_text_field.dart';
import 'package:teamxperience/widgets/my_dropdown/my_dropdown.dart';
import '../../../../model/newsCategory.dart';
import '../../../../constants/routes.dart';
import '../../../../enums/stire_type.dart';
import '../../../../utils/calendar_helper.dart';
import '../../../../widgets/my_dropdown/dropdown_item.dart';
import '../controller/filter_news_controller.dart';

class FilterStiriScreen extends StatefulWidget {
  const FilterStiriScreen({super.key});

  @override
  State<FilterStiriScreen> createState() => _FilterStiriScreenState();
}

class _FilterStiriScreenState extends State<FilterStiriScreen> {
  late FilterStiriController controller;
  final CalendarHelper calendarHelper = CalendarHelper();

  @override
  void initState() {
    super.initState();
    controller = FilterStiriController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final selectedDate = await calendarHelper.selectDate(context);
    if (selectedDate != null) {
      controller.setStartDate(selectedDate);
    }
  }

  Future<void> _selectEndDate() async {
    final selectedDate = await calendarHelper.selectDate(context);
    if (selectedDate != null) {
      controller.setEndDate(selectedDate);
    }
  }

  Future<void> _selectCategory() async {
    final selectedCategory = await Navigator.pushNamed(
      context,
      Routes.chooseNewsType,
      arguments: controller.selectedCategory,
    ) as NewsCategory?;

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

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const MyAppBar(appBarText: "Filtrare Știri"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MyPaddings.appHorizontalPadding,
          ),
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
                    items: StireType.values
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
                    hint: const Text(
                      "Selectează tipul știrii",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        color: MyColors.greyText,
                      ),
                    ),
                    borderColor: MyColors.lightBlue,
                    borderWidth: 1.5,
                    radius: 15,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category Selection
                  const Text(
                    'Categorie',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: MyColors.blackColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 10),
                  MyTextField(
                    controller: TextEditingController(
                        text: controller.selectedCategory?.name ?? ''
                    ),
                    hintText: "Selectează categoria",
                    readOnly: true,
                    onTap: _selectCategory,
                    radius: 15,
                    borderColor: MyColors.lightBlue,
                    borderWidth: 1.5,
                  ),
                  const SizedBox(height: 20),

                  // Start Date
                  const Text(
                    'Data de început',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: MyColors.blackColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 10),
                  MyTextField(
                    controller: TextEditingController(
                        text: _formatDateTime(controller.startDate)
                    ),
                    hintText: "Data de început",
                    readOnly: true,
                    onTap: _selectStartDate,
                    trailing: SvgPicture.asset(
                      'assets/images/calendar.svg',
                      height: 24,
                      width: 24,
                      colorFilter: const ColorFilter.mode(
                        MyColors.lightBlue,
                        BlendMode.srcIn,
                      ),
                    ),
                    radius: 15,
                    borderColor: MyColors.lightBlue,
                    borderWidth: 1.5,
                  ),
                  const SizedBox(height: 20),

                  // End Date
                  const Text(
                    'Data de sfârșit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: MyColors.blackColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 10),
                  MyTextField(
                    controller: TextEditingController(
                        text: _formatDateTime(controller.endDate)
                    ),
                    hintText: "Data de sfârșit",
                    readOnly: true,
                    onTap: _selectEndDate,
                    trailing: SvgPicture.asset(
                      'assets/images/calendar.svg',
                      height: 24,
                      width: 24,
                      colorFilter: const ColorFilter.mode(
                        MyColors.lightBlue,
                        BlendMode.srcIn,
                      ),
                    ),
                    radius: 15,
                    borderColor: MyColors.lightBlue,
                    borderWidth: 1.5,
                  ),

                  const Spacer(),

                  // Action Buttons
                  MyButton(
                    buttonText: "Aplică filtrele",
                    textColor: Colors.white,
                    buttonOnTap: _applyFilters,
                    withBorder: false,
                    gradient: MyColors.myGradient,
                    buttonTextSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
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