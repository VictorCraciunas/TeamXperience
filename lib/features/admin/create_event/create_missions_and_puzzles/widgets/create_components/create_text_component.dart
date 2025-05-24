import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:teamxperience/enums/animation_type.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/widgets/my_text_field.dart';
import 'package:teamxperience/widgets/my_dropdown.dart';
import 'package:teamxperience/widgets/my_button.dart';

import '../../../../../../enums/component-type.dart';
import '../../../../../../utils/component_conversion/component_to_widget.dart';
import '../../controller/add_missions_controller.dart';

class TextComponentFieldsWidget extends StatefulWidget {
  final TextEditingController textController;
  final AddMissionsController addMissionsController;
  final int missionSelected;
  final int puzzleSelected;
  final Function(Widget) refreshUI;

  const TextComponentFieldsWidget({
    super.key,
    required this.textController,
    required this.addMissionsController,
    required this.missionSelected,
    required this.puzzleSelected,
    required this.refreshUI,
  });

  @override
  State<TextComponentFieldsWidget> createState() =>
      _TextComponentFieldsWidgetState();
}

class _TextComponentFieldsWidgetState extends State<TextComponentFieldsWidget> {
  late String textColor;
  late AnimationType? animation;
  late double fontSize;
  late String? fontWeight;
  late String? fontFamily; // New state for font family
  TextEditingController textColorController = TextEditingController();
  TextEditingController fontController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textColor = '#000000';
    animation = null; // Set to null to show hint
    fontSize = 16.0;
    fontWeight = null; // Set to null to show hint
    fontFamily = null; // Set to null to show hint
  }

  Color _hexToColor(String hex) {
    if (hex.isEmpty) return Colors.black;
    final hexColor = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  String _colorToHex(Color color) {
    final argb = color.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#${argb.substring(2)}';
  }

  ComponentToWidget componentToWidget = ComponentToWidget();

  void _saveComponent() {
    if (widget.textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text content')),
      );
      return;
    }
    if (animation == null || fontWeight == null || fontFamily == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select all required fields')),
      );
      return;
    }

    Component component = widget.addMissionsController.addComponent(
      widget.missionSelected,
      widget.puzzleSelected,
      ComponentType.text,
      text: widget.textController.text,
      textColor: textColor,
      animation: animation,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontFamily: fontFamily,
    );
    Widget componentWidget = componentToWidget.convert(component);
    widget.refreshUI(componentWidget);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = _hexToColor(textColor);
    final currentSize = fontSize;
    final weightMap = <String, FontWeight>{
      'Thin (100)': FontWeight.w100,
      'Light (300)': FontWeight.w300,
      'Regular (400)': FontWeight.w400,
      'Medium (500)': FontWeight.w500,
      'Bold (700)': FontWeight.w700,
      'Black (900)': FontWeight.w900,
    };
    final currentWeight = fontWeight != null ? weightMap[fontWeight] ?? FontWeight.w400 : FontWeight.w400;
    final currentFontFamily = fontFamily ?? 'Poppins'; // Default for preview

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        // ───── Preview ─────
        const Text(
          'Previzualizare',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: MyColors.lightBlue, width: 1.5),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(12), // Added padding for better appearance
          child: Center(
            child: Text(
              widget.textController.text.isEmpty
                  ? 'Your text here'
                  : widget.textController.text,
              style: TextStyle(
                color: currentColor,
                fontSize: currentSize,
                fontWeight: currentWeight,
                fontFamily: currentFontFamily,
              ),
              textAlign: TextAlign.center, // Optional: centers the text horizontally
              maxLines: null, // Allows text to wrap to multiple lines
              overflow: TextOverflow.visible, // Ensures text wraps naturally
            ),
          ),
        ),
        const SizedBox(height: 50),

        // ───── Text Content ─────
        MyTextField(
          controller: widget.textController,
          labelText: 'Continut Text',
          borderColor: MyColors.lightBlue,
          borderWidth: 1.5,
          radius: 20,
          maxLines: null,
          validator: (value) =>
          value == null || value.isEmpty ? 'Please enter text content' : null,
        ),

        // ───── Animation Picker ─────
        const SizedBox(height: 16),
        MyDropdownField<AnimationType>(
          labelText: 'Animatie',
          items: AnimationType.values
              .map(
                (anim) => DropdownMenuItem(
              value: anim,
              child: Text(
                anim.toString().split('.').last,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
          )
              .toList(),
          value: animation,
          onChanged: (value) {
            setState(() {
              animation = value;
            });
          },
          validator: (value) => value == null ? 'Selecteaza animatia' : null,
          borderColor: MyColors.lightBlue,
          borderWidth: 1.5,
          radius: 20,
          selectedItemStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Colors.black,
          ),
          hint: const Text(
            'Selecteaza animatia',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: MyColors.greyText,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ───── Font Family Dropdown ─────
        MyDropdownField<String>(
          labelText: 'Tip Font',
          items: const [
            DropdownMenuItem(
              value: 'Poppins',
              child: Text(
                'Poppins',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
            DropdownMenuItem(
              value: 'Monospace',
              child: Text(
                'Monospace',
                style: TextStyle(
                  fontFamily: 'Monospace',
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
          ],
          value: fontFamily,
          onChanged: (value) {
            setState(() {
              fontFamily = value;
            });
          },
          validator: (value) => value == null ? 'Selecteaza tipul de font' : null,
          borderColor: MyColors.lightBlue,
          borderWidth: 1.5,
          radius: 20,
          selectedItemStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Colors.black,
          ),
          hint: const Text(
            'Selecteaza tipul de font',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: MyColors.greyText,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ───── Font Weight Dropdown ─────
        MyDropdownField<String>(
          labelText: 'Grosime Font',
          items: weightMap.keys
              .map((label) => DropdownMenuItem(
            value: label,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ))
              .toList(),
          value: fontWeight,
          onChanged: (value) {
            setState(() {
              fontWeight = value;
            });
          },
          validator: (value) => value == null ? 'Selecteaza grosimea fontului' : null,
          borderColor: MyColors.lightBlue,
          borderWidth: 1.5,
          radius: 20,
          selectedItemStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Colors.black,
          ),
          hint: const Text(
            'Selecteaza grosimea fontului',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: MyColors.greyText,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ───── Font Size Slider ─────
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dimensiune Text',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: MyColors.lightBlue, width: 1.5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Slider(
                min: 8,
                max: 72,
                divisions: 64,
                value: currentSize,
                label: currentSize.toStringAsFixed(0),
                activeColor: MyColors.lightBlue,
                inactiveColor: MyColors.greyText.withValues(alpha: 0.3),
                onChanged: (value) {
                  setState(() {
                    fontSize = value;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ───── Text Color ─────
        MyTextField(
          controller: textColorController,
          hintText: 'Culoare Text',
          borderColor: MyColors.lightBlue,
          radius: 15,
          readOnly: true,
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
                        setState(() {
                          textColor = _colorToHex(selectedColor);
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          },
          trailing: Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              color: currentColor,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ───── Save Button ─────
        Center(
          child: MyButton(
            buttonText: 'Salveaza componenta',
            textColor: Colors.white,
            buttonOnTap: _saveComponent,
            withBorder: false,
            buttonColor: MyColors.lightBlue,
            fontWeight: FontWeight.w500,
            buttonTextSize: 14,
            buttonWidth: 270,
          ),
        ),
      ],
    );
  }
}