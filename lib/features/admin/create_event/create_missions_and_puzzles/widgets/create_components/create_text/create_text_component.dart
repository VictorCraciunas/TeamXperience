import 'package:flutter/material.dart';
import 'package:teamxperience/enums/animation_type.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/widgets/my_text_field.dart';
import 'package:teamxperience/widgets/my_dropdown.dart';
import 'package:teamxperience/widgets/my_button.dart';
import 'package:teamxperience/widgets/color_picker_dialog.dart';
import 'package:teamxperience/widgets/slider_widget.dart';

import '../../../../../../../enums/component-type.dart';
import '../../../../../../../model/component.dart';
import '../../../../../../../utils/component_conversion/component_to_widget.dart';
import '../../../controller/add_missions_controller.dart';
import 'create_text_controller.dart';


class TextComponentFieldsWidget extends StatefulWidget {
  final AddMissionsController addMissionsController;
  final int missionSelected;
  final int puzzleSelected;
  final Function(Widget) refreshUI;
  final Component? componentToEdit;


  const TextComponentFieldsWidget({
    super.key,
    required this.addMissionsController,
    required this.missionSelected,
    required this.puzzleSelected,
    required this.refreshUI,
    this.componentToEdit
  });

  @override
  State<TextComponentFieldsWidget> createState() => _TextComponentFieldsWidgetState();
}

class _TextComponentFieldsWidgetState extends State<TextComponentFieldsWidget> {
  late final TextComponentController controller;
  final Map<String, FontWeight> weightMap = {
    'Thin (100)': FontWeight.w100,
    'Light (300)': FontWeight.w300,
    'Regular (400)': FontWeight.w400,
    'Medium (500)': FontWeight.w500,
    'Bold (700)': FontWeight.w700,
    'Black (900)': FontWeight.w900,
  };

  @override
  void initState() {
    super.initState();
    controller = TextComponentController();

    final c = widget.componentToEdit;
    if (c != null && c.type == ComponentType.text) {
      // 1) Seed the text content
      controller.textController.text = c.text ?? '';

      // 2) Seed styling fields
      controller.textColor    = c.textColor    ?? controller.textColor;
      controller.animation    = c.animation;
      controller.fontSize     = c.fontSize     ?? controller.fontSize;
      controller.fontWeight   = c.fontWeight;
      controller.fontFamily   = c.fontFamily;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = controller.hexToColor(controller.textColor);
    final currentSize = controller.fontSize;
    final currentWeight = controller.fontWeight != null ? weightMap[controller.fontWeight] ?? FontWeight.w400 : FontWeight.w400;
    final currentFontFamily = controller.fontFamily ?? 'Poppins'; // Default for preview

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
          padding: const EdgeInsets.all(12),
          child: Center(
            child: Text(
              controller.textController.text.isEmpty
                  ? 'Textul tau aici'
                  : controller.textController.text,
              style: TextStyle(
                color: currentColor,
                fontSize: currentSize,
                fontWeight: currentWeight,
                fontFamily: currentFontFamily,
              ),
              textAlign: TextAlign.center,
              maxLines: null,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
        const SizedBox(height: 50),

        // ───── Text Content ─────
        MyTextField(
          controller: controller.textController,
          labelText: 'Conținut Text',
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
          value: controller.animation,
          onChanged: (value) {
            setState(() {
              controller.animation = value;
            });
          },
          validator: (value) => value == null ? 'Selecteaza animația' : null,
          borderColor: MyColors.lightBlue,
          borderWidth: 1.5,
          radius: 20,
          hint: const Text(
            'Selectează animația',
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
          value: controller.fontFamily,
          onChanged: (value) {
            setState(() {
              controller.fontFamily = value;
            });
          },
          validator: (value) => value == null ? 'Selectează tipul de font' : null,
          borderColor: MyColors.lightBlue,
          borderWidth: 1.5,
          radius: 20,
          hint: const Text(
            'Selectează tipul de font',
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
          value: controller.fontWeight,
          onChanged: (value) {
            setState(() {
              controller.fontWeight = value;
            });
          },
          validator: (value) => value == null ? 'Selectează grosimea fontului' : null,
          borderColor: MyColors.lightBlue,
          borderWidth: 1.5,
          radius: 20,
          hint: const Text(
            'Selectează grosimea fontului',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: MyColors.greyText,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ───── Font Size Slider ─────
        SliderWidget(
          title: 'Dimensiune Text',
          min: 8,
          max: 72,
          divisions: 64,
          value: controller.fontSize,
          label: controller.fontSize.toStringAsFixed(0),
          onChanged: (value) {
            setState(() {
              controller.fontSize = value;
            });
          },
        ),
        const SizedBox(height: 16),

        // ───── Text Color ─────
        MyTextField(
          hinttextWeight: FontWeight.w500,
          hintTextSize: 15,
          hintTextColor: MyColors.blackColor,
          controller: controller.textColorController,
          hintText: 'Culoare Text',
          borderColor: MyColors.lightBlue,
          radius: 15,
          readOnly: true,
          onTap: () {
            ColorPickerDialog.show(
              context,
              'Pick a color',
              controller.hexToColor(controller.textColor),
                  (color) {
                setState(() {
                  controller.textColor = color;
                });
              },
            );
          },
          trailing: Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              color: controller.hexToColor(controller.textColor),
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
            buttonOnTap: () {
              // Validate text
              if (controller.textController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter text content')),
                );
                return;
              }
              // Validate required styling fields
              if (controller.animation == null
                  || controller.fontWeight == null
                  || controller.fontFamily == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select all required fields')),
                );
                return;
              }

              final c = widget.componentToEdit;
              if (c != null && c.type == ComponentType.text) {
                // —— EDIT FLOW ——
                c.text       = controller.textController.text;
                c.textColor  = controller.textColor;
                c.animation  = controller.animation;
                c.fontSize   = controller.fontSize;
                c.fontWeight = controller.fontWeight;
                c.fontFamily = controller.fontFamily;

                // rebuild the widget and pop
                final updatedWidget = ComponentToWidget().convert(c);
                widget.refreshUI(updatedWidget);
                Navigator.pop(context);

              } else {
                // —— CREATE FLOW ——
                controller.saveComponent(
                  context,
                  widget.missionSelected,
                  widget.puzzleSelected,
                  widget.addMissionsController,
                  widget.refreshUI,
                );
              }
            },
            withBorder: false,
            buttonColor: MyColors.lightBlue,
            fontWeight: FontWeight.w500,
            buttonTextSize: 14,
            buttonWidth: 270,
          ),
        ),
        const SizedBox(height: 60),

      ],
    );
  }
}