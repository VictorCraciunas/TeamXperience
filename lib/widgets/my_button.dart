import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String buttonText;
  final Color? buttonColor;
  final Color textColor;
  final LinearGradient? gradient;
  final Function() buttonOnTap;
  final Widget? leading;
  final bool withBorder;

  const MyButton({
    super.key,
    required this.buttonText,
    required this.textColor,
    required this.buttonOnTap,
    required this.withBorder,
    this.buttonColor,
    this.gradient,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: buttonOnTap,
      child: Container(
        width: double.infinity,
        height: 57,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(50)),
          color: buttonColor,
          gradient: gradient,
          border: withBorder
              ? Border.all(
            width: 2,
            color: const Color(0xFFE6E6E6),
          )
              : null,  // ← properly close the ternary
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 15)],
            Text(
              buttonText,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
