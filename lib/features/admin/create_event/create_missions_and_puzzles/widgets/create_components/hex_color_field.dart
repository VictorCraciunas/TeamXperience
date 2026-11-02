import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/inputs/app_text_field.dart';
import 'package:teamxperience/ui/components/misc/color_picker_dialog.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';
import 'package:teamxperience/utils/color_conversion.dart';

/// A field that shows a colour and opens the colour picker when tapped.
/// [hex] is the colour as saved in a component; [onChanged] gets the new one.
class HexColorField extends StatelessWidget {
  const HexColorField({
    super.key,
    required this.label,
    required this.hex,
    required this.onChanged,
  });

  final String label;
  final String hex;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final color = ColorConversion().hexToColor(hex);

    return AppTextField(
      hint: label,
      readOnly: true,
      onTap: () => ColorPickerDialog.show(context, label, color, onChanged),
      trailing: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: context.colors.border),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
