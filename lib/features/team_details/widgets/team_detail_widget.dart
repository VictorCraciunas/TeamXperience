import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

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
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: context.colors.text,
          ),
        ),
        const SizedBox(height: 10),
        if (isEditing && editingController != null)
          TextField(
            controller: editingController,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 13,
              color: context.colors.text,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: context.colors.text),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: context.colors.text, width: 1.5),
              ),
            ),
          )
        else
          Text(
            text2,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 13,
              color: context.colors.text,
            ),
          ),
      ],
    );
  }
}
