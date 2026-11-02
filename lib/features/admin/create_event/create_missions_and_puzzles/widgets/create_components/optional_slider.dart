import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/misc/slider_widget.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

/// A slider for a value the organiser may leave alone. While [value] is null the
/// [automaticValue] is shown, marked with [automaticNote]; moving the slider
/// reports a real value.
class OptionalSlider extends StatelessWidget {
  const OptionalSlider({
    super.key,
    required this.title,
    required this.min,
    required this.max,
    required this.divisions,
    required this.unit,
    required this.value,
    required this.automaticValue,
    required this.automaticNote,
    required this.onChanged,
  });

  final String title;
  final double min;
  final double max;
  final int divisions;
  final String unit;
  final double? value;
  final double automaticValue;
  final String automaticNote;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final shown = (value ?? automaticValue).clamp(min, max).toDouble();
    final text = '${shown.round()} $unit';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SliderWidget(
          title: title,
          min: min,
          max: max,
          divisions: divisions,
          value: shown,
          label: text,
          onChanged: onChanged,
        ),
        const SizedBox(height: 4),
        Text(
          value == null ? '$text ($automaticNote)' : text,
          style: TextStyle(color: context.colors.muted, fontSize: 12),
        ),
      ],
    );
  }
}
