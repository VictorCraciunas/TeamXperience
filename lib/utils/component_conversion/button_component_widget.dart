import 'package:flutter/material.dart';

class ButtonComponentWidget extends StatelessWidget {
  final String? buttonLabel;

  const ButtonComponentWidget({
    super.key,
    this.buttonLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {}, // Placeholder for future action
      child: Text(buttonLabel ?? 'Button'),
    );
  }
}