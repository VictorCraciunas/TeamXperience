import 'package:flutter/material.dart';
import 'package:teamxperience/enums/animation_type.dart';

class TextComponentWidget extends StatelessWidget {
  final String text;
  final String? textColor; // Hex string (e.g., "#34d974")
  final AnimationType? animation;
  final double? fontSize;
  final String? fontWeight; // String like "Black (900)"
  final String? fontFamily;
  final int? typewriterSpeed;

  const TextComponentWidget({
    super.key,
    required this.text,
    this.textColor,
    this.animation,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
    this.typewriterSpeed,
  });

  // Helper to convert hex string to Color
  Color hexToColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.black;
    final hexColor = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  // Helper to map fontWeight string to FontWeight
  FontWeight mapFontWeight(String? weight) {
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
    final currentColor = hexToColor(textColor);
    final currentFontWeight = mapFontWeight(fontWeight);

    if (animation == AnimationType.typewriter && text.isNotEmpty) {
      return TypewriterText(
        key: ValueKey(text), // Add key to force rebuild when text changes
        text: text,
        textColor: currentColor,
        fontSize: fontSize,
        fontWeight: currentFontWeight,
        fontFamily: fontFamily,
        msPerCharacter: typewriterSpeed ?? 100,
      );
    }

    return Text(
      textAlign: TextAlign.center,
      text,
      style: TextStyle(
          color: currentColor,
          fontSize: fontSize,
          fontWeight: currentFontWeight,
          fontFamily: fontFamily
      ),
    );
  }
}

class TypewriterText extends StatefulWidget {
  final String text;
  final Color textColor;
  final double? fontSize;
  final FontWeight fontWeight;
  final String? fontFamily;
  final int msPerCharacter;

  const TypewriterText({
    super.key,
    required this.text,
    required this.textColor,
    this.fontSize,
    required this.fontWeight,
    this.fontFamily,
    this.msPerCharacter = 100,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset animation when text changes
    if (oldWidget.text != widget.text) {
      _setupAnimation();
    }
  }

  void _setupAnimation() {
    // Dispose previous controller if it exists
    _controller?.dispose();

    _controller = AnimationController(
      duration: Duration(milliseconds: widget.text.length * widget.msPerCharacter),
      vsync: this,
    );

    _animation = IntTween(
        begin: 0,
        end: widget.text.length
    ).animate(_controller!);

    _controller!.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Add bounds checking to prevent RangeError
        final displayLength = _animation.value.clamp(0, widget.text.length);

        return Text(
          textAlign: TextAlign.center,
          widget.text.substring(0, displayLength),
          style: TextStyle(
              color: widget.textColor,
              fontSize: widget.fontSize,
              fontWeight: widget.fontWeight,
              fontFamily: widget.fontFamily
          ),
        );
      },
    );
  }
}