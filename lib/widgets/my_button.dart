import 'package:flutter/material.dart';

class MyButton extends StatefulWidget {
  final String buttonText;
  final Color? buttonColor;
  final Color textColor;
  final LinearGradient? gradient;
  final Function() buttonOnTap;
  final Widget? leading;
  final bool withBorder;
  final FontWeight fontWeight;

  const MyButton({
    super.key,
    required this.buttonText,
    required this.textColor,
    required this.buttonOnTap,
    required this.withBorder,
    this.buttonColor,
    this.gradient,
    this.leading,
    this.fontWeight = FontWeight.w500
  });

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  bool isPressed = false;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          isPressed = false;
        });
        widget.buttonOnTap();
      },
      onTapCancel: () {
        setState(() {
          isPressed = false;
        });
      },
      onTap: widget.buttonOnTap,
      child: Opacity(
        opacity: isPressed ? 0.6 : 1.0,
        child: Container(
          width: double.infinity,
          height: 57,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(50)),
            color: widget.buttonColor,
            gradient: widget.gradient,
            border: widget.withBorder
                ? Border.all(
              width: 2,
              color: const Color(0xFFE6E6E6),
            )
                : null,  // ← properly close the ternary
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.leading != null) ...[widget.leading!, const SizedBox(width: 15)],
              Text(
                widget.buttonText,
                style: TextStyle(
                  color: widget.textColor,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: widget.fontWeight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
