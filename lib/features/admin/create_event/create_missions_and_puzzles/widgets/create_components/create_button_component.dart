import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ButtonComponentFieldsWidget extends StatelessWidget {
  final TextEditingController buttonLabelController;
  final ValueChanged<String?> onButtonLabelChanged;
  final String? buttonColor; // Initial button background color
  final String? buttonColorOnTap; // Button background color on tap
  final String? buttonTextColor; // Initial button text color
  final String? buttonTextColorOnTap; // Button text color on tap
  final String? borderColor; // New: Border color
  final ValueChanged<String?> onButtonColorChanged;
  final ValueChanged<String?> onButtonColorOnTapChanged;
  final ValueChanged<String?> onButtonTextColorChanged;
  final ValueChanged<String?> onButtonTextColorOnTapChanged;
  final ValueChanged<String?> onBorderColorChanged; // New: Callback for border color

  const ButtonComponentFieldsWidget({
    super.key,
    required this.buttonLabelController,
    required this.onButtonLabelChanged,
    this.buttonColor,
    this.buttonColorOnTap,
    this.buttonTextColor,
    this.buttonTextColorOnTap,
    this.borderColor,
    required this.onButtonColorChanged,
    required this.onButtonColorOnTapChanged,
    required this.onButtonTextColorChanged,
    required this.onButtonTextColorOnTapChanged,
    required this.onBorderColorChanged,
  });

  // Helper to convert hex string to Color
  Color _hexToColor(String? hex, {Color defaultColor = Colors.black}) {
    if (hex == null || hex.isEmpty) return defaultColor;
    final hexColor = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  // Helper to convert Color to hex string
  String _colorToHex(Color color) {
    final argb = color.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#${argb.substring(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final currentButtonColor = _hexToColor(buttonColor, defaultColor: Colors.white);
    final currentButtonColorOnTap = _hexToColor(buttonColorOnTap, defaultColor: Colors.grey);
    final currentTextColor = _hexToColor(buttonTextColor, defaultColor: Colors.black);
    final currentTextColorOnTap = _hexToColor(buttonTextColorOnTap, defaultColor: Colors.white);
    final currentBorderColor = _hexToColor(borderColor, defaultColor: Colors.black);

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // ───── Preview ─────
            const Text('Preview', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Initial state preview
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: currentButtonColor,
                      border: Border.all(color: currentBorderColor, width: 3.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      buttonLabelController.text.isEmpty ? 'Your button' : buttonLabelController.text,
                      style: TextStyle(
                        color: currentTextColor,
                        fontSize: 16.0,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('→', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 16),
                  // Tapped state preview
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: currentButtonColorOnTap,
                      border: Border.all(color: currentBorderColor, width: 3.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      buttonLabelController.text.isEmpty ? 'Your button' : buttonLabelController.text,
                      style: TextStyle(
                        color: currentTextColorOnTap,
                        fontSize: 16.0,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 32),

            // ───── Button Label ─────
            TextField(
              controller: buttonLabelController,
              decoration: const InputDecoration(labelText: 'Button Label'),
              onChanged: onButtonLabelChanged,
            ),
            const SizedBox(height: 10),

            // ───── Button Color Picker ─────
            ListTile(
              title: const Text('Button Color'),
              trailing: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: currentButtonColor,
                  border: Border.all(color: Colors.grey),
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    Color selectedColor = currentButtonColor;
                    return AlertDialog(
                      title: const Text('Pick a button color'),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: selectedColor,
                          onColorChanged: (color) => selectedColor = color,
                          labelTypes: const [],
                          pickerAreaHeightPercent: 0.8,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            onButtonColorChanged(_colorToHex(selectedColor));
                            Navigator.pop(context);
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 10),

            // ───── Button Color On Tap Picker ─────
            ListTile(
              title: const Text('Button Color (On Tap)'),
              trailing: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: currentButtonColorOnTap,
                  border: Border.all(color: Colors.grey),
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    Color selectedColor = currentButtonColorOnTap;
                    return AlertDialog(
                      title: const Text('Pick a button color (on tap)'),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: selectedColor,
                          onColorChanged: (color) => selectedColor = color,
                          labelTypes: const [],
                          pickerAreaHeightPercent: 0.8,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            onButtonColorOnTapChanged(_colorToHex(selectedColor));
                            Navigator.pop(context);
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 10),

            // ───── Text Color Picker ─────
            ListTile(
              title: const Text('Text Color'),
              trailing: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: currentTextColor,
                  border: Border.all(color: Colors.grey),
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    Color selectedColor = currentTextColor;
                    return AlertDialog(
                      title: const Text('Pick a text color'),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: selectedColor,
                          onColorChanged: (color) => selectedColor = color,
                          labelTypes: const [],
                          pickerAreaHeightPercent: 0.8,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            onButtonTextColorChanged(_colorToHex(selectedColor));
                            Navigator.pop(context);
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 10),

            // ───── Text Color On Tap Picker ─────
            ListTile(
              title: const Text('Text Color (On Tap)'),
              trailing: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: currentTextColorOnTap,
                  border: Border.all(color: Colors.grey),
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    Color selectedColor = currentTextColorOnTap;
                    return AlertDialog(
                      title: const Text('Pick a text color (on tap)'),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: selectedColor,
                          onColorChanged: (color) => selectedColor = color,
                          labelTypes: const [],
                          pickerAreaHeightPercent: 0.8,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            onButtonTextColorOnTapChanged(_colorToHex(selectedColor));
                            Navigator.pop(context);
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 10),

            // ───── Border Color Picker ─────
            ListTile(
              title: const Text('Border Color'),
              trailing: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: currentBorderColor,
                  border: Border.all(color: Colors.grey),
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    Color selectedColor = currentBorderColor;
                    return AlertDialog(
                      title: const Text('Pick a border color'),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: selectedColor,
                          onColorChanged: (color) => selectedColor = color,
                          labelTypes: const [],
                          pickerAreaHeightPercent: 0.8,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            onBorderColorChanged(_colorToHex(selectedColor));
                            Navigator.pop(context);
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}