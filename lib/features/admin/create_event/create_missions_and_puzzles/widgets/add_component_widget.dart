import 'package:flutter/material.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/utils/component_to_widget.dart';

import '../../../../../model/component.dart';
import '../controller/add_missions_controller.dart';

class AddComponentWidget extends StatefulWidget {
  final AddMissionsController addMissionsController;
  final int missionSelected;
  final int puzzleSelected;
  final Function(Widget) refreshUI; // callback to notify parent

  const AddComponentWidget({super.key, required this.addMissionsController,required this.missionSelected, required this.puzzleSelected, required this.refreshUI});

  @override
  State<AddComponentWidget> createState() => _AddComponentWidgetState();
}

class _AddComponentWidgetState extends State<AddComponentWidget> {
  ComponentType? type ;
  ComponentToWidget componentToWidget = ComponentToWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Add Components"),
        DropdownButtonFormField<ComponentType>(
          decoration: const InputDecoration(labelText: 'Event Type'),
          value: type,
          items: ComponentType.values
              .map((type) => DropdownMenuItem(
            value: type,
            child: Text(type.toString().split('.').last),
          ))
              .toList(),
          onChanged: (value) {
            setState(() {
              type = value;
            });
          },
          validator: (value) => value == null ? 'Please select a component type' : null,
        ),
        ElevatedButton(onPressed: (){
          Component component = widget.addMissionsController.addComponent(widget.missionSelected, widget.puzzleSelected, type!);
          Widget componentWidget = componentToWidget.convert(component);
          widget.refreshUI(componentWidget);
          Navigator.pop(context);
        }, child: Text("save component"))
      ],
    );
  }
}

