import 'package:flutter/material.dart';
import 'package:teamxperience/features/event_game/logic/spaced_components.dart';
import 'package:teamxperience/ui/components/misc/slider_widget.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

/// How much space the game leaves under a component: 0 to 120 in steps of 5.
/// When nothing was chosen ([value] null) the usual gap is shown.
class SpaceBelowSlider extends StatelessWidget {
  const SpaceBelowSlider({super.key, required this.value, required this.onChanged});

  final double? value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final shown = value ?? defaultComponentGap;
    final text = '${shown.round()} px';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SliderWidget(
          title: 'Spațiu sub componentă',
          min: 0,
          max: 120,
          divisions: 24,
          value: shown.clamp(0, 120).toDouble(),
          label: text,
          onChanged: onChanged,
        ),
        const SizedBox(height: 4),
        Text(
          value == null ? '$text (implicit)' : text,
          style: TextStyle(color: context.colors.muted, fontSize: 12),
        ),
      ],
    );
  }
}
