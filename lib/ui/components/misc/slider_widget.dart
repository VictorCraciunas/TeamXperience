import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

class SliderWidget extends StatelessWidget {
  final String title;
  final double min;
  final double max;
  final int divisions;
  final double value;
  final String label;
  final ValueChanged<double> onChanged;

  const SliderWidget({super.key,
    required this.title,
    required this.min,
    required this.max,
    required this.divisions,
    required this.value,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: context.colors.accent, width: 1.5),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Slider(
            min: min,
            max: max,
            divisions: divisions,
            value: value,
            label: label,
            activeColor: context.colors.accent,
            inactiveColor: context.colors.muted.withValues(alpha: 0.3),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}