import 'package:flutter/material.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/model/puzzle.dart';

import '../../../../../../constants/colors.dart';
import '../../../../../../constants/padding.dart';
import '../../../../../../widgets/my_dropdown.dart';
import '../../controller/add_missions_controller.dart';
import 'create_button/create_button_component.dart';
import 'create_code/create_code_component.dart';
import 'create_image/create_image_component.dart';
import 'create_text/create_text_component.dart';

class AddComponentWidget extends StatefulWidget {
  final Puzzle puzzle;
  final Function(Widget) refreshUI;// callback to notify parent
  final Component component;
  final bool edit;

   const AddComponentWidget({
    super.key,
     required this.puzzle,
    required this.refreshUI,
    required this.component,
     required this.edit
  });

  @override
  State<AddComponentWidget> createState() => _AddComponentWidgetState();
}

class _AddComponentWidgetState extends State<AddComponentWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.edit) {
      type = widget.component.type;
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
                borderColor: MyColors.lightBlue,
                borderWidth: 1.5,
                radius: 20,
              ),
              if (type == ComponentType.text) ...[
                TextComponentFieldsWidget(
                  refreshUI: widget.refreshUI,
                  component:widget.component,
                  edit: widget.edit,
                  puzzle: widget.puzzle,
                ),
              ],
              if (type == ComponentType.image) ...[
                ImageComponentFieldsWidget(
                  refreshUI: widget.refreshUI,
                  component:widget.component,
                  edit: widget.edit,
                  puzzle: widget.puzzle,


                ),
              ],
              if (type == ComponentType.button) ...[
                ButtonComponentFieldsWidget(
                  refreshUI: widget.refreshUI,
                  component: widget.component,
                  edit: widget.edit,
                  puzzle: widget.puzzle,

                ),
              ],
              if (type == ComponentType.code) ...[
                CodeComponentFieldsWidget(
                  refreshUI: widget.refreshUI,
                  component:widget.component,
                  edit: widget.edit,
                  puzzle: widget.puzzle,
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
