import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/utils/component_conversion/component_to_widget.dart';
import '../../../../../../model/component.dart';
import '../../controller/add_missions_controller.dart';

class ButtonComponentFieldsWidget extends StatefulWidget {
  final TextEditingController buttonLabelController;
  final String? buttonColor;
  final String? buttonColorOnTap;
  final String? buttonTextColor;
  final String? buttonTextColorOnTap;
  final String? borderColor;
  final AddMissionsController addMissionsController;
  final int missionSelected;
  final int puzzleSelected;
  final Function(Widget) refreshUI;

  const ButtonComponentFieldsWidget({
    super.key,
    required this.buttonLabelController,
    this.buttonColor,
    this.buttonColorOnTap,
    this.buttonTextColor,
    this.buttonTextColorOnTap,
    this.borderColor,
    required this.addMissionsController,
    required this.missionSelected,
    required this.puzzleSelected,
    required this.refreshUI,
  });

  @override
  ButtonComponentFieldsWidgetState createState() => ButtonComponentFieldsWidgetState();
}

class ButtonComponentFieldsWidgetState extends State<ButtonComponentFieldsWidget> {
  bool _isTapped = false;
  late String buttonColor;
  late String buttonColorOnTap;
  late String buttonTextColor;
  late String buttonTextColorOnTap;
  late String borderColor;

  @override
  void initState() {
    super.initState();
    buttonColor = widget.buttonColor ?? '#FFFFFF';
    buttonColorOnTap = widget.buttonColorOnTap ?? '#CCCCCC';
    buttonTextColor = widget.buttonTextColor ?? '#000000';
    buttonTextColorOnTap = widget.buttonTextColorOnTap ?? '#FFFFFF';
    borderColor = widget.borderColor ?? '#000000';
  }

  Color _hexToColor(String? hex, {Color defaultColor = Colors.black}) {
    if (hex == null || hex.isEmpty) return defaultColor;
    final hexColor = hex.replaceFirst('#', '');
    if (hexColor.length == 6) {
      return Color(int.parse('FF$hexColor', radix: 16)); // Full opacity
    } else if (hexColor.length == 8) {
      return Color(int.parse(hexColor, radix: 16)); // With alpha
    } else {
      return defaultColor;
    }
  }

  String _colorToHex(Color color) {
    final argb = color.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#$argb';
  }

  Widget _buildColorPicker({
    required String title,
    required Color currentColor,
    required ValueChanged<Color> onColorChanged,
  }) {
    return ListTile(
      title: Text(title),
      trailing: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: currentColor,
          border: Border.all(color: Colors.grey),
        ),
      ),
      onTap: () => showDialog(
        context: context,
        builder: (context) {
          Color tempColor = currentColor;
          return AlertDialog(
            title: Text('Pick a $title'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: tempColor,
                onColorChanged: (color) => setState(() => tempColor = color),
                enableAlpha: true,
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
                    if (title == 'Button Color') buttonColor = _colorToHex(tempColor);
                    if (title == 'Button Color (On Tap)') buttonColorOnTap = _colorToHex(tempColor);
                    if (title == 'Text Color') buttonTextColor = _colorToHex(tempColor);
                    if (title == 'Text Color (On Tap)') buttonTextColorOnTap = _colorToHex(tempColor);
                    if (title == 'Border Color') borderColor = _colorToHex(tempColor);
                  });
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _saveComponent() {
    if (widget.buttonLabelController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a button label')),
      );
      return;
    }

    Component component = widget.addMissionsController.addComponent(
      widget.missionSelected,
      widget.puzzleSelected,
      ComponentType.button,
      buttonLabel: widget.buttonLabelController.text,
      buttonColor: buttonColor,
      buttonColorOnTap: buttonColorOnTap,
      buttonTextColor: buttonTextColor,
      buttonTextColorOnTap: buttonTextColorOnTap,
      borderColor: borderColor,
    );
    Widget componentWidget = ComponentToWidget().convert(component);
    widget.refreshUI(componentWidget);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _hexToColor(buttonColor, defaultColor: Colors.white);
    final bgOnTap = _hexToColor(buttonColorOnTap, defaultColor: Colors.grey);
    final textColor = _hexToColor(buttonTextColor, defaultColor: Colors.black);
    final textOnTap = _hexToColor(buttonTextColorOnTap, defaultColor: Colors.white);
    final borderClr = _hexToColor(borderColor, defaultColor: Colors.black);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Preview', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        // ------------ preview -------------
        Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (_) => setState(() => _isTapped = true),
          onPointerUp: (_) => setState(() => _isTapped = false),
          onPointerCancel: (_) => setState(() => _isTapped = false),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: _isTapped ? bgOnTap : bgColor,
              border: Border.all(color: borderClr, width: 3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.buttonLabelController.text,
              style: TextStyle(
                color: _isTapped ? textOnTap : textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        const Divider(height: 32),
        TextField(
          controller: widget.buttonLabelController,
          decoration: const InputDecoration(labelText: 'Button Label'),
          onChanged: (value) => setState(() {}), // Trigger rebuild for preview
        ),
        const SizedBox(height: 16),
        _buildColorPicker(
          title: 'Button Color',
          currentColor: bgColor,
          onColorChanged: (color) => setState(() => buttonColor = _colorToHex(color)),
        ),
        _buildColorPicker(
          title: 'Button Color (On Tap)',
          currentColor: bgOnTap,
          onColorChanged: (color) => setState(() => buttonColorOnTap = _colorToHex(color)),
        ),
        _buildColorPicker(
          title: 'Text Color',
          currentColor: textColor,
          onColorChanged: (color) => setState(() => buttonTextColor = _colorToHex(color)),
        ),
        _buildColorPicker(
          title: 'Text Color (On Tap)',
          currentColor: textOnTap,
          onColorChanged: (color) => setState(() => buttonTextColorOnTap = _colorToHex(color)),
        ),
        _buildColorPicker(
          title: 'Border Color',
          currentColor: borderClr,
          onColorChanged: (color) => setState(() => borderColor = _colorToHex(color)),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _saveComponent,
          child: const Text('Save Component'),
        ),
      ],
    );
  }
}