import 'package:flutter/material.dart';

import '../controller/add_missions_controller.dart';
import 'add_component_widget.dart';

class PuzzleWidget extends StatefulWidget {
  final int nrMission;  // 1 indexed ( so we need to make -1 when we use list.add)
  final AddMissionsController addMissionsController;
  final int selectedPuzzle;
  const PuzzleWidget({super.key, required this.nrMission, required this.selectedPuzzle, required this.addMissionsController});

  @override
  State<PuzzleWidget> createState() => _PuzzleWidgetState();
}

class _PuzzleWidgetState extends State<PuzzleWidget> {
  List<Widget> puzzleComponents = [];
  int componentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (puzzleComponents.isNotEmpty) ...[
          const SizedBox(height: 10),
          const Text(
            'Additional Components:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          Column(
            children: List.generate(puzzleComponents.length, (index) => ListTile(
              title: puzzleComponents[index],
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    puzzleComponents.removeAt(index);
                    widget.addMissionsController.deleteComponent(
                      widget.nrMission,
                      widget.selectedPuzzle,
                      index,
                    );
                  });
                },
              ),
            )),
          ),
        ],
        ElevatedButton(
          onPressed: widget.selectedPuzzle >= 0
              ? () {
            print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx Adding component for mission ${widget.nrMission - 1}, puzzle ${widget.selectedPuzzle}");
            showModalBottomSheet(
              context: context,
              builder: (context) => AddComponentWidget(
                addMissionsController: widget.addMissionsController,
                missionSelected: widget.nrMission,
                puzzleSelected: widget.selectedPuzzle,
                refreshUI: (Widget componentWidget) {
                  setState(() {
                    puzzleComponents.add(componentWidget);
                    componentIndex++;
                  });
                },
              ),
            );
          }
              : null, // Disable button if selectedPuzzle is invalid
          child: const Text("Add component"),
        ),
        ElevatedButton(onPressed: (){
          setState(() {
            puzzleComponents.clear();
            widget.addMissionsController.deleteAllComponents(widget.nrMission , widget.selectedPuzzle);
          });
        }, child: Text("Clear components"))
      ],
    );
  }
}
