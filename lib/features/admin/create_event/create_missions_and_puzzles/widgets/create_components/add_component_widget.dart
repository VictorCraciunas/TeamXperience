import 'package:flutter/material.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/model/component.dart';

import '../../../../../../constants/colors.dart';
import '../../../../../../constants/padding.dart';
import '../../../../../../widgets/my_dropdown.dart';
import '../../controller/add_missions_controller.dart';
import 'create_button/create_button_component.dart';
import 'create_code/create_code_component.dart';
import 'create_image/create_image_component.dart';
import 'create_text/create_text_component.dart';

class AddComponentWidget extends StatefulWidget {
  final AddMissionsController addMissionsController;
  final int missionSelected;
  final int puzzleSelected;
  final Function(Widget) refreshUI;// callback to notify parent
  final Component? componentToEdit;

   const AddComponentWidget({
    super.key,
    required this.addMissionsController,
    required this.missionSelected,
    required this.puzzleSelected,
    required this.refreshUI,
    this.componentToEdit
  });

  @override
  State<AddComponentWidget> createState() => _AddComponentWidgetState();
}

class _AddComponentWidgetState extends State<AddComponentWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.componentToEdit != null) {
      type = widget.componentToEdit!.type;
    }
  }

  ComponentType? type;

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
                  componentToEdit: widget.componentToEdit,
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
            ],
          ),
        ),
      ),
    );
  }
}
