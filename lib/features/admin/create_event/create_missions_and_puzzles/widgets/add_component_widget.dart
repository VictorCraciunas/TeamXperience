import 'package:flutter/material.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/utils/component_conversion/component_to_widget.dart';
import 'package:teamxperience/widgets/my_button.dart';

import '../../../../../constants/colors.dart';
import '../../../../../constants/padding.dart';
import '../../../../../enums/animation_type.dart';
import '../../../../../model/component.dart';
import '../../../../../widgets/my_dropdown.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MyPaddings.appHorizontalPadding,
          ),
          child: Column(
            children: [
              const SizedBox(height: 60),
              MyDropdownField<ComponentType>(
                labelText: 'Tip de componenta',
                items:
                    ComponentType.values
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(
                              type.toString().split('.').last,
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                color: Colors.black,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                value: type,
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
                hint: const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    "Selecteaza tipul de componenta",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      color: MyColors.greyText,
                    ),
                  ),
                ),
                selectedItemStyle: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: Colors.black,
                ),
                borderColor: MyColors.lightBlue,
                borderWidth: 1.5,
                radius: 20,
                isExpanded: true,
              ),
              if (type == ComponentType.text) ...[
                TextComponentFieldsWidget(
                  textController: textEditingController,
                  addMissionsController: widget.addMissionsController,
                  missionSelected: widget.missionSelected,
                  puzzleSelected: widget.puzzleSelected,
                  refreshUI: widget.refreshUI,
                ),
              ],
              if (type == ComponentType.image) ...[
                ImageComponentFieldsWidget(
                  imageUrlController: textEditingController,
                  addMissionsController: widget.addMissionsController,
                  missionSelected: widget.missionSelected,
                  puzzleSelected: widget.puzzleSelected,
                  refreshUI: widget.refreshUI,
                ),
              ],
              if (type == ComponentType.button) ...[
                ButtonComponentFieldsWidget(
                  buttonLabelController: textEditingController,
                  buttonColor: '#FFFFFF',
                  buttonColorOnTap: '#CCCCCC',
                  buttonTextColor: '#000000',
                  buttonTextColorOnTap: '#FFFFFF',
                  borderColor: '#000000',
                  addMissionsController: widget.addMissionsController,
                  missionSelected: widget.missionSelected,
                  puzzleSelected: widget.puzzleSelected,
                  refreshUI: widget.refreshUI,
                ),
              ],
              if (type == ComponentType.code) ...[
                CodeComponentFieldsWidget(
                  addMissionsController: widget.addMissionsController,
                  missionSelected: widget.missionSelected,
                  puzzleSelected: widget.puzzleSelected,
                  refreshUI: widget.refreshUI,
                ),
              ],
              const SizedBox(height: 20),
              // MyButton(
              //   buttonText: 'Salveaza Componenta',
              //   textColor: Colors.white,
              //   buttonOnTap: () {
              //     if (type == null) return;
              //     Component
              //     component = widget.addMissionsController.addComponent(
              //       widget.missionSelected,
              //       widget.puzzleSelected,
              //       type!,
              //       text:
              //           type == ComponentType.text
              //               ? text
              //               : type == ComponentType.image
              //               ? null
              //               : type == ComponentType.button
              //               ? null
              //               : null,
              //       textColor: type == ComponentType.text ? textColor : null,
              //       animation: type == ComponentType.text ? animation : null,
              //       imageUrl: type == ComponentType.image ? text : null,
              //       buttonLabel: type == ComponentType.button ? text : null,
              //       buttonColor:
              //           type == ComponentType.button ? buttonColor : null,
              //       buttonColorOnTap:
              //           type == ComponentType.button ? buttonColorOnTap : null,
              //       buttonTextColor:
              //           type == ComponentType.button ? buttonTextColor : null,
              //       buttonTextColorOnTap:
              //           type == ComponentType.button
              //               ? buttonTextColorOnTap
              //               : null,
              //       borderColor:
              //           type == ComponentType.button ? borderColor : null,
              //       // New: Pass border color
              //       fontSize: type == ComponentType.text ? fontSize : null,
              //       fontWeight: type == ComponentType.text ? fontWeight : null,
              //       codeLength: type == ComponentType.code ? codeLength : null,
              //     );
              //     Widget componentWidget = componentToWidget.convert(component);
              //     widget.refreshUI(componentWidget);
              //     Navigator.pop(context);
              //   },
              //   withBorder: false,
              //   buttonColor: MyColors.lightBlue,
              //   fontWeight: FontWeight.w500,
              //   buttonTextSize: 14,
              //   buttonWidth: 270,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
