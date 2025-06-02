import 'package:flutter/material.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/widgets/my_button.dart';
import 'package:teamxperience/widgets/my_dropdown.dart';
import '../../../../../../../enums/component-type.dart';
import '../../../../../../../model/component.dart';
import '../../../../../../../model/puzzle.dart';
import '../../../../../../../utils/component_conversion/component_to_widget.dart';
import '../../../controller/add_missions_controller.dart';
import 'code_component_controller.dart';
import '../../../../../../../widgets/slider_widget.dart';

class CodeComponentFieldsWidget extends StatefulWidget {
  final Function(Widget) refreshUI;
  final Component component;
  final bool edit;
  final Puzzle puzzle;

  const CodeComponentFieldsWidget({
    super.key,
    required this.refreshUI,
    required this.component,
    required this.edit,
    required this.puzzle,
  });

  @override
  State<CodeComponentFieldsWidget> createState() => _CodeComponentFieldsWidgetState();
}

class _CodeComponentFieldsWidgetState extends State<CodeComponentFieldsWidget> {
  late final CodeComponentController controller;

  @override
  void initState() {
    super.initState();
    controller = CodeComponentController();

    // Initialize controller with existing data if in edit mode
    if (widget.edit && widget.component.type == ComponentType.code) {
      controller.initializeFromComponent(widget.component);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildPreviewSection(),
          const SizedBox(height: 30),
          _buildBasicConfigurationSection(),
          const SizedBox(height: 20),
          _buildStylingSection(),
          const SizedBox(height: 20),
          _buildTextStylingSection(),
          const SizedBox(height: 20),
          _buildGlowEffectSection(),
          const SizedBox(height: 20),
          _buildSaveButton(),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildPreviewSection() {
    if (!controller.canShowPreview) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Previzualizare',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: MyColors.blackColor,
            ),
          ),
          SizedBox(height: 15),
          Center(
            child: Text('Select number of characters, input type and colors of the fields'),
          ),
        ],
      );
    }

    // Create a temporary Component for preview
    final previewComponent = Component();
    controller.updateComponent(previewComponent);

    // Use ComponentToWidget to convert to widget
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
            color: MyColors.blackColor,
          ),
        ),
        const SizedBox(height: 15),
        Center(child: previewWidget),
      ],
    );
  }

  Widget _buildBasicConfigurationSection() {
    return Column(
      children: [
        _buildCodeLengthDropdown(),
        const SizedBox(height: 20),
        _buildInputTypeDropdown(),
        const SizedBox(height: 20),
        _buildCapsLockDropdown(),
      ],
    );
  }

  Widget _buildCodeLengthDropdown() {
    return MyDropdownField<int>(
      labelText: 'Număr de caractere',
      items: List.generate(10, (index) => index + 1)
          .map(
            (length) => DropdownMenuItem(
          value: length,
          child: Text('$length'),
        ),
      )
          .toList(),
      value: controller.codeLength,
      onChanged: (value) => setState(() => controller.codeLength = value),
      borderColor: MyColors.lightBlue,
      borderWidth: 1.5,
      radius: 20,
      hint: const Text('Selecteaza numărul de caractere'),
    );
  }

  Widget _buildInputTypeDropdown() {
    return MyDropdownField<String>(
      labelText: 'Separat / Free',
      items: const [
        DropdownMenuItem(value: 'Separated', child: Text('Separated')),
        DropdownMenuItem(value: 'Free', child: Text('Free')),
      ],
      value: controller.inputType,
      onChanged: (value) => setState(() => controller.inputType = value),
      borderColor: MyColors.lightBlue,
      borderWidth: 1.5,
      radius: 20,
      hint: const Text('Selecteaza tipul de cod'),
    );
  }

  Widget _buildCapsLockDropdown() {
    return MyDropdownField<String>(
      labelText: 'CapsLock / Fără',
      items: const [
        DropdownMenuItem(value: 'CapsLock', child: Text('CapsLock')),
        DropdownMenuItem(value: 'Fără', child: Text('Fără')),
      ],
      value: controller.capsLock,
      onChanged: (value) => setState(() => controller.capsLock = value),
      borderColor: MyColors.lightBlue,
      borderWidth: 1.5,
      radius: 20,
      hint: const Text('Selecteaza tipul de cod'),
    );
  }

  Widget _buildStylingSection() {
    return Column(
      children: [
        _buildFrameRadiusSlider(),
        const SizedBox(height: 20),
        _buildInputWidthSlider(),
        const SizedBox(height: 20),
        _buildInputRadiusSlider(),
        const SizedBox(height: 20),
        _buildFrameBackgroundColorPicker(),
        const SizedBox(height: 20),
        _buildInputBackgroundColorPicker(),
        const SizedBox(height: 20),
        _buildInputBorderColorPicker(),
        const SizedBox(height: 20),
        _buildFrameBorderColorPicker(),
      ],
    );
  }

  Widget _buildFrameRadiusSlider() {
    return SliderWidget(
      title: 'Rotunjire chenar',
      min: 0,
      max: 50,
      divisions: 50,
      value: controller.radiusChenar,
      label: controller.radiusChenar.toStringAsFixed(0),
      onChanged: (value) => setState(() => controller.radiusChenar = value),
    );
  }

  Widget _buildInputWidthSlider() {
    return SliderWidget(
      title: 'Lungime inputuri',
      min: 0,
      max: 200,
      divisions: 200,
      value: controller.widthInput,
      label: controller.widthInput.toStringAsFixed(0),
      onChanged: (value) => setState(() => controller.widthInput = value),
    );
  }

  Widget _buildInputRadiusSlider() {
    return SliderWidget(
      title: 'Rotunjire chenar inputuri',
      min: 0,
      max: 50,
      divisions: 50,
      value: controller.radiusChenarInputuri,
      label: controller.radiusChenarInputuri.toStringAsFixed(0),
      onChanged: (value) => setState(() => controller.radiusChenarInputuri = value),
    );
  }

  Widget _buildFrameBackgroundColorPicker() {
    return controller.buildColorPickerField(
      'Culoare fundal chenar',
      controller.frameBackgroundColor,
          (color) => setState(() => controller.frameBackgroundColor = color),
      context,
    );
  }

  Widget _buildInputBackgroundColorPicker() {
    return controller.buildColorPickerField(
      'Culoare fundal input-uri',
      controller.inputBackgroundColor,
          (color) => setState(() => controller.inputBackgroundColor = color),
      context,
    );
  }

  Widget _buildInputBorderColorPicker() {
    return controller.buildColorPickerField(
      'Culoare bordura input',
      controller.colorBorderInput,
          (color) => setState(() => controller.colorBorderInput = color),
      context,
    );
  }

  Widget _buildFrameBorderColorPicker() {
    return controller.buildColorPickerField(
      'Culoare bordura chenar',
      controller.colorBorderContainer,
          (color) => setState(() => controller.colorBorderContainer = color),
      context,
    );
  }

  Widget _buildTextStylingSection() {
    return Column(
      children: [
        _buildFontFamilyDropdown(),
        const SizedBox(height: 20),
        _buildFontSizeSlider(),
        const SizedBox(height: 20),
        _buildTextColorPicker(),
      ],
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
      borderColor: MyColors.lightBlue,
      borderWidth: 1.5,
      radius: 20,
      hint: const Text(
        'Selecteaza tipul de font',
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
      onChanged: (value) => setState(() => controller.fontSize = value),
    );
  }

  Widget _buildTextColorPicker() {
    return controller.buildColorPickerField(
      'Culoare text input',
      controller.textColor,
          (color) => setState(() => controller.textColor = color),
      context,
    );
  }

  Widget _buildGlowEffectSection() {
    return Column(
      children: [
        _buildGlowCheckbox(),
        const SizedBox(height: 20),
        _buildGlowColorPicker(),
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
            onChanged: (value) => setState(() => controller.enableGlow = value!),
            activeColor: MyColors.lightBlue,
            checkColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            side: const BorderSide(width: 1.5, color: MyColors.lightBlue),
          ),
        ),
        const SizedBox(width: 16),
        const Text(
          'Glow Chenar',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: MyColors.blackColor,
          ),
        ),
      ],
    );
  }

  Widget _buildGlowColorPicker() {
    return controller.buildColorPickerField(
      'Culoare Glow',
      controller.glowColor,
          (color) => setState(() => controller.glowColor = color),
      context,
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