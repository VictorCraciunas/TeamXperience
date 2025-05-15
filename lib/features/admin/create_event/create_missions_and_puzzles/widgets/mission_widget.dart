import 'package:flutter/material.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/controller/add_missions_controller.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/add_component_widget.dart';
import 'my_list_component.dart';

class MissionWidget extends StatefulWidget {
  final int nrMission;  // 1 indexed ( so we need to make -1 when we use list.add)
  final Function(int) onSetPuzzles; // Callback to notify parent
  final AddMissionsController addMissionsController;

  const MissionWidget({
    super.key,
    required this.nrMission,
    required this.onSetPuzzles,
    required this.addMissionsController,
  });

  @override
  State<MissionWidget> createState() => _MissionWidgetState();
}

class _MissionWidgetState extends State<MissionWidget> {
  late TextEditingController puzzlesCountController;
  int numberOfPuzzles = 0;
  int selectedPuzzle = -1; // Start with no selection
  List<Widget> puzzleComponents = [];

  @override
  void initState() {
    super.initState();
    puzzlesCountController = TextEditingController();
  }

  @override
  void dispose() {
    puzzlesCountController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mission ${widget.nrMission} Details',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: puzzlesCountController,
                decoration: const InputDecoration(
                  labelText: 'Number of Puzzles for this mission',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of puzzles';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                final text = puzzlesCountController.text;
                final nrPuzzles = int.tryParse(text) ?? 0;
                widget.onSetPuzzles(nrPuzzles); // Notify parent
                setState(() {
                  numberOfPuzzles = nrPuzzles;
                  selectedPuzzle =
                      -1; // Reset selection when setting new puzzles
                });
              },
              child: const Text('Set Puzzles'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (numberOfPuzzles > 0) ...[
          const Text(
            'Puzzles:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: numberOfPuzzles,
              itemBuilder: (context, index) {
                return MyListComponent(
                  index: index,
                  type: "Puzzle",
                  isSelected: selectedPuzzle == index,
                  onTap: () {
                    setState(() {
                      selectedPuzzle = index;
                    });
                  },
                );
              },
            ),
          ),
        ],
        if (puzzleComponents.isNotEmpty) ...[
          const SizedBox(height: 10),
          const Text(
            'Additional Components:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          ...puzzleComponents,
        ],
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: (numberOfPuzzles > 0 && selectedPuzzle != -1)
              ? () => showModalBottomSheet(
            context: context,
            builder: (context) => AddComponentWidget(
              addMissionsController: widget.addMissionsController,
              missionSelected: widget.nrMission - 1,
              puzzleSelected: selectedPuzzle,
              refreshUI: (Widget componentWidget) {
                setState(() {
                  puzzleComponents.add(componentWidget);
                });
              },
            ),
          )
              : null, // Disabled if no puzzles or no selection
          child: const Text("Add component"),
        ),
      ],
    );
  }
}
