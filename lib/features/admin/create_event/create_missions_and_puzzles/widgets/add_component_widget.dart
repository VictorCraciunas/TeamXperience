import 'package:flutter/material.dart';
import 'package:teamxperience/enums/component-type.dart';

import '../../../../../constants/colors.dart';
import '../../../../../constants/padding.dart';
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
  TextEditingController textEditingController = TextEditingController();

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
                  addMissionsController: widget.addMissionsController,
                  missionSelected: widget.missionSelected,
                  puzzleSelected: widget.puzzleSelected,
                  refreshUI: widget.refreshUI,
                ),
              ],
              if (type == ComponentType.image) ...[
                ImageComponentFieldsWidget(
                  addMissionsController: widget.addMissionsController,
                  missionSelected: widget.missionSelected,
                  puzzleSelected: widget.puzzleSelected,
                  refreshUI: widget.refreshUI,
                ),
              ],
              if (type == ComponentType.button) ...[
                ButtonComponentFieldsWidget(
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
