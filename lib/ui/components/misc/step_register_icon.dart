import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';


class StepRegisterWidget extends StatelessWidget {
  const StepRegisterWidget({super.key, required this.text, required this.isEnabled});

  final String text;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: isEnabled
            ? context.colors.tick
            : context.colors.border,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Center(
        child: Text(text,style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16,color: Colors.white),),
      ),
    );
  }
}
