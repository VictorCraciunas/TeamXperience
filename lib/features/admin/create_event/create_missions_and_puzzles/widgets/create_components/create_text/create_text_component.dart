import 'package:flutter/material.dart';
import 'package:teamxperience/utils/component_conversion/box_effects.dart';
import '../hex_color_field.dart';
import '../optional_slider.dart';
import '../option_checkbox.dart';
import 'package:teamxperience/utils/event_fonts.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/enums/animation_type.dart';
import 'package:teamxperience/ui/components/inputs/app_text_field.dart';
import 'package:teamxperience/ui/components/inputs/app_dropdown.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';
import 'package:teamxperience/ui/components/misc/color_picker_dialog.dart';
import 'package:teamxperience/ui/components/misc/slider_widget.dart';

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
  State<TextComponentFieldsWidget> createState() =>
      _TextComponentFieldsWidgetState();
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
        if (controller.animation == AnimationType.typewriter || controller.animation == AnimationType.decode) ...[
          const SizedBox(height: 16),
          _buildTypewriterSpeedSlider(),
        ],
        const SizedBox(height: 16),
        _buildFontFamilyDropdown(),
        const SizedBox(height: 16),
        _buildTextAlignDropdown(),
        const SizedBox(height: 16),
        _buildFontWeightDropdown(),
        const SizedBox(height: 16),
        _buildFontSizeSlider(),
        const SizedBox(height: 16),
        _buildTextColorPicker(),
        const SizedBox(height: 16),
        _buildLetterSpacingSlider(),
        const SizedBox(height: 16),
        _buildLineHeightSlider(),
        const SizedBox(height: 16),
        OptionCheckbox(
          label: 'Cursiv',
          value: controller.italic,
          onChanged: (value) => setState(() => controller.italic = value),
        ),
        const SizedBox(height: 16),
        OptionCheckbox(
          label: 'Majuscule',
          value: controller.uppercase,
          onChanged: (value) => setState(() => controller.uppercase = value),
        ),
        const SizedBox(height: 16),
        _buildGlowSection(),
        const SizedBox(height: 16),
        _buildShadowSection(),
        const SizedBox(height: 16),
        _buildSaveButton(),
        const SizedBox(height: 60),
      ],
    );
  }

  Widget _buildPreviewSection() {
    final previewComponent = Component();
    controller.updateComponentFields(previewComponent);
    BoxEffects.copy(widget.component, previewComponent, shadow: false);
    final previewWidget = ComponentToWidget().convert(previewComponent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Previzualizare',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.colors.panel,
            border: Border.all(color: context.colors.accent, width: 1.5),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(12),
          child: previewWidget,
        ),
      ],
    );
  }

  Widget _buildTextContentField() {
    return AppTextField(
      onChanged: (value) {
        setState(() {});
      },
      controller: controller.textController,
      label: 'Conținut Text',
      maxLines: null,
      validator:
          (value) =>
              value == null || value.isEmpty
                  ? 'Please enter text content'
                  : null,
    );
  }

  Widget _buildAnimationDropdown() {
    return AppDropdown<AnimationType>(
      label: 'Animație',
      items:
          AnimationType.values
              .map(
                (anim) => AppDropdownItem<AnimationType>(
                  value: anim,
                  label: anim.toString().split('.').last,
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
      hint: 'Selectează animația',
    );
  }

  Widget _buildTypewriterSpeedSlider() {
    return SliderWidget(
      title: 'Viteză Typewriter (ms/caracter)',
      min: 10,
      max: 300,
      divisions: 29,
      value: controller.typewriterSpeed.toDouble(),
      label: '${controller.typewriterSpeed} ms',
      onChanged: (value) {
        setState(() {
          controller.typewriterSpeed = value.toInt();
        });
      },
    );
  }

  Widget _buildFontFamilyDropdown() {
    return AppDropdown<String>(
      label: 'Tip Font',
      items: [
        for (final font in eventFonts) AppDropdownItem<String>(value: font.family, label: font.family),
      ],
      value: controller.fontFamily,
      onChanged: (value) {
        setState(() {
          controller.fontFamily = value;
        });
      },
      validator: (value) => value == null ? 'Selectează tipul de font' : null,
      hint: 'Selectează tipul de font',
    );
  }

  Widget _buildFontWeightDropdown() {
    return AppDropdown<String>(
      label: 'Grosime Font',
      items:
          weightMap.keys
              .map(
                (label) => AppDropdownItem<String>(value: label, label: label),
              )
              .toList(),
      value: controller.fontWeight,
      onChanged: (value) {
        setState(() {
          controller.fontWeight = value;
        });
      },
      validator:
          (value) => value == null ? 'Selectează grosimea fontului' : null,
      hint: 'Selectează grosimea fontului',
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

  Widget _buildLetterSpacingSlider() {
    return SliderWidget(
      title: 'Spațiu între litere',
      min: 0,
      max: 12,
      divisions: 12,
      value: controller.letterSpacing,
      label: controller.letterSpacing.toStringAsFixed(0),
      onChanged: (value) => setState(() => controller.letterSpacing = value),
    );
  }

  Widget _buildLineHeightSlider() {
    return OptionalSlider(
      title: 'Înălțime rând',
      min: 0.8,
      max: 2,
      divisions: 12,
      unit: '×',
      decimals: 1,
      value: controller.lineHeight,
      automaticValue: 1.2,
      automaticNote: 'automat',
      onChanged: (value) => setState(() => controller.lineHeight = value),
    );
  }

  Widget _buildGlowSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptionCheckbox(
          label: 'Glow text',
          value: controller.enableGlow,
          onChanged: (value) {
            setState(() {
              controller.enableGlow = value;
              // A glow starts in the colour of the text.
              if (value) controller.glowColor = controller.textColor;
            });
          },
        ),
        if (controller.enableGlow) ...[
          const SizedBox(height: 16),
          HexColorField(
            label: 'Culoare glow',
            hex: controller.glowColor,
            onChanged: (color) => setState(() => controller.glowColor = color),
          ),
        ],
      ],
    );
  }

  Widget _buildShadowSection() {
    final hasShadow = controller.shadowBlur > 0 || controller.shadowDistance > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SliderWidget(
          title: 'Încețoșare umbră',
          min: 0,
          max: 30,
          divisions: 30,
          value: controller.shadowBlur,
          label: controller.shadowBlur.toStringAsFixed(0),
          onChanged: (value) => setState(() => controller.shadowBlur = value),
        ),
        const SizedBox(height: 16),
        SliderWidget(
          title: 'Distanță umbră',
          min: 0,
          max: 20,
          divisions: 20,
          value: controller.shadowDistance,
          label: controller.shadowDistance.toStringAsFixed(0),
          onChanged: (value) => setState(() => controller.shadowDistance = value),
        ),
        if (hasShadow) ...[
          const SizedBox(height: 16),
          HexColorField(
            label: 'Culoare umbră',
            hex: controller.shadowColor,
            onChanged: (color) => setState(() => controller.shadowColor = color),
          ),
        ],
      ],
    );
  }

  Widget _buildTextColorPicker() {
    return AppTextField(
      controller: controller.textColorController,
      hint: 'Culoare Text',
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
          border: Border.all(color: context.colors.border),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      validator: requiredValidator('a value'),
    );
  }

  Widget _buildTextAlignDropdown() {
    return AppDropdown<String>(
      label: 'Aliniere Text',
      items: const [
        AppDropdownItem<String>(value: 'left', label: 'Stânga'),
        AppDropdownItem<String>(value: 'center', label: 'Centrat'),
        AppDropdownItem<String>(value: 'right', label: 'Dreapta'),
        AppDropdownItem<String>(value: 'justify', label: 'Justify'),
      ],
      value: controller.textAlign,
      onChanged: (value) {
        setState(() {
          controller.textAlign = value ?? 'center';
        });
      },
      hint: 'Selectează alinierea',
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
