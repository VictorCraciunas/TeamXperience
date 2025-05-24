import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/utils/component_conversion/component_to_widget.dart';
import 'package:teamxperience/widgets/my_button.dart';
import 'package:teamxperience/widgets/my_text_field.dart';
import '../../../../../../widgets/my_dropdown.dart';
import '../../controller/add_missions_controller.dart';

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
  bool _isTapped = false;
  late String buttonColor;
  late String buttonColorOnTap;
  late String buttonTextColor;
  late String buttonTextColorOnTap;
  late String borderColor;
  late String glowColor;

  TextEditingController labelController = TextEditingController();
  late String? fontWeight;
  late String? fontFamily;

  late double cornerRadius;
  bool enableFlicker = false;
  bool enableGlow = false;




  @override
  void initState() {
    super.initState();
    buttonColor ='#FFFFFF'; // Default white
    buttonColorOnTap ='#CCCCCC'; // Default gray
    buttonTextColor ='#000000'; // Default black
    buttonTextColorOnTap ='#FFFFFF'; // Default white
    borderColor ='#000000'; // Default black
    glowColor ='#000000';
    fontWeight = null; // Set to null to show hint
    fontFamily = null;
    cornerRadius = 15.0;
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

  void _saveComponent() {
    if (labelController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a button label')),
      );
      return;
    }

    Component component = widget.addMissionsController.addComponent(
      widget.missionSelected,
      widget.puzzleSelected,
      ComponentType.button,
      buttonLabel: labelController.text,
      buttonColor: buttonColor,
      buttonColorOnTap: buttonColorOnTap,
      buttonTextColor: buttonTextColor,
      buttonTextColorOnTap: buttonTextColorOnTap,
      borderColor: borderColor,
      fontWeight: fontWeight,
      fontFamily: fontFamily,
      cornerRadius: cornerRadius, // New
      enableFlicker: enableFlicker, // New
      enableGlow: enableGlow, // New
      glowColor: glowColor, // New
    );
    Widget componentWidget = ComponentToWidget().convert(component);
    widget.refreshUI(componentWidget);
    Navigator.pop(context);
  }

  TextEditingController controller = TextEditingController();
  Widget _buildColorPickerField(String title, String colorHex, Function(String) onColorChanged) {
    Color currentColor = _hexToColor(colorHex);
    return MyTextField(
      controller: controller,
      hintText: title,
      borderColor: MyColors.lightBlue,
      radius: 15,
      readOnly: true,
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            Color dialogColor = currentColor;
            TextEditingController rController = TextEditingController(text: (dialogColor.r * 255).toInt().toString());
            TextEditingController gController = TextEditingController(text: (dialogColor.g * 255).toInt().toString());
            TextEditingController bController = TextEditingController(text: (dialogColor.b * 255).toInt().toString());
            TextEditingController aController = TextEditingController(text: (dialogColor.a * 255).toInt().toString());
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Alege Culoarea'),
              content: StatefulBuilder(
                builder: (context, setState) {
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ColorPicker(
                          labelTypes: const [],
                          pickerColor: dialogColor,
                          onColorChanged: (color) {
                            setState(() {
                              dialogColor = color;
                              // Update text fields with raw values (0-255)
                              rController.text = (color.r * 255).toInt().toString();
                              gController.text = (color.g * 255).toInt().toString();
                              bController.text = (color.b * 255).toInt().toString();
                              aController.text = (color.a * 255).toInt().toString();
                            });
                          },
                          enableAlpha: true,
                        ),
                        Row(
                          children: [
                            Expanded(child: _buildInputField('R', rController)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildInputField('G', gController)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildInputField('B', bController)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildInputField('A', aController)),
                          ],
                        ),
                      ],
                    ),

                  );
                },

              ),
              actions:  [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    try {
                      int r = int.parse(rController.text);
                      int g = int.parse(gController.text);
                      int b = int.parse(bController.text);
                      int a = int.parse(aController.text);
                      if (r >= 0 && r <= 255 &&
                          g >= 0 && g <= 255 &&
                          b >= 0 && b <= 255 &&
                          a >= 0 && a <= 255) {
                        setState(() {
                          dialogColor = Color.fromRGBO(r, g, b, a / 255.0);
                          onColorChanged(_colorToHex(dialogColor));
                        });
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Values out of range')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid input')),
                      );
                    }
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
      trailing: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          color: currentColor,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }

