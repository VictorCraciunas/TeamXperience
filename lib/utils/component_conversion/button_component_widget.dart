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
    if (hexColor.length == 6) {
      return Color(int.parse('FF$hexColor', radix: 16)); // Full opacity
    } else if (hexColor.length == 8) {
      return Color(int.parse(hexColor, radix: 16)); // With alpha
    } else {
      return defaultColor;
    }
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

    return Listener(
      behavior: HitTestBehavior.opaque,  // ensures even transparent areas catch the touch
      onPointerDown: (_)  => setState(() => _isTapped = true),
      onPointerUp:   (_)  => setState(() => _isTapped = false),
      onPointerCancel: (_) => setState(() => _isTapped = false),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: currentButtonColor,
          border: Border.all(color: currentBorderColor, width: 3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            widget.buttonLabel!,
            style: TextStyle(
              color: currentTextColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}