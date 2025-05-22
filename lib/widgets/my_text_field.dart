import 'package:flutter/material.dart';
import 'package:teamxperience/constants/colors.dart';

/// A reusable labeled text field that displays a label on the left
/// and an outlined text field on the right, with customizable styling.
class MyTextField extends StatefulWidget {
  /// Controller for the text input
  final TextEditingController controller;

  /// The text label displayed above the field
  final String labelText;

  /// Font size of the label
  final double labelFontSize;

  /// Font weight of the label
  final FontWeight labelFontWeight;

  /// Color of the text field's border when enabled
  final Color borderColor;

  /// Whether the input is obscured (for passwords)
  final bool obscureText;

  /// Keyboard type (e.g. email, number, text)
  final TextInputType keyboardType;

  /// Optional widget at the start of the field (prefixIcon)
  final Widget? leading;

  /// Optional widget at the end of the field (suffixIcon)
  final Widget? trailing;

  /// Optional hint text inside the field
  final String? hintText;

  /// Optional custom validator; if null, defaults to checking non-empty
  final String? Function(String?)? validator;

  const MyTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.labelFontSize = 16,
    this.labelFontWeight = FontWeight.w500,
    this.borderColor = const Color(0xFFE6E6E6),
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.leading,
    this.trailing,
    this.hintText,
    this.validator,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  void _toggleObscure() {
    setState(() {
      _obscure = !_obscure;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget? suffix;
    if (widget.obscureText && widget.trailing != null) {
      suffix = GestureDetector(
        onTap: _toggleObscure,
        child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: widget.trailing,
        ),
      );
    } else if (widget.trailing != null) {
      suffix = Padding(
        padding: const EdgeInsets.only(right: 10),
        child: widget.trailing,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: widget.labelFontSize,
            fontWeight: widget.labelFontWeight,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: _obscure,
          validator:
              widget.validator ??
              (value) =>
                  (value ?? '').isEmpty ? 'Enter ${widget.labelText}' : null,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              color: MyColors.greyText,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10),
              child: widget.leading,
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: suffix,
            ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide(color: widget.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide(color: widget.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide(color: widget.borderColor, width: 3),
            ),
          ),
        ),
      ],
    );
  }
}
