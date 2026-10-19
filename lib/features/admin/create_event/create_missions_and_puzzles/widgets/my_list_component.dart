import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

class MyListComponent extends StatelessWidget {
  final int index;
  final String type;
  final bool isSelected;
  final bool isDone;
  final VoidCallback onTap;

  const MyListComponent({
    super.key,
    required this.index,
    required this.type,
    required this.isSelected,
    required this.isDone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 103,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
                  ? context.colors.accent
                  : (isDone ? context.colors.tick : context.colors.panel),
          borderRadius: BorderRadius.circular(15),
          border: isSelected == false && isDone == false
                  ? Border.all(width: 1.5, color: context.colors.accent)
                  : null,
        ),
        child: Center(
          child: Text(
            '$type ${index + 1}',
            style: TextStyle(
              fontSize: 15,
              color: isSelected || isDone ? Colors.white : context.colors.muted,
            ),
          ),
        ),
      ),
    );
  }
}