// Helper method to build styled input fields
  Widget _buildInputField(String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(hint,style: const TextStyle(fontSize: 20, color:MyColors.blackColor),),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: MyColors.lightBlue, width: 1.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: InputBorder.none,
            ),
            keyboardType: hint.contains('A') ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.number,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _hexToColor(buttonColor, defaultColor: Colors.white);
    final bgOnTap = _hexToColor(buttonColorOnTap, defaultColor: Colors.grey);
    final textColor = _hexToColor(buttonTextColor, defaultColor: Colors.black);
    final textOnTap = _hexToColor(buttonTextColorOnTap, defaultColor: Colors.white);
    final borderClr = _hexToColor(borderColor, defaultColor: Colors.black);
    final glowClr = _hexToColor(glowColor, defaultColor: Colors.black);
    final weightMap = <String, FontWeight>{
      'Thin (100)': FontWeight.w100,
      'Light (300)': FontWeight.w300,
      'Regular (400)': FontWeight.w400,
      'Medium (500)': FontWeight.w500,
      'Bold (700)': FontWeight.w700,
      'Black (900)': FontWeight.w900,
    };
    final currentWeight = fontWeight != null ? weightMap[fontWeight] ?? FontWeight.w400 : FontWeight.w400;
    final currentFontFamily = fontFamily ?? 'Poppins';

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
              onPointerDown: (_) => setState(() => _isTapped = true),
              onPointerUp: (_) => setState(() => _isTapped = false),
              onPointerCancel: (_) => setState(() => _isTapped = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: _isTapped ? bgOnTap : bgColor,
                  border: Border.all(color: borderClr, width: 1.5),
                  borderRadius: BorderRadius.circular(cornerRadius),
                  boxShadow: enableGlow
                      ? [
                    BoxShadow(
                      color: glowClr.withValues(alpha: 0.6), // Glow color with some transparency
                      blurRadius: 10.0, // Spread of the glow
                      spreadRadius: 2.0, // Size of the glow
                      offset: const Offset(0, 0), // Centered glow
                    ),
                  ]
                      : null,
                ),
                child: Text(
                  labelController.text.isEmpty
                      ? 'Button Label'
                      : labelController.text,
                  style: TextStyle(
                    color: _isTapped ? textOnTap : textColor,
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
          controller: labelController,
          labelText: 'Button Label',
          borderColor: MyColors.lightBlue,
          borderWidth: 1.5,
          radius: 20,
          validator: (value) =>
          value == null || value.isEmpty ? 'Please enter a button label' : null,
        ),

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
          value: fontFamily,
          onChanged: (value) {
            setState(() {
              fontFamily = value;
            });
          },
          validator: (value) => value == null ? 'Selecteaza tipul de font' : null,
          borderColor: MyColors.lightBlue,
          borderWidth: 1.5,
          radius: 20,
          selectedItemStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Colors.black,
          ),
          hint: const Text(
            'Selecteaza tipul de font',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: MyColors.greyText,
            ),
          ),
        ),
        const SizedBox(height: 16),

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
          value: fontWeight,
          onChanged: (value) {
            setState(() {
              fontWeight = value;
            });
          },
          validator: (value) => value == null ? 'Selecteaza grosimea fontului' : null,
          borderColor: MyColors.lightBlue,
          borderWidth: 1.5,
          radius: 20,
          selectedItemStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Colors.black,
          ),
          hint: const Text(
            'Selecteaza grosimea fontului',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: MyColors.greyText,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Color Pickers
        _buildColorPickerField('Button Color', buttonColor, (color) => buttonColor = color),
        const SizedBox(height: 16),
        _buildColorPickerField('Button Color (On Tap)', buttonColorOnTap,
                (color) => buttonColorOnTap = color),
        const SizedBox(height: 16),
        _buildColorPickerField('Text Color', buttonTextColor, (color) => buttonTextColor = color),
        const SizedBox(height: 16),
        _buildColorPickerField('Text Color (On Tap)', buttonTextColorOnTap,
                (color) => buttonTextColorOnTap = color),
        const SizedBox(height: 16),
        _buildColorPickerField('Border Color', borderColor, (color) => borderColor = color),
        const SizedBox(height: 16),

        // ───── Corner Radius Slider ─────
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Colțuri Rotunjite',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: MyColors.lightBlue, width: 1.5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Slider(
                min: 0,
                max: 50,
                divisions: 50,
                value: cornerRadius,
                label: cornerRadius.toStringAsFixed(0),
                activeColor: MyColors.lightBlue,
                inactiveColor: MyColors.greyText.withValues(alpha: 0.3),
                onChanged: (value) {
                  setState(() {
                    cornerRadius = value;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ───── Flicker Animation Checkbox ─────
        Row(
          children: [
            Transform.scale(
              scale: 1.5,
              child: Checkbox(
                value: enableFlicker,
                activeColor: MyColors.lightBlue,
                onChanged: (value) {
                  setState(() {
                    enableFlicker = value ?? false;
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6), // corner radius
                ),
                // controls the unchecked/check border width & color
                side: const BorderSide(
                  width: 1.5,                    // border thickness
                  color: MyColors.lightBlue,   // border color
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Flicker Animation',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ───── Glow Button Checkbox ─────
        Row(
          children: [
            Transform.scale(
              // adjust this scale factor to grow/shrink the box
              scale: 1.5,
              child: Checkbox(
                value: enableGlow,
                onChanged: (v) => setState(() => enableGlow = v!),
                activeColor: MyColors.lightBlue,
                checkColor: Colors.white,
                // gives you a rounded rectangle outline instead of the default square
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6), // corner radius
                ),
                // controls the unchecked/check border width & color
                side: const BorderSide(
                  width: 1.5,                    // border thickness
                  color: MyColors.lightBlue,   // border color
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Glow Button',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildColorPickerField('Culoare Glow', glowColor, (color) => glowColor = color),
        const SizedBox(height: 20),

        // Save Button
        Center(
          child: MyButton(
            buttonText: 'Salveaza componenta',
            textColor: Colors.white,
            buttonOnTap: _saveComponent,
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