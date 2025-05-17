import 'package:flutter/material.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/utils/component_conversion/component_to_widget.dart';

import '../../../../../enums/animation_type.dart';
import '../../../../../model/component.dart';
import '../controller/add_missions_controller.dart';
import 'create_components/create_button_component.dart';
import 'create_components/create_code_component.dart';
import 'create_components/create_image_component.dart';
import 'create_components/create_text_component.dart';

class AddComponentWidget extends StatefulWidget {
  final AddMissionsController addMissionsController;
  final int missionSelected;
  final int puzzleSelected;
  final Function(Widget) refreshUI; // callback to notify parent

  const AddComponentWidget({
    super.key,
    required this.addMissionsController,
    required this.missionSelected,
    required this.puzzleSelected,
    required this.refreshUI,
  });

  @override
  State<AddComponentWidget> createState() => _AddComponentWidgetState();
}

class _AddComponentWidgetState extends State<AddComponentWidget> {

  ComponentType? type;
  ComponentToWidget componentToWidget = ComponentToWidget();
  TextEditingController textEditingController = TextEditingController();
  String? text;
  String? textColor = '#000000'; // Default to black
  AnimationType? animation = AnimationType.none; // Default to no animation
  double? fontSize;
  String? fontWeight = 'normal'; // Default to normal
  String? buttonColor = '#FFFFFF'; // Default to white
  String? buttonColorOnTap = '#CCCCCC'; // Default to grey
  String? buttonTextColor = '#000000'; // Default to black
  String? buttonTextColorOnTap = '#FFFFFF'; // Default to white
  String? borderColor = '#000000'; // New: Default to black
  int? codeLength; // New: Store the number of letters for code component

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text("Add Components"),
          DropdownButtonFormField<ComponentType>(
            decoration: const InputDecoration(labelText: 'Component Type'),
            value: type,
            items:
                ComponentType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.toString().split('.').last),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              setState(() {
                type = value;
                textEditingController.clear();
                text = null;
                textColor = '#000000';
                animation = AnimationType.none;
                fontSize = null;
                fontWeight = 'normal';
                buttonColor = '#FFFFFF';
                buttonColorOnTap = '#CCCCCC';
                buttonTextColor = '#000000';
                buttonTextColorOnTap = '#FFFFFF';
                borderColor = '#000000';
                codeLength = null;
              });
            },
            validator:
                (value) =>
                    value == null ? 'Please select a component type' : null,
          ),
          if (type == ComponentType.text) ...[
            TextComponentFieldsWidget(
              textController: textEditingController,
              textColor: textColor,
              animation: animation,
              fontSize: fontSize,
              fontWeight: fontWeight,
              onTextChanged: (value) => setState(() => text = value),
              onTextColorChanged: (value) => setState(() => textColor = value),
              onAnimationChanged: (value) => setState(() => animation = value),
              onFontSizeChanged: (value) => setState(() => fontSize = value),
              onFontWeightChanged: (value) => setState(() => fontWeight = value),
            ),
          ],
          if (type == ComponentType.image) ...[
            ImageComponentFieldsWidget(
              imageUrlController: textEditingController,
              onImageUrlChanged: (value) => setState(() => text = value),
            ),
          ],
          if (type == ComponentType.button) ...[
            ButtonComponentFieldsWidget(
              buttonLabelController: textEditingController,
              buttonColor: buttonColor,
              buttonColorOnTap: buttonColorOnTap,
              buttonTextColor: buttonTextColor,
              buttonTextColorOnTap: buttonTextColorOnTap,
              borderColor: borderColor, // New: Pass border color
              onButtonLabelChanged: (value) => setState(() => text = value),
              onButtonColorChanged: (value) => setState(() => buttonColor = value),
              onButtonColorOnTapChanged: (value) => setState(() => buttonColorOnTap = value),
              onButtonTextColorChanged: (value) => setState(() => buttonTextColor = value),
              onButtonTextColorOnTapChanged: (value) => setState(() => buttonTextColorOnTap = value),
              onBorderColorChanged: (value) => setState(() => borderColor = value), // New: Callback for border color
            ),
          ],
          if (type == ComponentType.code) ...[
            CodeComponentFieldsWidget(
              onCodeLengthChanged: (value) => setState(() => codeLength = value),
            ),
          ],
          ElevatedButton(
            onPressed: () {
              if (type == null) return;
              Component component = widget.addMissionsController.addComponent(
                widget.missionSelected,
                widget.puzzleSelected,
                type!,
                text: type == ComponentType.text ? text : type == ComponentType.image ? null : type == ComponentType.button ? null : null,
                textColor: type == ComponentType.text ? textColor : null,
                animation: type == ComponentType.text ? animation : null,
                imageUrl: type == ComponentType.image ? text : null,
                buttonLabel: type == ComponentType.button ? text : null,
                buttonColor: type == ComponentType.button ? buttonColor : null,
                buttonColorOnTap: type == ComponentType.button ? buttonColorOnTap : null,
                buttonTextColor: type == ComponentType.button ? buttonTextColor : null,
                buttonTextColorOnTap: type == ComponentType.button ? buttonTextColorOnTap : null,
                borderColor: type == ComponentType.button ? borderColor : null, // New: Pass border color
                fontSize: type == ComponentType.text ? fontSize : null,
                fontWeight: type == ComponentType.text ? fontWeight : null,
                codeLength: type == ComponentType.code ? codeLength : null,
              );
              Widget componentWidget = componentToWidget.convert(component);
              widget.refreshUI(componentWidget);
              Navigator.pop(context);
            },
            child: Text("save component"),
          ),
        ],
      ),
    );
  }
}
