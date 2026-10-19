import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/constants/padding.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/enums/event_type.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';
import 'package:teamxperience/ui/components/buttons/my_button.dart';
import 'package:teamxperience/ui/components/inputs/my_dropdown/my_dropdown.dart';
import 'package:teamxperience/ui/components/inputs/my_dropdown/dropdown_item.dart';
import 'package:teamxperience/ui/components/inputs/my_text_field.dart';
import '../controller/filter_events_controller.dart';

class FilterEventsScreen extends StatefulWidget {
  const FilterEventsScreen({super.key});

  @override
  State<FilterEventsScreen> createState() => _FilterEventsScreenState();
}

class _FilterEventsScreenState extends State<FilterEventsScreen> {
  late FilterController controller;
  late TextEditingController _periodController;


  @override
  void initState() {
    super.initState();
    controller = FilterController();
    _periodController = TextEditingController();
  }


  @override
  void dispose() {
    controller.dispose();
    _periodController.dispose();
    super.dispose();
  }

  late bool isAdmin;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isAdmin = ModalRoute.of(context)?.settings.arguments as bool;
  }

  void _updatePeriodText() {
    _periodController.text = controller.startDate != null && controller.endDate != null
        ? '${_formatDate(controller.startDate!)} - ${_formatDate(controller.endDate!)}'
        : '';
  }
  void _navigateToPeriodSelection() async {
    final result = await Navigator.pushNamed(
      context,
      Routes.calendar,
    ) as Map<String, DateTime?>?;

    if (result != null) {
      controller.setDateRange(
        result['startDate'],
        result['endDate'],
      );
      _updatePeriodText(); // Update the text field
    }
  }

  void _applyFilters() {
    // Pass filter data back to EventsDashboard
    Navigator.pop(context, controller.getFilterData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.page,
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
              if (isAdmin)
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
                    hint: Text(
                      "Selectează tipul de eveniment",
                      style: TextStyle(
                        fontSize: 14,
                        color: context.colors.muted,
                      ),
                    ),
                    borderColor: context.colors.accent,
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
              MyTextField(
                labelText: 'Perioada',
                hintText: 'Selectează perioadă',
                readOnly: true,
                onTap: _navigateToPeriodSelection,
                trailing: Icon(
                  Icons.chevron_right,
                  color: context.colors.accent,
                ),
                borderColor: context.colors.accent,
                borderWidth: 1.5,
                radius: 20,
                controller: _periodController,
              ),

              const Spacer(),

              // Apply Filters Button
              MyButton(
                buttonText: 'Salvează modificările',
                textColor: Colors.white,
                buttonOnTap: _applyFilters,
                withBorder: false,
                gradient: context.colors.ctaGradient,
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
      case EventType.PUBLIC:
        return 'Public';
      case EventType.PRIVAT:
        return 'Privat';
      }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}