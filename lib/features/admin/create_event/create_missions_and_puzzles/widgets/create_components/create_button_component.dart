import 'package:flutter/material.dart';

class ButtonComponentFieldsWidget extends StatelessWidget {
  final TextEditingController buttonLabelController;
  final ValueChanged<String?> onButtonLabelChanged;

  const ButtonComponentFieldsWidget({
    super.key,
    required this.buttonLabelController,
    required this.onButtonLabelChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        TextField(
          controller: buttonLabelController,
          decoration: const InputDecoration(labelText: 'Button Label'),
          onChanged: onButtonLabelChanged,
        ),
      ],
    );
  }
}