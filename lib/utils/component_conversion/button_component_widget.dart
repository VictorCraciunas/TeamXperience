import 'package:flutter/material.dart';

class ButtonComponentWidget extends StatefulWidget {
  final String? buttonLabel;
  final String? buttonColor; // Initial background color (hex string)
  final String? buttonColorOnTap; // Background color on tap (hex string)
  final String? buttonTextColor; // Initial text color (hex string)
  final String? buttonTextColorOnTap; // Text color on tap (hex string)
  final String? borderColor; // New: Border color

  const ButtonComponentWidget({
    super.key,
    this.buttonLabel,
    this.buttonColor,
    this.buttonColorOnTap,
    this.buttonTextColor,
    this.buttonTextColorOnTap,
    this.borderColor,
  });

  @override
  State<ButtonComponentWidget> createState() => _ButtonComponentWidgetState();
}

class _ButtonComponentWidgetState extends State<ButtonComponentWidget> {
  bool _isTapped = false;

  // Helper to convert hex string to Color
  Color _hexToColor(String? hex, {Color defaultColor = Colors.black}) {
    if (hex == null || hex.isEmpty) return defaultColor;
    final hexColor = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final currentButtonColor = _isTapped
        ? _hexToColor(widget.buttonColorOnTap, defaultColor: Colors.grey)
        : _hexToColor(widget.buttonColor, defaultColor: Colors.white);
    final currentTextColor = _isTapped
        ? _hexToColor(widget.buttonTextColorOnTap, defaultColor: Colors.white)
        : _hexToColor(widget.buttonTextColor, defaultColor: Colors.black);
    final currentBorderColor = _hexToColor(widget.borderColor, defaultColor: Colors.black);

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isTapped = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isTapped = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isTapped = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: currentButtonColor, // Dynamic background color
          border: Border.all(
            color: currentBorderColor,
            width: 3.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          widget.buttonLabel ?? 'Button',
          style: TextStyle(
            color: currentTextColor, // Dynamic text color
            fontSize: 16.0,
            letterSpacing: 2.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}