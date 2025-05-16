import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:teamxperience/enums/animation_type.dart';

class TextComponentFieldsWidget extends StatelessWidget {
  final TextEditingController textController;
  final String? textColor;
  final AnimationType? animation;
  final double? fontSize;
  final String? fontWeight;
  final ValueChanged<String?> onTextChanged;
  final ValueChanged<String?> onTextColorChanged;
  final ValueChanged<AnimationType?> onAnimationChanged;
  final ValueChanged<double?> onFontSizeChanged;
  final ValueChanged<String?> onFontWeightChanged;

  const TextComponentFieldsWidget({
    super.key,
    required this.textController,
    this.textColor,
    this.animation,
    this.fontSize,
    this.fontWeight,
    required this.onTextChanged,
    required this.onTextColorChanged,
    required this.onAnimationChanged,
    required this.onFontSizeChanged,
    required this.onFontWeightChanged,
  });
  Color _hexToColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.black;
    final hexColor = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }
  String _colorToHex(Color color) {
    final argb = color.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#${argb.substring(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = _hexToColor(textColor);
    final currentSize = fontSize ?? 16.0;
    final weightMap = <String, FontWeight>{
      'Thin (100)': FontWeight.w100,
      'Light (300)': FontWeight.w300,
      'Regular (400)': FontWeight.w400,
      'Medium (500)': FontWeight.w500,
      'Bold (700)': FontWeight.w700,
      'Black (900)': FontWeight.w900,
    };
    final currentWeight = weightMap[fontWeight ?? 'Regular (400)'] ?? FontWeight.w400;


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
              child: Text(
                textController.text.isEmpty ? 'Your text here' : textController.text,
                style: TextStyle(
                  color: currentColor,
                  fontSize: currentSize,
                  fontWeight: currentWeight,
                ),
              ),
            ),
            const Divider(height: 32),

            // ───── Text Content ─────
            TextField(
              controller: textController,
              decoration: const InputDecoration(labelText: 'Text Content'),
              onChanged: onTextChanged,
            ),
            const SizedBox(height: 10),

            // ───── Color Picker ─────
            ListTile(
              title: const Text('Text Color'),
              trailing: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: currentColor,
                  border: Border.all(color: Colors.grey),
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    Color selectedColor = currentColor;
                    return AlertDialog(
                      title: const Text('Pick a color'),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: selectedColor,
                          onColorChanged: (color) => selectedColor = color,
                          labelTypes: const [], // Replace deprecated showLabel
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
                            onTextColorChanged(_colorToHex(selectedColor));
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

            // ───── Animation Picker ─────
            DropdownButtonFormField<AnimationType>(
              decoration: const InputDecoration(labelText: 'Animation'),
              value: animation,
              items: AnimationType.values
                  .map((anim) => DropdownMenuItem(
                value: anim,
                child: Text(anim.toString().split('.').last),
              ))
                  .toList(),
              onChanged: onAnimationChanged,
            ),
            const SizedBox(height: 10),

            // ───── Font Size Slider ─────
            Slider(
              min: 8,
              max: 72,
              divisions: 64,
              value: currentSize,
              label: currentSize.toStringAsFixed(0),
              onChanged: onFontSizeChanged,
            ),
            const SizedBox(height: 10),

            // ───── Font Weight Dropdown ─────
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Font Weight'),
              value: weightMap.entries
                  .firstWhere((e) => e.value == currentWeight,
                  orElse: () => MapEntry('Regular (400)', FontWeight.w400))
                  .key,
              items: weightMap.keys.map((label) {
                return DropdownMenuItem(value: label, child: Text(label));
              }).toList(),
              onChanged: onFontWeightChanged,
            ),
          ],
        ),
      ),
    );
  }
}