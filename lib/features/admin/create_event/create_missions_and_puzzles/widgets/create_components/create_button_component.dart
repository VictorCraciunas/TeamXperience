import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ButtonComponentFieldsWidget extends StatefulWidget {
  final TextEditingController buttonLabelController;
  final ValueChanged<String?> onButtonLabelChanged;
  final String? buttonColor;
  final String? buttonColorOnTap;
  final String? buttonTextColor;
  final String? buttonTextColorOnTap;
  final String? borderColor;
  final ValueChanged<String?> onButtonColorChanged;
  final ValueChanged<String?> onButtonColorOnTapChanged;
  final ValueChanged<String?> onButtonTextColorChanged;
  final ValueChanged<String?> onButtonTextColorOnTapChanged;
  final ValueChanged<String?> onBorderColorChanged;

  const ButtonComponentFieldsWidget({
    super.key,
    required this.buttonLabelController,
    required this.onButtonLabelChanged,
    this.buttonColor,
    this.buttonColorOnTap,
    this.buttonTextColor,
    this.buttonTextColorOnTap,
    this.borderColor,
    required this.onButtonColorChanged,
    required this.onButtonColorOnTapChanged,
    required this.onButtonTextColorChanged,
    required this.onButtonTextColorOnTapChanged,
    required this.onBorderColorChanged,
  });

  @override
  ButtonComponentFieldsWidgetState createState() => ButtonComponentFieldsWidgetState();
}

class ButtonComponentFieldsWidgetState extends State<ButtonComponentFieldsWidget> {
  bool _isTapped = false;

  // Hex <-> Color Helpers
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

  // Helper to convert Color to hex string
  String _colorToHex(Color color) {
    final argb = color.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#$argb';
  }

  // Builds a ListTile with ColorPicker dialog
  Widget _buildColorPicker({
    required String title,
    required Color currentColor,
    required ValueChanged<String?> onColorChanged,
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
                    onColorChanged(_colorToHex(tempColor));
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

  @override
  Widget build(BuildContext context) {
    final bgColor = _hexToColor(widget.buttonColor, defaultColor: Colors.white);
    final bgOnTap = _hexToColor(widget.buttonColorOnTap, defaultColor: Colors.grey);
    final textColor = _hexToColor(widget.buttonTextColor, defaultColor: Colors.black);
    final textOnTap = _hexToColor(widget.buttonTextColorOnTap, defaultColor: Colors.white);
    final borderClr = _hexToColor(widget.borderColor, defaultColor: Colors.black);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Preview', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        // ------------ preview -------------
        Listener(
          behavior: HitTestBehavior.opaque,  // ensures even transparent areas catch the touch
          onPointerDown: (_)  => setState(() => _isTapped = true),
          onPointerUp:   (_)  => setState(() => _isTapped = false),
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
          onChanged: widget.onButtonLabelChanged,
        ),
        const SizedBox(height: 16),
        _buildColorPicker(
          title: 'Button Color',
          currentColor: bgColor,
          onColorChanged: widget.onButtonColorChanged,
        ),
        _buildColorPicker(
          title: 'Button Color (On Tap)',
          currentColor: bgOnTap,
          onColorChanged: widget.onButtonColorOnTapChanged,
        ),
        _buildColorPicker(
          title: 'Text Color',
          currentColor: textColor,
          onColorChanged: widget.onButtonTextColorChanged,
        ),
        _buildColorPicker(
          title: 'Text Color (On Tap)',
          currentColor: textOnTap,
          onColorChanged: widget.onButtonTextColorOnTapChanged,
        ),
        _buildColorPicker(
          title: 'Border Color',
          currentColor: borderClr,
          onColorChanged: widget.onBorderColorChanged,
        ),
      ],
    );
  }
}
