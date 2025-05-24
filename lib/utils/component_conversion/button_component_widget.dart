import 'package:flutter/material.dart';

class ButtonComponentWidget extends StatefulWidget {
  final String? buttonLabel;
  final String? buttonColor; // Initial background color (hex string)
  final String? buttonColorOnTap; // Background color on tap (hex string)
  final String? buttonTextColor; // Initial text color (hex string)
  final String? buttonTextColorOnTap; // Text color on tap (hex string)
  final String? borderColor;
  final bool? enableGlow; // Enable glow effect
  final String? glowColor; // Color for glow effect
  final bool? enableFlicker; // Enable flicker animation
  final String? fontFamily; // Font family
  final String? fontWeight; // Font weight

  const ButtonComponentWidget({
    super.key,
    this.buttonLabel,
    this.buttonColor,
    this.buttonColorOnTap,
    this.buttonTextColor,
    this.buttonTextColorOnTap,
    this.borderColor,
    this.enableGlow,
    this.glowColor,
    this.enableFlicker,
    this.fontFamily,
    this.fontWeight,
  });

  @override
  State<ButtonComponentWidget> createState() => _ButtonComponentWidgetState();
}

class _ButtonComponentWidgetState extends State<ButtonComponentWidget>
    with SingleTickerProviderStateMixin {
  bool _isTapped = false;
  late AnimationController _flickerController;
  late Animation<double> _flickerAnimation;

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
  void initState() {
    super.initState();
    _flickerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Half-second cycle
    );
    _flickerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _flickerController,
        curve: Curves.easeInOut,
      ),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _flickerController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _flickerController.forward();
      }
    });
    if (widget.enableFlicker == true) {
      _flickerController.forward();
    }
  }


  @override
  void dispose() {
    _flickerController.dispose();
    super.dispose();
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
    final currentGlowColor = _hexToColor(widget.glowColor, defaultColor: Colors.black);

    // Map fontWeight string to FontWeight enum
    final weightMap = {
      'Thin (100)': FontWeight.w100,
      'Light (300)': FontWeight.w300,
      'Regular (400)': FontWeight.w400,
      'Medium (500)': FontWeight.w500,
      'Bold (700)': FontWeight.w700,
      'Black (900)': FontWeight.w900,
    };
    final currentFontWeight =
        weightMap[widget.fontWeight] ?? FontWeight.bold; // Default to bold if null

    return AnimatedBuilder(
      animation: _flickerAnimation,
      builder: (context, child) {
        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (_) => setState(() => _isTapped = true),
          onPointerUp: (_) => setState(() => _isTapped = false),
          onPointerCancel: (_) => setState(() => _isTapped = false),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: currentButtonColor,
              border: Border.all(color: currentBorderColor, width: 1.5),
              borderRadius: BorderRadius.circular(8),
              boxShadow: widget.enableGlow == true
                  ? [
                BoxShadow(
                  color: currentGlowColor.withValues(alpha:
                    widget.enableFlicker == true
                        ? 0.6 + (_flickerAnimation.value * 0.2) // From 0.6 to 0.8
                        : 0.6, // Default opacity
                  ),
                  blurRadius: 10.0,
                  spreadRadius: widget.enableFlicker == true
                      ? 2.0 + (_flickerAnimation.value * 3.0) // From 2.0 to 4.0
                      : 2.0, // Default spread
                  offset: const Offset(0, 0),
                ),
              ]
                  : null,
            ),
            child: Center(
              child: Text(
                widget.buttonLabel!,
                style: TextStyle(
                  color: currentTextColor,
                  fontSize: 16,
                  fontWeight: currentFontWeight,
                  fontFamily: widget.fontFamily ?? 'Poppins',
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}