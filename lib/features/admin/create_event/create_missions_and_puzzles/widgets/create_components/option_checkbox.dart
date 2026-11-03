import 'package:flutter/material.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

/// A labelled checkbox of the component editors. Tapping the label toggles it too.
class OptionCheckbox extends StatelessWidget {
  const OptionCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Transform.scale(
            scale: 1.5,
            child: Checkbox(
              value: value,
              onChanged: (checked) => onChanged(checked ?? false),
              activeColor: colors.accent,
              checkColor: colors.onTick,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              side: BorderSide(width: 1.5, color: colors.accent),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: colors.text),
          ),
        ],
      ),
    );
  }
}
