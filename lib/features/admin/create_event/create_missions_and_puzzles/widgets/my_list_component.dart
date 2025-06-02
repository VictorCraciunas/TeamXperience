import 'package:flutter/material.dart';
import 'package:teamxperience/constants/colors.dart';

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
                  ? MyColors.lightBlue
                  : (isDone ? MyColors.yellow : Colors.white),
          borderRadius: BorderRadius.circular(15),
          border: isSelected == false && isDone == false
                  ? Border.all(width: 1.5, color: MyColors.lightBlue)
                  : null,
        ),
        child: Center(
          child: Text(
            '$type ${index + 1}',
            style: TextStyle(
              fontSize: 15,
              fontFamily: 'Poppins',
              color: isSelected || isDone ? Colors.white : MyColors.greyText,
            ),
          ),
        ),
      ),
    );
  }
}
