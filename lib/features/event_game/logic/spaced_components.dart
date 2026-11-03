import 'package:flutter/material.dart';
import 'package:teamxperience/enums/screen_animation.dart';
import 'package:teamxperience/features/event_game/logic/entrance.dart';

/// The space between two components when the organiser did not choose one.
const double defaultComponentGap = 40;

/// The components of a puzzle, each coming in with its own progress in
/// [animations] in the way [mode] says, with the gap the organiser chose under
/// it ([spaces], null or missing means [defaultComponentGap]). There is no gap
/// after the last one. The movement is only drawn: the layout never changes.
List<Widget> spacedComponents(
  List<Widget> components,
  List<Animation<double>> animations,
  List<double?> spaces, {
  ScreenAnimation mode = ScreenAnimation.fade,
}) {
  final result = <Widget>[];

  for (var i = 0; i < components.length; i++) {
    final progress = i < animations.length ? animations[i].value : 1.0;
    result.add(_entering(components[i], entranceFrame(mode, progress)));

    if (i < components.length - 1) {
      final chosen = i < spaces.length ? spaces[i] : null;
      result.add(SizedBox(height: chosen ?? defaultComponentGap));
    }
  }
  return result;
}

Widget _entering(Widget child, EntranceFrame frame) {
  final moved =
      frame.isMoved
          ? Transform(
            alignment: Alignment.center,
            transform:
                Matrix4.translationValues(frame.dx, frame.dy, 0)..scaleByDouble(frame.scale, frame.scale, 1, 1),
            child: child,
          )
          : child;

  return Opacity(opacity: frame.opacity, child: moved);
}
