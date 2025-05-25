import 'package:flutter/material.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/widgets/my_button.dart';
import 'package:teamxperience/widgets/my_text_field.dart';
import 'package:teamxperience/widgets/slider_widget.dart';
import '../../../../../../../widgets/my_dropdown.dart';
import '../../../controller/add_missions_controller.dart';
import 'create_button_controller.dart';

class ButtonComponentFieldsWidget extends StatefulWidget {
  final AddMissionsController addMissionsController;
  final int missionSelected;
  final int puzzleSelected;
  final Function(Widget) refreshUI;

  const ButtonComponentFieldsWidget({
    super.key,
    required this.addMissionsController,
    required this.missionSelected,
    required this.puzzleSelected,
    required this.refreshUI,
  });

  @override
  ButtonComponentFieldsWidgetState createState() => ButtonComponentFieldsWidgetState();
}

class ButtonComponentFieldsWidgetState extends State<ButtonComponentFieldsWidget> {
  late final ButtonComponentController controller;
  final weightMap = <String, FontWeight>{
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
    controller = ButtonComponentController();
  }

  @override
  Widget build(BuildContext context) {
    final currentWeight = controller.fontWeight != null
        ? weightMap[controller.fontWeight] ?? FontWeight.w400
        : FontWeight.w400;
    final currentFontFamily = controller.fontFamily ?? 'Poppins';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        // Preview Label
        const Text(
          'Previzualizare',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 15),

        // Preview Section
        Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: MyColors.lightBlue, width: 1.5),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (_) => setState(() => controller.isTapped = true),
              onPointerUp: (_) => setState(() => controller.isTapped = false),
              onPointerCancel: (_) => setState(() => controller.isTapped = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: controller.isTapped
                      ? controller.hexToColor(controller.buttonColorOnTap)
                      : controller.hexToColor(controller.buttonColor),
                  border: Border.all(
                      color: controller.hexToColor(controller.borderColor), width: 1.5),
                  borderRadius: BorderRadius.circular(controller.cornerRadius),
                  boxShadow: controller.enableGlow
                      ? [
                    BoxShadow(
                      color: controller
                          .hexToColor(controller.glowColor)
                          .withValues(alpha: 0.6),
                      blurRadius: 10.0,
                      spreadRadius: 2.0,
                      offset: const Offset(0, 0),
                    ),
                  ]
                      : null,
                ),
                child: Text(
                  controller.labelController.text.isEmpty
                      ? 'Text'
                      : controller.labelController.text,
                  style: TextStyle(
                    color: controller.isTapped
                        ? controller.hexToColor(controller.buttonTextColorOnTap)
                        : controller.hexToColor(controller.buttonTextColor),
                    fontSize: 16,
                    fontWeight: currentWeight,
                    fontFamily: currentFontFamily,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),

        // Button Label Input
        MyTextField(
          controller: controller.labelController,
          labelText: 'Text',
          borderColor: MyColors.lightBlue,
          borderWidth: 1.5,
          radius: 20,
          validator: (value) =>
          value == null || value.isEmpty ? 'Introdu un text la buton' : null,
        ),
        const SizedBox(height: 20),

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
          selectedItemStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Colors.black,
          ),
          hint: const Text(
            'Selectează tipul de font',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: MyColors.greyText,
            ),
          ),
        ),
        const SizedBox(height: 20),

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
          selectedItemStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Colors.black,
          ),
          hint: const Text(
            'Selectează grosimea fontului',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: MyColors.greyText,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Color Pickers
        controller.buildColorPickerField(
          title: 'Culoare fundal',
          colorHex: controller.buttonColor,
          onColorChanged: (color) => setState(() => controller.buttonColor = color),
          context: context,
        ),
        const SizedBox(height: 20),

        controller.buildColorPickerField(
          title: 'Culoare fundal apăsat',
          colorHex: controller.buttonColorOnTap,
          onColorChanged: (color) => setState(() => controller.buttonColorOnTap = color),
          context: context,
        ),
        const SizedBox(height: 20),

        controller.buildColorPickerField(
          title: 'Culoare text',
          colorHex: controller.buttonTextColor,
          onColorChanged: (color) => setState(() => controller.buttonTextColor = color),
          context: context,
        ),
        const SizedBox(height: 20),

        controller.buildColorPickerField(
          title: 'Culoare text apăsat',
          colorHex: controller.buttonTextColorOnTap,
          onColorChanged: (color) => setState(() => controller.buttonTextColorOnTap = color),
          context: context,
        ),
        const SizedBox(height: 20),

        controller.buildColorPickerField(
          title: 'Culoare chenar',
          colorHex: controller.borderColor,
          onColorChanged: (color) => setState(() => controller.borderColor = color),
          context: context,
        ),
        const SizedBox(height: 20),

        // ───── Corner Radius Slider ─────
        SliderWidget(
          title: 'Rotunjire chenar',
          min: 0,
          max: 50,
          divisions: 50,
          value: controller.cornerRadius,
          label: controller.cornerRadius.toStringAsFixed(0),
          onChanged: (value) {
            setState(() {
              controller.cornerRadius = value;
            });
          },
        ),
        const SizedBox(height: 20),

        // ───── Flicker Animation Checkbox ─────
        Row(
          children: [
            Transform.scale(
              scale: 1.5,
              child: Checkbox(
                value: controller.enableFlicker,
                activeColor: MyColors.lightBlue,
                onChanged: (value) {
                  setState(() {
                    controller.enableFlicker = value ?? false;
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                side: const BorderSide(
                  width: 1.5,
                  color: MyColors.lightBlue,
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Animatie Flicker',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ───── Glow Button Checkbox ─────
        Row(
          children: [
            Transform.scale(
              scale: 1.5,
              child: Checkbox(
                value: controller.enableGlow,
                onChanged: (v) => setState(() => controller.enableGlow = v!),
                activeColor: MyColors.lightBlue,
                checkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                side: const BorderSide(
                  width: 1.5,
                  color: MyColors.lightBlue,
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Glow buton',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        controller.buildColorPickerField(
          title: 'Culoare Glow',
          colorHex: controller.glowColor,
          onColorChanged: (color) => setState(() => controller.glowColor = color),
          context: context,
        ),
        const SizedBox(height: 20),

        // Save Button
        Center(
          child: MyButton(
            buttonText: 'Salveaza componenta',
            textColor: Colors.white,
            buttonOnTap: () => controller.saveComponent(
              context,
              widget.missionSelected,
              widget.puzzleSelected,
              widget.addMissionsController,
              widget.refreshUI,
            ),
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