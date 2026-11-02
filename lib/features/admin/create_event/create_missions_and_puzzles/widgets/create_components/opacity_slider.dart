import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/misc/slider_widget.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

/// How visible a component is, from 0 % to 100 % in steps of 5. A component
/// with no opacity set ([value] null) is fully visible. Reports 0 to 1.
class OpacitySlider extends StatelessWidget {
  const OpacitySlider({super.key, required this.value, required this.onChanged});

  final double? value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final percent = ((value ?? 1) * 100).clamp(0, 100).toDouble();
    final text = '${percent.round()} %';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SliderWidget(
          title: 'Opacitate',
          min: 0,
          max: 100,
          divisions: 20,
          value: percent,
          label: text,
          onChanged: (v) => onChanged(v / 100),
        ),
        const SizedBox(height: 4),
        Text(text, style: TextStyle(color: context.colors.muted, fontSize: 12)),
      ],
    );
  }
}
