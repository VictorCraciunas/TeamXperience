import 'package:flutter/material.dart';


class MyListComponent extends StatelessWidget {
  final int index;
  final String type;
  final bool isSelected;
  final VoidCallback onTap;

  const MyListComponent({
    super.key,
    required this.index,
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[100] : Colors.red[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$type ${index + 1}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}