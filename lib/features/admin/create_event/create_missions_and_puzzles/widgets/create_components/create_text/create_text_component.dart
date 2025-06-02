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
import '../../../../../../../model/puzzle.dart';
import '../../../../../../../utils/component_conversion/component_to_widget.dart';
import 'create_text_controller.dart';

class TextComponentFieldsWidget extends StatefulWidget {
  final Function(Widget) refreshUI;
  final Component component;
  final bool edit;
  final Puzzle puzzle;

  const TextComponentFieldsWidget({
    super.key,
    required this.refreshUI,
    required this.component,
    required this.edit,
    required this.puzzle,
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

    // Initialize controller with existing data if in edit mode
    if (widget.edit && widget.component.type == ComponentType.text) {
      controller.initializeFromComponent(widget.component);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        _buildPreviewSection(),
        const SizedBox(height: 50),
        _buildTextContentField(),
        const SizedBox(height: 16),
        _buildAnimationDropdown(),
        const SizedBox(height: 16),
        _buildFontFamilyDropdown(),
        const SizedBox(height: 16),
        _buildFontWeightDropdown(),
        const SizedBox(height: 16),
        _buildFontSizeSlider(),
        const SizedBox(height: 16),
        _buildTextColorPicker(),
        const SizedBox(height: 16),
        _buildSaveButton(),
        const SizedBox(height: 60),
      ],
    );
  }

  Widget _buildPreviewSection() {


    final previewComponent = Component();
    controller.updateComponentFields(previewComponent);
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
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: MyColors.lightBlue, width: 1.5),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(12),
          child: previewWidget,
        ),
      ],
    );
  }

  Widget _buildTextContentField() {
    return MyTextField(
      controller: controller.textController,
      labelText: 'Conținut Text',
      borderColor: MyColors.lightBlue,
      borderWidth: 1.5,
      radius: 20,
      maxLines: null,
      validator: (value) =>
      value == null || value.isEmpty ? 'Please enter text content' : null,
    );
  }

  Widget _buildAnimationDropdown() {
    return MyDropdownField<AnimationType>(
      labelText: 'Animație',
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
      validator: (value) => value == null ? 'Selectează animația' : null,
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
      onChanged: (value) {
        setState(() {
          controller.fontSize = value;
        });
      },
    );
  }

  Widget _buildTextColorPicker() {
    return MyTextField(
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