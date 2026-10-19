import 'package:flutter/material.dart';

import 'app_text_field.dart';

/// Legacy text field kept so existing screens keep compiling. It renders an
/// [AppTextField]; the styling parameters below are accepted but ignored, the
/// theme decides the look. New code should use [AppTextField] directly.
class MyTextField extends StatelessWidget {
  const MyTextField({
    super.key,
    this.controller,
    this.labelText,
    this.labelFontSize = 15,
    this.labelFontWeight = FontWeight.w500,
    this.borderColor,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.leading,
    this.trailing,
    this.hintText,
    this.validator,
    this.onChanged,
    this.borderWidth,
    this.radius,
    this.readOnly = false,
    this.maxLines = 1,
    this.hintTextColor,
    this.hintTextSize,
    this.hinttextWeight,
    this.onTap,
    this.validateRequired = true,
  });

  final TextEditingController? controller;
  final String? labelText;
  final double labelFontSize;
  final FontWeight labelFontWeight;
  final Color? borderColor;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? leading;
  final Widget? trailing;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final double? borderWidth;
  final double? radius;
  final bool readOnly;
  final int? maxLines;
  final Color? hintTextColor;
  final double? hintTextSize;
  final FontWeight? hinttextWeight;
  final VoidCallback? onTap;

  /// When no [validator] is given, require a non-empty value (the behaviour
  /// this widget always had). Set to false for optional fields.
  final bool validateRequired;

  String? _defaultValidator(String? value) {
    if (!validateRequired) return null;
    return (value ?? '').isEmpty ? 'Introdu ${labelText ?? 'a value'}' : null;
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: labelText,
      hint: hintText,
      validator: validator ?? _defaultValidator,
      obscure: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      readOnly: readOnly,
      onTap: onTap,
      leading: leading,
      trailing: trailing,
      onChanged: onChanged,
    );
  }
}
