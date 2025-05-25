import 'package:flutter/material.dart';

import '../constants/colors.dart';

/// A reusable labeled dropdown field that displays a label above
/// a dropdown button, with customizable styling and behavior.
class MyDropdownField<T> extends StatelessWidget {
  /// The list of dropdown items to display.
  final List<DropdownMenuItem<T>> items;

  /// The currently selected value.
  final T? value;

  /// Callback function triggered when the selection changes.
  final void Function(T?)? onChanged;

  /// The text label displayed above the dropdown.
  final String labelText;

  /// Font size of the label.
  final double labelFontSize;

  /// Font weight of the label.
  final FontWeight labelFontWeight;

  /// Color of the dropdown's border.
  final Color borderColor;

  /// Width of the border when enabled.
  final double borderWidth;

  /// Radius of the border's corners.
  final double radius;

  /// Optional hint widget displayed when no value is selected.
  final Widget? hint;

  /// Optional validator function to validate the selection.
  final String? Function(T?)? validator;

  /// Optional widget displayed before the dropdown (prefix icon).
  final Widget? leading;

  /// Optional custom icon for the dropdown button (replaces the default arrow).
  final Widget? dropdownIcon;

  /// Padding inside the dropdown field.
  final EdgeInsets? contentPadding;

  /// Text style for the selected item.
  final TextStyle? selectedItemStyle;

  /// Whether the dropdown menu expands to the field's width.
  final bool isExpanded;

  const MyDropdownField({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.labelText,
    this.labelFontSize = 15,
    this.labelFontWeight = FontWeight.w500,
    this.borderColor = const Color(0xFFE6E6E6),
    this.borderWidth = 2,
    this.radius = 50,
    this.hint,
    this.validator,
    this.leading,
    this.dropdownIcon,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    this.selectedItemStyle,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: labelFontSize,
            fontWeight: labelFontWeight,
              color: MyColors.blackColor
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          hint: hint,
          validator: validator,
          style: selectedItemStyle,
          icon: dropdownIcon,
          isExpanded: isExpanded,
          decoration: InputDecoration(
            prefixIcon: leading != null
                ? Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10),
              child: leading,
            )
                : null,
            prefixIconConstraints: leading != null
                ? const BoxConstraints(minWidth: 0, minHeight: 0)
                : null,
            contentPadding: contentPadding,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(color: borderColor, width: borderWidth),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(color: borderColor, width: borderWidth),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(color: borderColor, width: borderWidth + 1),
            ),
          ),
        ),
      ],
    );
  }
}