import 'package:flutter/material.dart';
import 'package:teamxperience/model/component.dart';

class CodeComponentWidget extends StatelessWidget {
  final Component component;

  const CodeComponentWidget({
    super.key,
    required this.component,
  });

  @override
  Widget build(BuildContext context) {
    final codeLength = component.codeLength ?? 5; // Default to 5 if not set

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5E8C7), // Parchment-like background
        border: Border.all(color: Colors.black, width: 2),
      ),
      child:Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(codeLength, (index) => index)
            .map((index) => Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFF5E8C7),
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(25),
          ),
          child: TextField(
            textAlign: TextAlign.center,
            maxLength: 1, // Restrict to one letter
            decoration: const InputDecoration(
              counterText: '', // Hide character count
              border: InputBorder.none,
            ),
            onChanged: (value) {
              // Optional: Store the value in a state list if needed
            },
          ),
        ))
            .toList(),
      ),
    );
  }
}