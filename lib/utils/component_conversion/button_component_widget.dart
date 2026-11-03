import 'package:flutter/material.dart';
import 'package:teamxperience/utils/event_fonts.dart';

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
  final double? fontSize;
  final double? radius;
  final double? letterSpacing; // Space between the letters, 8 when missing
  final double? paddingY; // Space above and below the label, 5 when missing
  final double? borderWidth; // Thickness of the border, 1.5 when missing
  final VoidCallback? onPressed; // Add callback parameter

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
    this.fontSize,
    this.radius,
    this.letterSpacing,
    this.paddingY,
    this.borderWidth,
    this.onPressed,
  });

  @override
  State<ButtonComponentWidget> createState() => _ButtonComponentWidgetState();
}

class _ButtonComponentWidgetState extends State<ButtonComponentWidget>
    with TickerProviderStateMixin {
  bool _isTapped = false;
  late AnimationController _flickerController;
  late Animation<double> _flickerAnimation;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

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

    //initialize text flicker animation
    _flickerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Half-second cycle
    );
    _flickerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flickerController, curve: Curves.bounceIn),
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

    // initialize glow animation flicker
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Adjust duration as needed
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut, // Smooth pulsing effect
      ),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _glowController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _glowController.forward();
      }
    });
    if (widget.enableGlow == true) {
      _glowController.forward(); // Start glow animation if enabled
    }
  }

  @override
  void dispose() {
    _flickerController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentButtonColor =
        _isTapped
            ? _hexToColor(widget.buttonColorOnTap, defaultColor: Colors.grey)
            : _hexToColor(widget.buttonColor, defaultColor: Colors.white);
    final currentTextColor =
        _isTapped
            ? _hexToColor(
              widget.buttonTextColorOnTap,
              defaultColor: Colors.white,
            )
            : _hexToColor(widget.buttonTextColor, defaultColor: Colors.black);
    final currentBorderColor = _hexToColor(
      widget.borderColor,
      defaultColor: Colors.black,
    );
    final glowColor = _hexToColor(widget.glowColor, defaultColor: Colors.black);

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
        weightMap[widget.fontWeight] ??
        FontWeight.w400; // Default to bold if null

    return AnimatedBuilder(
      animation: _flickerAnimation,
      builder: (context, child) {
        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (_) => setState(() => _isTapped = true),
          onPointerUp: (_) => setState(() {
            _isTapped = false;
            // FIXED: Actually call the onPressed callback
            if (widget.onPressed != null) {
              widget.onPressed!();
            }
          }),
          onPointerCancel: (_) => setState(() => _isTapped = false),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: widget.paddingY ?? 5.0, horizontal: 30),
            decoration: BoxDecoration(
              color: currentButtonColor,
              border: Border.all(color: currentBorderColor, width: widget.borderWidth ?? 1.5),
              borderRadius: BorderRadius.circular(widget.radius ?? 10),
              boxShadow:
                  widget.enableGlow == true
                      ? [
                        BoxShadow(
                          color: glowColor.withValues(
                            alpha: (0.6 + _glowAnimation.value * 0.2),
                          ),
                          blurRadius: 10.0,
                          spreadRadius: 2.0 + (_glowAnimation.value * 3.0),
                          offset: const Offset(0, 0),
                        ),
                      ]
                      : null,
            ),
            child: Opacity(
              opacity:
                  widget.enableFlicker == true ? _flickerAnimation.value : 1,
              child: Text(
                widget.buttonLabel ?? '',
                style: TextStyle(
                  color: currentTextColor,
                  fontSize: widget.fontSize,
                  fontWeight: currentFontWeight,
                  fontFamily: widget.fontFamily ?? 'Poppins',
                  fontVariations: fontVariationsFor(widget.fontFamily ?? 'Poppins', currentFontWeight),
                  letterSpacing: widget.letterSpacing ?? 8,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
