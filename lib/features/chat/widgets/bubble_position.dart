import 'package:flutter/material.dart';

enum BubblePosition { single, first, middle, last }

BorderRadius bubbleRadius(bool isMe, BubblePosition position) {
  const r = Radius.circular(22);
  const t = Radius.circular(6);

  if (isMe) {
    switch (position) {
      case BubblePosition.single:
        return const BorderRadius.only(
            topLeft: r, topRight: r, bottomRight: t, bottomLeft: r);
      case BubblePosition.first:
        return const BorderRadius.only(
            topLeft: r, topRight: r, bottomRight: t, bottomLeft: r);
      case BubblePosition.middle:
        return const BorderRadius.only(
            topLeft: r, topRight: t, bottomRight: t, bottomLeft: r);
      case BubblePosition.last:
        return const BorderRadius.only(
            topLeft: r, topRight: t, bottomRight: r, bottomLeft: r);
    }
  } else {
    switch (position) {
      case BubblePosition.single:
        return const BorderRadius.only(
            topLeft: r, topRight: r, bottomRight: r, bottomLeft: t);
      case BubblePosition.first:
        return const BorderRadius.only(
            topLeft: r, topRight: r, bottomRight: r, bottomLeft: t);
      case BubblePosition.middle:
        return const BorderRadius.only(
            topLeft: t, topRight: r, bottomRight: r, bottomLeft: t);
      case BubblePosition.last:
        return const BorderRadius.only(
            topLeft: t, topRight: r, bottomRight: r, bottomLeft: r);
    }
  }
}
