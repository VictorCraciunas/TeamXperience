import 'package:flutter/material.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/utils/color_conversion.dart';

/// The extras of an image, a button or a code input: opacity, a shadow, and for
/// an image a glow. (A text has its own, see `TextEffects`.) Everything left out
/// looks as the component always looked.
class BoxEffects {
  const BoxEffects({
    this.opacity,
    this.shadowColor,
    this.shadowBlur = 0,
    this.shadowDistance = 0,
    this.glowColor,
  });

  factory BoxEffects.fromComponent(Component component) {
    final colors = ColorConversion();

    return BoxEffects(
      opacity: component.opacity,
      shadowColor: component.shadowColor == null ? null : colors.hexToColor(component.shadowColor),
      shadowBlur: component.shadowBlur ?? 0,
      shadowDistance: component.shadowDistance ?? 0,
      glowColor: component.enableGlow == true ? colors.hexToColor(component.glowColor) : null,
    );
  }

  /// 0 (invisible) to 1; null means fully visible.
  final double? opacity;
  final Color? shadowColor;
  final double shadowBlur;
  final double shadowDistance;

  /// The colour of the glow; null means no glow.
  final Color? glowColor;

  /// The usual dark shadow when no colour was chosen.
  static const _defaultShadow = Color(0xD9000000);

  bool get hasShadow => shadowBlur > 0 || shadowDistance > 0;

  /// Just the shadow: for components that have their own glow.
  List<BoxShadow>? get shadowOnly {
    if (!hasShadow) return null;
    return [
      BoxShadow(
        color: shadowColor ?? _defaultShadow,
        blurRadius: shadowBlur,
        offset: Offset(shadowDistance, shadowDistance),
      ),
    ];
  }

  /// The shadow, then the glow on top of it.
  List<BoxShadow>? get shadowAndGlow {
    final result = <BoxShadow>[
      ...?shadowOnly,
      if (glowColor case final glow?)
        BoxShadow(color: glow.withValues(alpha: 0.7), blurRadius: 14, spreadRadius: 2),
    ];
    return result.isEmpty ? null : result;
  }

  /// Copies the options the editors set directly on a component (opacity and,
  /// when [shadow] is true, the shadow) onto the component a preview is built from.
  static void copy(Component from, Component to, {required bool shadow}) {
    to.opacity = from.opacity;
    if (!shadow) return;
    to.shadowColor = from.shadowColor;
    to.shadowBlur = from.shadowBlur;
    to.shadowDistance = from.shadowDistance;
  }

  /// [child] with the shadow around it, following corners of [radius].
  Widget shadowAround(Widget child, double radius) {
    final shadows = shadowOnly;
    if (shadows == null) return child;

    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius), boxShadow: shadows),
      child: child,
    );
  }

  /// [child] made see-through, when an opacity below 1 was chosen.
  Widget withOpacity(Widget child) {
    final value = opacity;
    if (value == null || value >= 1) return child;
    return Opacity(opacity: value, child: child);
  }
}
