import 'package:flutter/material.dart';
import 'package:teamxperience/model/component.dart';

class CodeComponentWidget extends StatefulWidget {
  final Component component;

  const CodeComponentWidget({
    super.key,
    required this.component,
  });

  @override
  CodeComponentWidgetState createState() => CodeComponentWidgetState();
}

class CodeComponentWidgetState extends State<CodeComponentWidget> {
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();
    final int codeLength = widget.component.codeLength ?? 5;
    controllers = List.generate(codeLength, (_) => TextEditingController());
    focusNodes = List.generate(codeLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int codeLength = widget.component.codeLength ?? 5;
    const int maxPerRow = 5;

    // Determine how many rows we need (ceil)
    final int rowCount = (codeLength + maxPerRow - 1) ~/ maxPerRow;

    // Distribute items as evenly as possible across rows
    final int basePerRow = codeLength ~/ rowCount;
    final int extra = codeLength % rowCount;

    // Build rows with evenly distributed cell counts
    int currentIndex = 0;
    final rows = List<Widget>.generate(rowCount, (rowIndex) {
      // Each of the first 'extra' rows gets one additional cell
      final countInRow = basePerRow + (rowIndex < extra ? 1 : 0);
      final rowCells = List<Widget>.generate(countInRow, (_) {
        final index = currentIndex;
        currentIndex++;
        return Expanded( // Use Expanded to share available space
          child: _buildCell(index),
        );
      });

      return Padding(
        padding: EdgeInsets.only(bottom: rowIndex == rowCount - 1 ? 0 : 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center the row
          children: rowCells,
        ),
      );
    });

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0x00f5e8c7),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: rows,
      ),
    );
  }

  Widget _buildCell(int index) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0x00f5e8c7),
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(25),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      child: TextField(
        controller: controllers[index],
        focusNode: focusNodes[index],
        textAlign: TextAlign.center,
        maxLength: 1,
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.length == 1 && index < controllers.length - 1) {
            FocusScope.of(context).requestFocus(focusNodes[index + 1]);
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).requestFocus(focusNodes[index - 1]);
          }
        },
        style: const TextStyle(
          fontSize: 20, // Increase this value to make the text bigger (e.g., 20, 24, 30)
          fontWeight: FontWeight.bold, // Optional: Makes text bolder
        ),
      ),
    );
  }
}