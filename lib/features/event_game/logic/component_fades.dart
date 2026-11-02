import 'package:flutter/material.dart';
import 'package:teamxperience/enums/screen_animation.dart';

/// The fade of each component of a puzzle, driven by [parent]. With [fade] the
/// components appear one after another over the length of [parent]; with [none]
/// every component is fully visible from the start.
List<Animation<double>> componentFades(
  Animation<double> parent,
  int count,
  ScreenAnimation mode,
) {
  if (mode == ScreenAnimation.none) {
    return List.generate(count, (_) => const AlwaysStoppedAnimation<double>(1.0));
  }

  return List.generate(count, (index) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(index / count, (index + 1) / count, curve: Curves.easeIn),
      ),
    );
  });
}

/// Starts the entrance of a puzzle: plays the fade from the beginning, or for
/// [ScreenAnimation.none] shows everything at once.
void startEntrance(AnimationController controller, ScreenAnimation mode) {
  if (mode == ScreenAnimation.none) {
    controller.value = 1.0;
    return;
  }
  controller.reset();
  controller.forward();
}
