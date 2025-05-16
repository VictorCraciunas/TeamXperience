import 'package:flutter/material.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/utils/component_conversion/component_to_widget.dart';

import '../../../../../enums/animation_type.dart';
import '../../../../../model/component.dart';
import '../controller/add_missions_controller.dart';
import 'create_components/create_button_component.dart';
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

  @override
  Widget build(BuildContext context) {
    return Column(
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
            onButtonLabelChanged: (value) => setState(() => text = value),
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
              fontSize: type == ComponentType.text ? fontSize : null,
              fontWeight: type == ComponentType.text ? fontWeight : null,
            );
            Widget componentWidget = componentToWidget.convert(component);
            widget.refreshUI(componentWidget);
            Navigator.pop(context);
          },
          child: Text("save component"),
        ),
      ],
    );
  }
}
