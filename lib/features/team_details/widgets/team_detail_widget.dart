import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teamxperience/constants/colors.dart';

class TeamDetailWidget extends StatelessWidget {
  final String text1;
  final String text2;
  final bool isEditing;
  final TextEditingController? editingController;

  const TeamDetailWidget({
    super.key,
    required this.text1,
    required this.text2,
    this.isEditing = false,
    this.editingController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text1,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: MyColors.blackColor,
          ),
        ),
        const SizedBox(height: 10),
        if (isEditing && editingController != null)
          TextField(
            controller: editingController,
            style: const TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 13,
              color: MyColors.blackColor,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: MyColors.blackColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: MyColors.blackColor, width: 1.5),
              ),
            ),
          )
        else
          Text(
            text2,
            style: const TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 13,
              color: MyColors.blackColor,
            ),
          ),
      ],
    );
  }
}
