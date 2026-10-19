import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/ui/components/buttons/my_button.dart';
import 'package:teamxperience/ui/components/inputs/my_dropdown/my_dropdown.dart';
import '../../../../../../../enums/component-type.dart';
import '../../../../../../../model/component.dart';
import '../../../../../../../model/puzzle.dart';
import '../../../../../../../utils/component_conversion/component_to_widget.dart';
import 'package:teamxperience/ui/components/inputs/my_dropdown/dropdown_item.dart';
import 'code_component_controller.dart';
import 'package:teamxperience/ui/components/misc/slider_widget.dart';

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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Previzualizare',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: context.colors.text,
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
        Text(
          'Previzualizare',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: context.colors.text,
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
            (length) => DropdownItem<int>(
          value: length,
          label: '$length',
        ),
      )
          .toList(),
      value: controller.codeLength,
      onChanged: (value) => setState(() => controller.codeLength = value),
      validator: (value) => value == null ? 'Selectează numărul de caractere' : null,
      borderColor: context.colors.accent,
      borderWidth: 1.5,
      radius: 20,
      hint: Text(
        'Selectează numărul de caractere',
        style: TextStyle(
          fontSize: 14,
          color: context.colors.muted,
        ),
      ),
    );
  }

  Widget _buildInputTypeDropdown() {
    return MyDropdownField<String>(
      labelText: 'Separat / Free',
      items: const [
        DropdownItem<String>(value: 'Separated', label: 'Separated'),
        DropdownItem<String>(value: 'Free', label: 'Free'),
      ],
      value: controller.inputType,
      onChanged: (value) => setState(() => controller.inputType = value),
      validator: (value) => value == null ? 'Selectează tipul de cod' : null,
      borderColor: context.colors.accent,
      borderWidth: 1.5,
      radius: 20,
      hint: Text(
        'Selectează tipul de cod',
        style: TextStyle(
          fontSize: 14,
          color: context.colors.muted,
        ),
      ),
    );
  }

  Widget _buildCapsLockDropdown() {
    return MyDropdownField<String>(
      labelText: 'CapsLock / Fără',
      items: const [
        DropdownItem<String>(value: 'CapsLock', label: 'CapsLock'),
        DropdownItem<String>(value: 'Fără', label: 'Fără'),
      ],
      value: controller.capsLock,
      onChanged: (value) => setState(() => controller.capsLock = value),
      validator: (value) => value == null ? 'Selectează tipul de cod' : null,
      borderColor: context.colors.accent,
      borderWidth: 1.5,
      radius: 20,
      hint: Text(
        'Selectează tipul de cod',
        style: TextStyle(
          fontSize: 14,
          color: context.colors.muted,
        ),
      ),
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
        DropdownItem<String>(
          value: 'Poppins',
          label: 'Poppins',
        ),
        DropdownItem<String>(
          value: 'Monospace',
          label: 'Monospace',
        ),
      ],
      value: controller.fontFamily,
      onChanged: (value) => setState(() => controller.fontFamily = value),
      validator: (value) => value == null ? 'Selectează tipul de font' : null,
      borderColor: context.colors.accent,
      borderWidth: 1.5,
      radius: 20,
      hint: Text(
        'Selectează tipul de font',
        style: TextStyle(
          fontSize: 14,
          color: context.colors.muted,
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
            activeColor: context.colors.accent,
            checkColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            side: BorderSide(width: 1.5, color: context.colors.accent),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'Glow Chenar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: context.colors.text,
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