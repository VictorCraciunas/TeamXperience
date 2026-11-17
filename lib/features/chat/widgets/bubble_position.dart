import 'package:flutter/material.dart';

import '../logic/bubble_position.dart';

export '../logic/bubble_position.dart';

/// The bubble's corners: round, with the small corner towards its sender and
/// flattened between bubbles of one run.
BorderRadius bubbleRadius(bool isMe, BubblePosition position) {
  const r = Radius.circular(18);
  const t = Radius.circular(6);

  if (isMe) {
    switch (position) {
      case BubblePosition.single:
      case BubblePosition.first:
        return const BorderRadius.only(topLeft: r, topRight: r, bottomRight: t, bottomLeft: r);
      case BubblePosition.middle:
        return const BorderRadius.only(topLeft: r, topRight: t, bottomRight: t, bottomLeft: r);
      case BubblePosition.last:
        return const BorderRadius.only(topLeft: r, topRight: t, bottomRight: t, bottomLeft: r);
    }
  } else {
    switch (position) {
      case BubblePosition.single:
      case BubblePosition.first:
        return const BorderRadius.only(topLeft: r, topRight: r, bottomRight: r, bottomLeft: t);
      case BubblePosition.middle:
        return const BorderRadius.only(topLeft: t, topRight: r, bottomRight: r, bottomLeft: t);
      case BubblePosition.last:
        return const BorderRadius.only(topLeft: t, topRight: r, bottomRight: r, bottomLeft: t);
    }
  }
}
