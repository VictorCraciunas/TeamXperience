import 'package:flutter/material.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/constants/padding.dart';
import 'package:teamxperience/enums/event_type.dart';
import 'package:teamxperience/widgets/my_appbar.dart';
import 'package:teamxperience/widgets/my_button.dart';
import 'package:teamxperience/widgets/my_dropdown/my_dropdown.dart';
import '../../../widgets/my_dropdown/dropdown_item.dart';
import '../controller/filter_controller.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late FilterController controller;

  @override
  void initState() {
    super.initState();
    controller = FilterController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _navigateToPeriodSelection() {
    // TODO: Navigate to period selection screen
    // For now, just a placeholder navigation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigating to period selection...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _applyFilters() {
    // Pass filter data back to EventsDashboard
    Navigator.pop(context, controller.getFilterData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: const MyAppBar(appBarText: "Filtrare"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MyPaddings.appHorizontalPadding,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Type Dropdown
              AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  return MyDropdownField<EventType>(
                    labelText: 'Tip de eveniment',
                    items: EventType.values
                        .map(
                          (type) => DropdownItem<EventType>(
                        value: type,
                        label: _getEventTypeDisplayName(type),
                      ),
                    )
                        .toList(),
                    value: controller.selectedEventType,
                    onChanged: (value) {
                      controller.setEventType(value);
                    },
                    hint: const Text(
                      "Selectează tipul de eveniment",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        color: MyColors.greyText,
                      ),
                    ),
                    borderColor: MyColors.lightBlue,
                    borderWidth: 1.5,
                    radius: 20,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Period Selection Button
              const Text(
                'Perioada',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: MyColors.blackColor,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _navigateToPeriodSelection,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: MyColors.lightBlue,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AnimatedBuilder(
                        animation: controller,
                        builder: (context, _) {
                          return Text(
                            controller.startDate != null && controller.endDate != null
                                ? '${_formatDate(controller.startDate!)} - ${_formatDate(controller.endDate!)}'
                                : 'Selectează perioadă',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              color: controller.startDate != null
                                  ? MyColors.blackColor
                                  : MyColors.greyText,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: MyColors.blackColor,
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Apply Filters Button
              MyButton(
                buttonText: 'Salvează modificările',
                textColor: Colors.white,
                buttonOnTap: _applyFilters,
                withBorder: false,
                gradient: MyColors.myGradient,
                fontWeight: FontWeight.w600,
                radius: 30,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _getEventTypeDisplayName(EventType type) {
    // Convert enum to display name
    switch (type) {
      case EventType.public:
        return 'Public';
      case EventType.private:
        return 'Privat';
      }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}