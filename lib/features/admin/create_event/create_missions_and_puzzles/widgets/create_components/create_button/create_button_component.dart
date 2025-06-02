import 'package:flutter/material.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/widgets/my_button.dart';
import 'package:teamxperience/widgets/my_text_field.dart';
import 'package:teamxperience/widgets/slider_widget.dart';
import '../../../../../../../enums/component-type.dart';
import '../../../../../../../model/component.dart';
import '../../../../../../../model/puzzle.dart';
import '../../../../../../../utils/component_conversion/component_to_widget.dart';
import '../../../../../../../widgets/my_dropdown.dart';
import '../../../controller/add_missions_controller.dart';
import 'create_button_controller.dart';

class ButtonComponentFieldsWidget extends StatefulWidget {
  final Function(Widget) refreshUI;
  final Component component;
  final bool edit;
  final Puzzle puzzle;

  const ButtonComponentFieldsWidget({
    super.key,
    required this.refreshUI,
    required this.component,
    required this.edit,
    required this.puzzle,
  });

  @override
  State<ButtonComponentFieldsWidget> createState() => _ButtonComponentFieldsWidgetState();
}

class _ButtonComponentFieldsWidgetState extends State<ButtonComponentFieldsWidget> {
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

    // Initialize controller with existing data if in edit mode
    if (widget.edit && widget.component.type == ComponentType.button) {
      controller.initializeFromComponent(widget.component);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        _buildPreviewSection(),
        const SizedBox(height: 30),
        _buildButtonLabelField(),
        const SizedBox(height: 20),
        _buildFontFamilyDropdown(),
        const SizedBox(height: 20),
        _buildFontWeightDropdown(),
        const SizedBox(height: 20),
        _buildColorFields(),
        const SizedBox(height: 20),
        _buildCornerRadiusSlider(),
        const SizedBox(height: 20),
        _buildFlickerCheckbox(),
        const SizedBox(height: 20),
        _buildGlowCheckbox(),
        const SizedBox(height: 20),
        _buildGlowColorField(),
        const SizedBox(height: 20),
        _buildFontSizeSlider(),
        const SizedBox(height: 20),
        _buildSaveButton(),
        const SizedBox(height: 60),
      ],
    );
  }

  Widget _buildPreviewSection() {
    // Create a temporary Component for preview
    final previewComponent = Component();
    controller.updateComponentFields(previewComponent);
    previewComponent.buttonLabel = controller.labelController.text.isEmpty
        ? 'Text'
        : controller.labelController.text;

    final previewWidget = ComponentToWidget().convert(previewComponent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Previzualizare',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          width: double.infinity,
          height: 100,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: MyColors.lightBlue, width: 1.5),
            borderRadius: BorderRadius.circular(15),
          ),
          child: previewWidget,
        ),
      ],
    );
  }

  Widget _buildButtonLabelField() {
    return MyTextField(
      controller: controller.labelController,
      labelText: 'Text',
      borderColor: MyColors.lightBlue,
      borderWidth: 1.5,
      radius: 20,
      validator: (value) =>
      value == null || value.isEmpty ? 'Introdu un text la buton' : null,
    );
  }

  Widget _buildFontFamilyDropdown() {
    return MyDropdownField<String>(
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
      onChanged: (value) => setState(() => controller.fontFamily = value),
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
    );
  }

  Widget _buildFontWeightDropdown() {
    return MyDropdownField<String>(
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
      onChanged: (value) => setState(() => controller.fontWeight = value),
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
    );
  }

  Widget _buildColorFields() {
    return Column(
      children: [
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
      ],
    );
  }

  Widget _buildCornerRadiusSlider() {
    return SliderWidget(
      title: 'Rotunjire chenar',
      min: 0,
      max: 50,
      divisions: 50,
      value: controller.cornerRadius,
      label: controller.cornerRadius.toStringAsFixed(0),
      onChanged: (value) => setState(() => controller.cornerRadius = value),
    );
  }

  Widget _buildFlickerCheckbox() {
    return Row(
      children: [
        Transform.scale(
          scale: 1.5,
          child: Checkbox(
            value: controller.enableFlicker,
            activeColor: MyColors.lightBlue,
            onChanged: (value) => setState(() => controller.enableFlicker = value ?? false),
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
    );
  }

  Widget _buildGlowCheckbox() {
    return Row(
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
    );
  }

  Widget _buildGlowColorField() {
    return controller.buildColorPickerField(
      title: 'Culoare Glow',
      colorHex: controller.glowColor,
      onColorChanged: (color) => setState(() => controller.glowColor = color),
      context: context,
    );
  }

  Widget _buildFontSizeSlider() {
    return SliderWidget(
      title: 'Dimensiune Text',
      min: 8,
      max: 72,
      divisions: 64,
      value: controller.fontSize,
      label: controller.fontSize.toStringAsFixed(0),
      onChanged: (value) => setState(() => controller.fontSize = value),
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: MyButton(
        buttonText: 'Salvează componenta',
        textColor: Colors.white,
        buttonOnTap: () {
          controller.saveComponent(
            context: context,
            puzzle: widget.puzzle,
            component: widget.component,
            refreshUI: widget.refreshUI,
            isEditMode: widget.edit,
          );
        },
        withBorder: false,
        buttonColor: MyColors.lightBlue,
        fontWeight: FontWeight.w500,
        buttonTextSize: 14,
        buttonWidth: 270,
      ),
    );
  }
}