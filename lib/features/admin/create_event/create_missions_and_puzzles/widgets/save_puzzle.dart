import 'package:flutter/material.dart';
import 'package:teamxperience/enums/puzzle_type.dart';

import '../controller/add_missions_controller.dart';

class SavePuzzle extends StatefulWidget {
  final int
  nrMission; // 1 indexed ( so we need to make -1 when we use list.add)
  final AddMissionsController addMissionsController;
  final int selectedPuzzle;

  const SavePuzzle({
    super.key,
    required this.nrMission,
    required this.selectedPuzzle,
    required this.addMissionsController,
  });

  @override
  State<SavePuzzle> createState() => _SavePuzzleState();
}

class _SavePuzzleState extends State<SavePuzzle> {
  TextEditingController? text = TextEditingController();
  PuzzleType? type;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<PuzzleType>(
          decoration: const InputDecoration(labelText: 'Event Type'),
          value: type,
          items:
              PuzzleType.values
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
            });
          },
          validator:
              (value) => value == null ? 'Please select an puzzle type' : null,
        ),
        if (type == PuzzleType.code) ...[
          TextField(
            controller: text,
            decoration: const InputDecoration(labelText: 'Enter Code'),
          ),
        ],
        ElevatedButton(onPressed: () {
          widget.addMissionsController.setPuzzleType(widget.nrMission, widget.selectedPuzzle, type!, type == PuzzleType.code ? text!.text : null);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Puzzle saved successfully')),
          );
          Navigator.pop(context);
        }, child: Text("Save")),
      ],
    );
  }
}
