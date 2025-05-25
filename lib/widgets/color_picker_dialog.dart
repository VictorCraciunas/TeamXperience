import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:teamxperience/utils/color_conversion.dart';

import '../../../../../../../constants/colors.dart';

class ColorPickerDialog {
  static Future<void> show(BuildContext context, String title, Color initialColor, Function(String) onColorChanged) async {
    Color dialogColor = initialColor;
    TextEditingController rController = TextEditingController(text: (initialColor.r * 255).toInt().toString());
    TextEditingController gController = TextEditingController(text: (initialColor.g * 255).toInt().toString());
    TextEditingController bController = TextEditingController(text: (initialColor.b * 255).toInt().toString());
    TextEditingController aController = TextEditingController(text: (initialColor.a * 255).toInt().toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(title),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ColorPicker(
                      labelTypes: const [],
                      pickerColor: dialogColor,
                      onColorChanged: (color) {
                        setState(() {
                          dialogColor = color;
                          rController.text = (color.r * 255).toInt().toString();
                          gController.text = (color.g * 255).toInt().toString();
                          bController.text = (color.b * 255).toInt().toString();
                          aController.text = (color.a * 255).toInt().toString();
                        });
                      },
                      enableAlpha: true,
                    ),
                    Row(
                      children: [
                        Expanded(child: _buildInputField('R', rController)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildInputField('G', gController)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildInputField('B', bController)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildInputField('A', aController)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                try {
                  int r = int.parse(rController.text);
                  int g = int.parse(gController.text);
                  int b = int.parse(bController.text);
                  int a = int.parse(aController.text);
                  if (r >= 0 && r <= 255 &&
                      g >= 0 && g <= 255 &&
                      b >= 0 && b <= 255 &&
                      a >= 0 && a <= 255) {
                    dialogColor = Color.fromRGBO(r, g, b, a / 255.0);
                    onColorChanged(ColorConversion().colorToHex(dialogColor));
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Values out of range')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid input')),
                  );
                }
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildInputField(String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(hint, style: const TextStyle(fontSize: 20, color: MyColors.blackColor)),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: MyColors.lightBlue, width: 1.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: InputBorder.none,
            ),
            keyboardType: hint.contains('A') ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.number,
          ),
        ),
      ],
    );
  }

}