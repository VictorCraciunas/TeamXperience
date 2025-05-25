import 'package:flutter/material.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/widgets/my_button.dart';
import 'package:teamxperience/widgets/my_dropdown.dart';
import '../../../controller/add_missions_controller.dart';
import 'code_component_controller.dart'; // Import the controller
import '../../../../../../../widgets/slider_widget.dart'; // Import the slider widget

class CodeComponentFieldsWidget extends StatefulWidget {
  final AddMissionsController addMissionsController;
  final int missionSelected;
  final int puzzleSelected;
  final Function(Widget) refreshUI;

  const CodeComponentFieldsWidget({
    super.key,
    required this.addMissionsController,
    required this.missionSelected,
    required this.puzzleSelected,
    required this.refreshUI,
  });

  @override
  State<CodeComponentFieldsWidget> createState() => _CodeComponentFieldsWidgetState();
}

class _CodeComponentFieldsWidgetState extends State<CodeComponentFieldsWidget> {
  late CodeComponentController controller;

  @override
  void initState() {
    super.initState();
    // Initialize the controller to manage state and logic
    controller = CodeComponentController();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // **Title for the preview section**
          // Displays "Previzualizare" with a font size of 15
           const Text(
            'Previzualizare',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: MyColors.blackColor
            ),
          ),
          const SizedBox(height: 15),
          // **Preview widget**
          // Shows the code input preview based on selected options or a placeholder text
          Center(
            child: controller.codeLength != null && controller.inputType != null
                ? controller.buildCodePreview(context)
                : const Text('Select number of characters and input type to preview'),
          ),
          const SizedBox(height: 30),
          // **Dropdown for number of characters**
          // Allows selecting a number from 1 to 10
          MyDropdownField<int>(
            labelText: 'Număr de caractere',
            items: List.generate(10, (index) => index + 1)
                .map((length) => DropdownMenuItem(value: length, child: Text('$length')))
                .toList(),
            value: controller.codeLength,
            onChanged: (value) => setState(() => controller.codeLength = value),
            borderColor: MyColors.lightBlue,
            borderWidth: 1.5,
            radius: 20,
            hint: const Text('Selecteaza numărul de caractere'),
          ),
          const SizedBox(height: 20),
          // **Dropdown for input type**
          // Options: "Separated" or "Free"
          MyDropdownField<String>(
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
          ),
          const SizedBox(height: 20),
          // **Dropdown for CapsLock behavior**
          // Options: "CapsLock" or "Fără"
          MyDropdownField<String>(
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
          ),
          const SizedBox(height: 20),
          // **Slider for frame corner radius**
          // Adjusts the corner radius of the frame (0-50)
          SliderWidget(
            title: 'Rotunjire chenar',
            min: 0,
            max: 50,
            divisions: 50,
            value: controller.radiusChenar,
            label: controller.radiusChenar.toStringAsFixed(0),
            onChanged: (value) => setState(() => controller.radiusChenar = value),
          ),
          const SizedBox(height: 20),
          // **Slider for input field width**
          // Adjusts the width of input fields (0-200)
          SliderWidget(
            title: 'Lungime inputuri',
            min: 0,
            max: 200,
            divisions: 200,
            value: controller.widthInput,
            label: controller.widthInput.toStringAsFixed(0),
            onChanged: (value) => setState(() => controller.widthInput = value),
          ),
          const SizedBox(height: 20),
          // **Slider for input field corner radius**
          // Adjusts the corner radius of input fields (0-50)
          SliderWidget(
            title: 'Rotunjire chenar inputuri',
            min: 0,
            max: 50,
            divisions: 50,
            value: controller.radiusChenarInputuri,
            label: controller.radiusChenarInputuri.toStringAsFixed(0),
            onChanged: (value) => setState(() => controller.radiusChenarInputuri = value),
          ),
          const SizedBox(height: 20),
          // **Color picker for frame background**
          // Sets the background color of the frame
          controller.buildColorPickerField(
            'Culoare fundal chenar',
            controller.frameBackgroundColor,
                (color) => setState(() => controller.frameBackgroundColor = color),
            context,
          ),
          const SizedBox(height: 20),
          // **Color picker for input background**
          // Sets the background color of the input fields
          controller.buildColorPickerField(
            'Culoare fundal input-uri',
            controller.inputBackgroundColor,
                (color) => setState(() => controller.inputBackgroundColor = color),
            context,
          ),
          const SizedBox(height: 20),
          // **Color picker for input border**
          // Sets the border color of the input fields
          controller.buildColorPickerField(
            'Culoare bordura input',
            controller.colorBorderInput,
                (color) => setState(() => controller.colorBorderInput = color),
            context,
          ),
          const SizedBox(height: 20),
          // **Color picker for frame border**
          // Sets the border color of the frame
          controller.buildColorPickerField(
            'Culoare bordura chenar',
            controller.colorBorderContainer,
                (color) => setState(() => controller.colorBorderContainer = color),
            context,
          ),
          const SizedBox(height: 20),
          // **Dropdown for font family**
          // Options: "Poppins" or "Monospace", font size 14 for items
          MyDropdownField<String>(
            labelText: 'Tip Font',
            items: const [
              DropdownMenuItem(
                value: 'Poppins',
                child: Text('Poppins', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.black)),
              ),
              DropdownMenuItem(
                value: 'Monospace',
                child: Text('Monospace', style: TextStyle(fontFamily: 'Monospace', fontSize: 14, color: Colors.black)),
              ),
            ],
            value: controller.fontFamily,
            onChanged: (value) => setState(() => controller.fontFamily = value),
            validator: (value) => value == null ? 'Selecteaza tipul de font' : null,
            borderColor: MyColors.lightBlue,
            borderWidth: 1.5,
            radius: 20,
            selectedItemStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.black),
            hint: const Text('Selecteaza tipul de font',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: MyColors.greyText)),
          ),
          const SizedBox(height: 20),
          // **Slider for font size**
          // Adjusts the text size (8-72), default is 16
          SliderWidget(
            title: 'Dimensiune Text',
            min: 8,
            max: 72,
            divisions: 64,
            value: controller.fontSize,
            label: controller.fontSize.toStringAsFixed(0),
            onChanged: (value) => setState(() => controller.fontSize = value),
          ),
          const SizedBox(height: 20),
          // **Color picker for input text**
          // Sets the text color in the input fields
          controller.buildColorPickerField(
            'Culoare text input',
            controller.textColor,
                (color) => setState(() => controller.textColor = color),
            context,
          ),
          const SizedBox(height: 20),
          // **Checkbox for glow effect**
          // Enables/disables the glow effect on the frame
          Row(
            children: [
              Transform.scale(
                scale: 1.5,
                child: Checkbox(
                  value: controller.enableGlow,
                  onChanged: (v) => setState(() => controller.enableGlow = v!),
                  activeColor: MyColors.lightBlue,
                  checkColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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
          ),
          const SizedBox(height: 20),
          // **Color picker for glow color**
          // Sets the color of the glow effect
          controller.buildColorPickerField(
            'Culoare Glow',
            controller.glowColor,
                (color) => setState(() => controller.glowColor = color),
            context,
          ),
          const SizedBox(height: 20),

          // **Save button**
          // Saves the component with all selected options
          Center(
            child: MyButton(
              buttonText: 'Salvează componenta',
              textColor: Colors.white,
              buttonOnTap: () => controller.saveComponent(context, widget.missionSelected, widget.puzzleSelected, widget.addMissionsController, widget.refreshUI),
              withBorder: false,
              buttonColor: MyColors.lightBlue,
              fontWeight: FontWeight.w500,
              buttonTextSize: 14,
              buttonWidth: 270,
            ),
          ),
        ],
      ),
    );
  }
}