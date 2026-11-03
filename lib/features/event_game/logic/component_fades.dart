import 'package:flutter/material.dart';
import 'package:teamxperience/enums/screen_animation.dart';
import 'package:teamxperience/features/event_game/logic/entrance.dart';

/// The progress, from 0 to 1, of the entrance of each component of a puzzle,
/// driven by [parent]. With anything but [ScreenAnimation.none] the components
/// come in one after another following [timing]; with [none] every component is
/// in place from the start.
List<Animation<double>> componentFades(
  Animation<double> parent,
  int count,
  ScreenAnimation mode, {
  EntranceTiming timing = const EntranceTiming(),
}) {
  if (mode == ScreenAnimation.none) {
    return List.generate(count, (_) => const AlwaysStoppedAnimation<double>(1.0));
  }

  return List.generate(count, (index) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(timing.start(index, count), timing.end(index, count), curve: Curves.easeIn),
      ),
    );
  });
}

/// Starts the entrance of a puzzle of [count] components: plays it from the
/// beginning over the time [timing] needs, or for [ScreenAnimation.none] shows
/// everything at once.
void startEntrance(
  AnimationController controller,
  ScreenAnimation mode, {
  int count = 1,
  EntranceTiming timing = const EntranceTiming(),
}) {
  if (mode == ScreenAnimation.none) {
    controller.value = 1.0;
    return;
  }
  controller.duration = timing.total(count);
  controller.reset();
  controller.forward();
}
