import 'package:flutter/material.dart';
import 'package:teamxperience/constants/colors.dart';

/// A reusable labeled text field that displays a label on the left
/// and an outlined text field on the right, with customizable styling.
class MyTextField extends StatefulWidget {
  /// Controller for the text input
  final TextEditingController? controller;

  /// The text label displayed above the field
  final String? labelText;

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
  /// Optional callback when the text changes
  final void Function(String)? onChanged;

  final double borderWidth;

  final double radius;

  final bool readOnly;
  final int? maxLines;
  final Color hintTextColor;
  final double hintTextSize;
  final FontWeight hinttextWeight;
  /// Optional callback when the field is tapped (e.g., for date pickers)
  final VoidCallback? onTap;

  const MyTextField({
    super.key,
    this.controller,
    this.labelText,
    this.labelFontSize = 15,
    this.labelFontWeight = FontWeight.w500,
    this.borderColor = const Color(0xFFE6E6E6),
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.leading,
    this.trailing,
    this.hintText,
    this.validator,
    this.borderWidth = 2,
    this.radius = 50,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.hintTextColor = MyColors.greyText,
    this.hintTextSize = 14,
    this.hinttextWeight = FontWeight.w400,
    this.onChanged, // Add this line
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
      // For password fields, trailing icon toggles obscure
      suffix = GestureDetector(
        onTap: _toggleObscure,
        child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: widget.trailing,
        ),
      );
    } else if (widget.readOnly && widget.trailing != null) {
      // For read-only fields (e.g., date fields), trailing icon triggers onTap
      suffix = GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.only(right: 15),
          child: widget.trailing,
        ),
      );
    } else if (widget.trailing != null) {
      // Non-interactive trailing icon
      suffix = Padding(
        padding: const EdgeInsets.only(right: 15),
        child: widget.trailing,
      );
    }

    final textField = TextFormField(
      onTap: widget.onTap,
      readOnly: widget.readOnly,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      obscureText: _obscure,
      onChanged: widget.onChanged, // Add this line
      validator: widget.validator ??
              (value) => (value ?? '').isEmpty
              ? 'Enter ${widget.labelText ?? 'a value'}'
              : null,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontSize: widget.hintTextSize,
          fontFamily: 'Poppins',
          color: widget.hintTextColor,
          fontWeight: widget.hinttextWeight
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10),
          child: widget.leading,
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 0,
          minHeight: 0,
        ),
        suffixIcon: suffix,
        suffixIconConstraints: const BoxConstraints(
          minWidth: 0,
          minHeight: 0,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.radius),
          borderSide: BorderSide(color: widget.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.radius),
          borderSide: BorderSide(
              color: widget.borderColor, width: widget.borderWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.radius),
          borderSide: BorderSide(color: widget.borderColor, width: 3),
        ),
      ),
    );

    if (widget.labelText == null) {
      return textField;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText!,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: MyColors.blackColor,
          ),
        ),
        const SizedBox(height: 8),
        textField,
      ],
    );
  }
}