import 'package:flutter/material.dart';

class MissionWidget extends StatefulWidget {
  final int nrMission;
  final Function(int) onSetPuzzles; // Callback to notify parent

  const MissionWidget({
    super.key,
    required this.nrMission,
    required this.onSetPuzzles,
  });

  @override
  State<MissionWidget> createState() => _MissionWidgetState();
}

class _MissionWidgetState extends State<MissionWidget> {
  late TextEditingController puzzlesCountController;
  List<Widget> puzzleWidgets = [];
  int selectedPuzzle = 0;


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
                final count = int.tryParse(text) ?? 0;
                widget.onSetPuzzles(count); // Notify parent
                setState(() {
                  puzzleWidgets = List.generate(
                    count,
                        (i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text('Puzzle ${i + 1}', style: const TextStyle(fontSize: 14)),
                    ),
                  );
                });
              },
              child: const Text('Set Puzzles'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (puzzleWidgets.isNotEmpty) ...[
          const Text(
            'Puzzles:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          ...puzzleWidgets,
        ],
      ],
    );
  }
}