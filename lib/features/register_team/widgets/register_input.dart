import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teamxperience/ui/theme/app_radius.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

/// The mockups' `.in` as a text field: a panel with a 1 px border, a 12
/// radius and 9 / 12 of padding (the border adds 1). [borderColor] replaces
/// the grey border, [trailing] sits at the right end inside the field.
class RegisterInput extends StatelessWidget {
  const RegisterInput({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hint,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.readOnly = false,
    this.borderColor,
    this.trailing,
    this.verticalPadding = 10,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final Color? borderColor;
  final Widget? trailing;
  final double verticalPadding;

  static const double _textSize = 12;

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.button),
    borderSide: BorderSide(color: color),
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final border = _border(borderColor ?? colors.border);
    final end = trailing;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      readOnly: readOnly,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      cursorColor: colors.accent,
      style: TextStyle(fontSize: _textSize, height: 1.45, color: colors.text),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: colors.panel,
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: _textSize,
          height: 1.45,
          color: colors.muted,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 13,
          vertical: verticalPadding,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: _border(borderColor ?? colors.tick),
        suffixIcon:
            end == null
                ? null
                : Padding(
                  padding: const EdgeInsets.only(left: 8, right: 13),
                  child: end,
                ),
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }
}
