import 'package:flutter/material.dart';
import 'package:teamxperience/features/admin/create_event/create_missions_and_puzzles/widgets/create_components/hex_color_field.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/ui/components/misc/slider_widget.dart';

/// The shadow of an image, a button or a code input: how soft, how far and what
/// colour. Written straight onto [component]; a value of 0 is not written, so a
/// component without a shadow stays as it was.
class BoxShadowControls extends StatelessWidget {
  const BoxShadowControls({super.key, required this.component, required this.onChanged});

  final Component component;

  /// Called after the component was changed, so the screen can redraw.
  final VoidCallback onChanged;

  void _setBlur(double value) {
    component.shadowBlur = value > 0 ? value : null;
    _clearColorWithoutShadow();
    onChanged();
  }

  void _setDistance(double value) {
    component.shadowDistance = value > 0 ? value : null;
    _clearColorWithoutShadow();
    onChanged();
  }

  void _clearColorWithoutShadow() {
    if (component.shadowBlur == null && component.shadowDistance == null) {
      component.shadowColor = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final blur = component.shadowBlur ?? 0;
    final distance = component.shadowDistance ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SliderWidget(
          title: 'Încețoșare umbră',
          min: 0,
          max: 30,
          divisions: 30,
          value: blur,
          label: blur.toStringAsFixed(0),
          onChanged: _setBlur,
        ),
        const SizedBox(height: 16),
        SliderWidget(
          title: 'Distanță umbră',
          min: 0,
          max: 20,
          divisions: 20,
          value: distance,
          label: distance.toStringAsFixed(0),
          onChanged: _setDistance,
        ),
        if (blur > 0 || distance > 0) ...[
          const SizedBox(height: 16),
          HexColorField(
            label: 'Culoare umbră',
            hex: component.shadowColor ?? '#000000',
            onChanged: (color) {
              component.shadowColor = color;
              onChanged();
            },
          ),
        ],
      ],
    );
  }
}
