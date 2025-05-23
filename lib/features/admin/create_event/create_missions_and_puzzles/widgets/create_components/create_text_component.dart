import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:teamxperience/enums/animation_type.dart';
import 'package:teamxperience/model/component.dart';

import '../../../../../../enums/component-type.dart';
import '../../../../../../utils/component_conversion/component_to_widget.dart';
import '../../controller/add_missions_controller.dart';

class TextComponentFieldsWidget extends StatefulWidget {
  final TextEditingController textController;
  final String? textColor;
  final AnimationType? animation;
  final double? fontSize;
  final String? fontWeight;
  final AddMissionsController addMissionsController;
  final int missionSelected;
  final int puzzleSelected;
  final Function(Widget) refreshUI;

  const TextComponentFieldsWidget({
    super.key,
    required this.textController,
    this.textColor,
    this.animation,
    this.fontSize,
    this.fontWeight,
    required this.addMissionsController,
    required this.missionSelected,
    required this.puzzleSelected,
    required this.refreshUI,
  });

  @override
  State<TextComponentFieldsWidget> createState() => _TextComponentFieldsWidgetState();
}

class _TextComponentFieldsWidgetState extends State<TextComponentFieldsWidget> {
  late String textColor;
  late AnimationType? animation;
  late double fontSize;
  late String fontWeight;

  @override
  void initState() {
    super.initState();
    textColor = widget.textColor ?? '#000000';
    animation = widget.animation ?? AnimationType.none;
    fontSize = widget.fontSize ?? 16.0;
    final weightMap = <String, FontWeight>{
      'Thin (100)': FontWeight.w100,
      'Light (300)': FontWeight.w300,
      'Regular (400)': FontWeight.w400,
      'Medium (500)': FontWeight.w500,
      'Bold (700)': FontWeight.w700,
      'Black (900)': FontWeight.w900,
    };
    fontWeight = widget.fontWeight ?? 'Regular (400)';
    if (!weightMap.containsKey(fontWeight)) {
      fontWeight = 'Regular (400)';
    }
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
    Component component = widget.addMissionsController.addComponent(
      widget.missionSelected,
      widget.puzzleSelected,
      ComponentType.text,
      text: widget.textController.text,
      textColor: textColor,
      animation: animation,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
    Widget componentWidget = componentToWidget.convert(component); // Assuming ComponentToWidget is accessible
    widget.refreshUI(componentWidget);
    Navigator.pop(context); // Close the widget or screen
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
    final currentWeight = weightMap[fontWeight] ?? FontWeight.w400;

    return Column(
      children: [
        const SizedBox(height: 12),

        // ───── Preview ─────
        const Text('Preview', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            widget.textController.text.isEmpty ? 'Your text here' : widget.textController.text,
            style: TextStyle(
              color: currentColor,
              fontSize: currentSize,
              fontWeight: currentWeight,
            ),
          ),
        ),
        const Divider(height: 32),

        // ───── Text Content ─────
        TextField(
          controller: widget.textController,
          decoration: const InputDecoration(labelText: 'Text Content'),
          onChanged: (value) {
            setState(() {});
          },
        ),
        const SizedBox(height: 10),

        // ───── Color Picker ─────
        ListTile(
          title: const Text('Text Color'),
          trailing: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: currentColor,
              border: Border.all(color: Colors.grey),
            ),
          ),
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
        ),
        const SizedBox(height: 10),

        // ───── Animation Picker ─────
        DropdownButtonFormField<AnimationType>(
          decoration: const InputDecoration(labelText: 'Animation'),
          value: animation,
          items: AnimationType.values
              .map((anim) => DropdownMenuItem(
            value: anim,
            child: Text(anim.toString().split('.').last),
          ))
              .toList(),
          onChanged: (value) {
            setState(() {
              animation = value;
            });
          },
        ),
        const SizedBox(height: 10),

        // ───── Font Size Slider ─────
        Slider(
          min: 8,
          max: 72,
          divisions: 64,
          value: currentSize,
          label: currentSize.toStringAsFixed(0),
          onChanged: (value) {
            setState(() {
              fontSize = value;
            });
          },
        ),
        const SizedBox(height: 10),

        // ───── Font Weight Dropdown ─────
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Font Weight'),
          value: fontWeight,
          items: weightMap.keys.map((label) {
            return DropdownMenuItem(value: label, child: Text(label));
          }).toList(),
          onChanged: (value) {
            setState(() {
              fontWeight = value ?? 'Regular (400)';
            });
          },
        ),
        const SizedBox(height: 20),

        // ───── Save Button ─────
        ElevatedButton(
          onPressed: _saveComponent,
          child: const Text('Save Component'),
        ),
      ],
    );
  }
}