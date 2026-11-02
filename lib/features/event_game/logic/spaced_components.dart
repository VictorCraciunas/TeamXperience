import 'package:flutter/material.dart';

/// The space between two components when the organiser did not choose one.
const double defaultComponentGap = 40;

/// The components of a puzzle, each fading in with its own animation, with the
/// gap the organiser chose under it ([spaces], null or missing means
/// [defaultComponentGap]). There is no gap after the last one.
List<Widget> spacedComponents(
  List<Widget> components,
  List<Animation<double>> animations,
  List<double?> spaces,
) {
  final result = <Widget>[];

  for (var i = 0; i < components.length; i++) {
    result.add(
      Opacity(
        opacity: i < animations.length ? animations[i].value : 1.0,
        child: components[i],
      ),
    );

    if (i < components.length - 1) {
      final chosen = i < spaces.length ? spaces[i] : null;
      result.add(SizedBox(height: chosen ?? defaultComponentGap));
    }
  }
  return result;
}
