import 'package:flutter/material.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/model/component.dart';

import '../../../../../../utils/component_conversion/component_to_widget.dart';

class CodeComponentFieldsWidget extends StatefulWidget {
  final ValueChanged<int?> onCodeLengthChanged; // Callback to notify parent of code length

  const CodeComponentFieldsWidget({
    super.key,
    required this.onCodeLengthChanged,
  });

  @override
  State<CodeComponentFieldsWidget> createState() => _CodeComponentFieldsWidgetState();
}

class _CodeComponentFieldsWidgetState extends State<CodeComponentFieldsWidget> {
  int? _codeLength;
  Component? component ;
  ComponentToWidget componentToWidget = ComponentToWidget();

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
              component = Component(type: ComponentType.code,codeLength: value);
            });
            widget.onCodeLengthChanged(value); // Notify parent
          },
          validator: (value) => value == null ? 'Please select the number of letters' : null,
        ),
        if (_codeLength != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5E8C7), // Parchment-like background
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: component != null
            ? componentToWidget.convert(component!)
            : null,
          ),
        ],
      ],
    );
  }
}