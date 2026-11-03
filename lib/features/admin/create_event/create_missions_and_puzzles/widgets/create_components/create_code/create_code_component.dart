import 'package:flutter/material.dart';
import 'package:teamxperience/utils/component_conversion/box_effects.dart';
import 'package:teamxperience/utils/event_fonts.dart';
import '../option_checkbox.dart';
import '../optional_slider.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';
import 'package:teamxperience/ui/components/inputs/app_dropdown.dart';
import '../../../../../../../enums/component-type.dart';
import '../../../../../../../model/component.dart';
import '../../../../../../../model/puzzle.dart';
import '../../../../../../../utils/component_conversion/component_to_widget.dart';
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
  State<CodeComponentFieldsWidget> createState() =>
      _CodeComponentFieldsWidgetState();
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
          OptionCheckbox(
            label: 'Animație la răspuns',
            value: controller.answerFeedback,
            onChanged: (value) => setState(() => controller.answerFeedback = value),
          ),
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
            child: Text(
              'Select number of characters, input type and colors of the fields',
            ),
          ),
        ],
      );
    }

    // Create a temporary Component for preview
    final previewComponent = Component();
    controller.updateComponent(previewComponent);
    BoxEffects.copy(widget.component, previewComponent, shadow: true);

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
    return AppDropdown<int>(
      label: 'Număr de caractere',
      items:
          List.generate(10, (index) => index + 1)
              .map(
                (length) =>
                    AppDropdownItem<int>(value: length, label: '$length'),
              )
              .toList(),
      value: controller.codeLength,
      onChanged: (value) => setState(() => controller.codeLength = value),
      validator:
          (value) => value == null ? 'Selectează numărul de caractere' : null,
      hint: 'Selectează numărul de caractere',
    );
  }

  Widget _buildInputTypeDropdown() {
    return AppDropdown<String>(
      label: 'Separat / Free',
      items: const [
        AppDropdownItem<String>(value: 'Separated', label: 'Separated'),
        AppDropdownItem<String>(value: 'Free', label: 'Free'),
      ],
      value: controller.inputType,
      onChanged: (value) => setState(() => controller.inputType = value),
      validator: (value) => value == null ? 'Selectează tipul de cod' : null,
      hint: 'Selectează tipul de cod',
    );
  }

  Widget _buildCapsLockDropdown() {
    return AppDropdown<String>(
      label: 'CapsLock / Fără',
      items: const [
        AppDropdownItem<String>(value: 'CapsLock', label: 'CapsLock'),
        AppDropdownItem<String>(value: 'Fără', label: 'Fără'),
      ],
      value: controller.capsLock,
      onChanged: (value) => setState(() => controller.capsLock = value),
      validator: (value) => value == null ? 'Selectează tipul de cod' : null,
      hint: 'Selectează tipul de cod',
    );
  }

  Widget _buildStylingSection() {
    return Column(
      children: [
        _buildFrameRadiusSlider(),
        const SizedBox(height: 20),
        _buildInputWidthSlider(),
        const SizedBox(height: 20),
        _buildBoxHeightSlider(),
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

  Widget _buildBoxHeightSlider() {
    return OptionalSlider(
      title: 'Înălțime casete',
      min: 20,
      max: 100,
      divisions: 80,
      unit: 'px',
      value: controller.boxHeight,
      automaticValue: controller.fontSize * 1.5,
      automaticNote: 'automat',
      onChanged: (value) => setState(() => controller.boxHeight = value),
    );
  }

  Widget _buildBoldCheckbox() {
    return Row(
      children: [
        Transform.scale(
          scale: 1.5,
          child: Checkbox(
            value: controller.boldText,
            onChanged: (value) => setState(() => controller.boldText = value ?? true),
            activeColor: context.colors.accent,
            checkColor: context.colors.onTick,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            side: BorderSide(width: 1.5, color: context.colors.accent),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'Text îngroșat',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: context.colors.text),
        ),
      ],
    );
  }

  Widget _buildGlowPlaceDropdown() {
    return AppDropdown<String>(
      label: 'Glow pe',
      items: const [
        AppDropdownItem<String>(value: 'frame', label: 'Chenarul din jur'),
        AppDropdownItem<String>(value: 'boxes', label: 'Fiecare casetă'),
      ],
      value: controller.glowOn,
      onChanged: (value) => setState(() => controller.glowOn = value ?? 'frame'),
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
      onChanged:
          (value) => setState(() => controller.radiusChenarInputuri = value),
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
        _buildBoldCheckbox(),
        const SizedBox(height: 20),
        _buildTextColorPicker(),
      ],
    );
  }

  Widget _buildFontFamilyDropdown() {
    return AppDropdown<String>(
      label: 'Tip Font',
      items: [
        for (final font in eventFonts) AppDropdownItem<String>(value: font.family, label: font.family),
      ],
      value: controller.fontFamily,
      onChanged: (value) => setState(() => controller.fontFamily = value),
      validator: (value) => value == null ? 'Selectează tipul de font' : null,
      hint: 'Selectează tipul de font',
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
        if (controller.enableGlow && controller.inputType == 'Separated') ...[
          const SizedBox(height: 20),
          _buildGlowPlaceDropdown(),
        ],
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
            onChanged:
                (value) => setState(() => controller.enableGlow = value!),
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
      child: SizedBox(
        width: 270,
        child: AppButton(
          label: 'Salvează componenta',
          onPressed: () {
            controller.saveComponent(
              context: context,
              puzzle: widget.puzzle,
              component: widget.component,
              refreshUI: widget.refreshUI,
              isEditMode: widget.edit,
            );
          },
        ),
      ),
    );
  }
}
