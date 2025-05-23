import 'package:flutter/material.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/model/component.dart';

import '../../../../../../utils/component_conversion/component_to_widget.dart';
import '../../controller/add_missions_controller.dart';

class CodeComponentFieldsWidget extends StatefulWidget {
  final AddMissionsController addMissionsController;
  final int missionSelected;
  final int puzzleSelected;
  final Function(Widget) refreshUI;

  const CodeComponentFieldsWidget({
    super.key,
    required this.addMissionsController,
    required this.missionSelected,
    required this.puzzleSelected,
    required this.refreshUI,
  });

  @override
  State<CodeComponentFieldsWidget> createState() => _CodeComponentFieldsWidgetState();
}

class _CodeComponentFieldsWidgetState extends State<CodeComponentFieldsWidget> {
  int? _codeLength;
  Component? component;
  ComponentToWidget componentToWidget = ComponentToWidget();

  void _saveComponent() {
    if (_codeLength == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select the number of letters')),
      );
      return;
    }

    Component component = widget.addMissionsController.addComponent(
      widget.missionSelected,
      widget.puzzleSelected,
      ComponentType.code,
      codeLength: _codeLength,
    );
    Widget componentWidget = componentToWidget.convert(component);
    widget.refreshUI(componentWidget);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        DropdownButtonFormField<int>(
          decoration: const InputDecoration(labelText: 'Number of Letters'),
          value: _codeLength,
          items: List.generate(10, (index) => index + 1)
              .map((length) => DropdownMenuItem(
            value: length,
            child: Text('$length'),
          ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _codeLength = value;
              component = Component(type: ComponentType.code, codeLength: value);
            });
          },
          validator: (value) => value == null ? 'Please select the number of letters' : null,
        ),
        if (_codeLength != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0x00f5e8c7), // Parchment-like background
              border: Border.all(color: Colors.black, width: 2),
            ),
            // ------- preview --------
            child: component != null ? componentToWidget.convert(component!) : null,
          ),
        ],
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _saveComponent,
          child: const Text('Save Component'),
        ),
      ],
    );
  }
}