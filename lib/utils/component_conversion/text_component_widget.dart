import 'package:flutter/material.dart';
import 'package:teamxperience/enums/animation_type.dart';

class TextComponentWidget extends StatelessWidget {
  final String text;
  final String? textColor; // Hex string (e.g., "#34d974")
  final AnimationType? animation;
  final double? fontSize;
  final String? fontWeight; // String like "Black (900)"

  const TextComponentWidget({
    super.key,
    required this.text,
    this.textColor,
    this.animation,
    this.fontSize,
    this.fontWeight,
  });
  // Helper to convert hex string to Color
  Color _hexToColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.black;
    final hexColor = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  // Helper to map fontWeight string to FontWeight
  FontWeight _mapFontWeight(String? weight) {
    if (weight == null) return FontWeight.normal;
    final match = RegExp(r'\((\d+)\)').firstMatch(weight);
    if (match != null) {
      final weightValue = int.tryParse(match.group(1)!) ?? 400;
      return FontWeight.values.firstWhere(
            (w) => w.index == (weightValue ~/ 100) - 1,
        orElse: () => FontWeight.normal,
      );
    }
    return FontWeight.normal; // Default to normal if parsing fails
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = _hexToColor(textColor);
    final currentFontWeight = _mapFontWeight(fontWeight);

    if (animation == AnimationType.typewriter) {
      return TypewriterText(
        text: text,
        textColor: currentColor,
        fontSize: fontSize,
        fontWeight: currentFontWeight,
      );
    }
    return Text(
      text,
      style: TextStyle(
        color: currentColor,
        fontSize: fontSize,
        fontWeight: currentFontWeight,
      ),
    );
  }
}

class TypewriterText extends StatefulWidget {
  final String text;
  final Color textColor;
  final double? fontSize;
  final FontWeight fontWeight;

  const TypewriterText({
    super.key,
    required this.text,
    required this.textColor,
    this.fontSize,
    required this.fontWeight,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.text.length * 100),
      vsync: this,
    );
    _animation = IntTween(begin: 0, end: widget.text.length).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          widget.text.substring(0, _animation.value),
          style: TextStyle(
            color: widget.textColor,
            fontSize: widget.fontSize,
            fontWeight: widget.fontWeight,
          ),
        );
      },
    );
  }
}