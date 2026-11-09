import 'package:flutter/material.dart';

import '../../theme/app_radius.dart';
import '../../theme/theme_context.dart';

class AppDropdownItem<T> {
  const AppDropdownItem({required this.value, required this.label});

  final T value;
  final String label;
}

/// A labelled dropdown that matches [AppTextField]: panel fill, themed
/// border, error state and the same label style.
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.label,
    this.hint = 'Selectează o opțiune',
    this.validator,
    this.leading,
  });

  final List<AppDropdownItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String hint;
  final String? Function(T?)? validator;
  final Widget? leading;

  OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final title = label;
    final selected = items.any((item) => item.value == value) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title,
            style: TextStyle(color: colors.text, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
        ],
        DropdownButtonFormField<T>(
          initialValue: selected,
          key: ValueKey(selected),
          isExpanded: true,
          onChanged: onChanged,
          validator: validator,
          icon: Icon(Icons.keyboard_arrow_down, color: colors.text),
          dropdownColor: colors.panel,
          borderRadius: BorderRadius.circular(AppRadius.card),
          style: TextStyle(color: colors.text, fontSize: 16),
          hint: Text(hint, style: TextStyle(color: colors.muted, fontSize: 16)),
          items: [
            for (final item in items)
              DropdownMenuItem<T>(
                value: item.value,
                child: Text(item.label, overflow: TextOverflow.ellipsis),
              ),
          ],
          decoration: InputDecoration(
            filled: true,
            fillColor: colors.panel,
            prefixIcon: leading,
            errorStyle: TextStyle(color: colors.live, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: _border(colors.border, 1.5),
            enabledBorder: _border(colors.border, 1.5),
            focusedBorder: _border(colors.tick, 2),
            errorBorder: _border(colors.live, 1.5),
            focusedErrorBorder: _border(colors.live, 2),
          ),
        ),
      ],
    );
  }
}
