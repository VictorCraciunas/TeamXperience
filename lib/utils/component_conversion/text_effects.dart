import 'package:flutter/material.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/utils/color_conversion.dart';

/// The extras of a text: spacing, line height, italic, capitals, glow and
/// shadow. Everything left out looks as a text always looked.
class TextEffects {
  const TextEffects({
    this.letterSpacing,
    this.lineHeight,
    this.italic = false,
    this.uppercase = false,
    this.glowColor,
    this.shadowColor,
    this.shadowBlur = 0,
    this.shadowDistance = 0,
  });

  /// The effects chosen on a text component.
  factory TextEffects.fromComponent(Component component) {
    final colors = ColorConversion();
    final glowing = component.enableGlow == true;

    return TextEffects(
      letterSpacing: component.letterSpacing,
      lineHeight: component.lineHeight,
      italic: component.italic == true,
      uppercase: component.uppercase == true,
      glowColor: glowing ? colors.hexToColor(component.glowColor ?? component.textColor) : null,
      shadowColor: component.shadowColor == null ? null : colors.hexToColor(component.shadowColor),
      shadowBlur: component.shadowBlur ?? 0,
      shadowDistance: component.shadowDistance ?? 0,
    );
  }

  final double? letterSpacing;
  final double? lineHeight;
  final bool italic;
  final bool uppercase;

  /// The colour of the glow; null means no glow.
  final Color? glowColor;
  final Color? shadowColor;
  final double shadowBlur;
  final double shadowDistance;

  /// The usual dark shadow when no colour was chosen.
  static const _defaultShadow = Color(0xD9000000);

  /// The text as it is shown.
  String apply(String text) => uppercase ? text.toUpperCase() : text;

  /// The shadow first, so it is painted behind the glow.
  List<Shadow>? get shadows {
    final result = <Shadow>[
      if (shadowBlur > 0 || shadowDistance > 0)
        Shadow(
          color: shadowColor ?? _defaultShadow,
          blurRadius: shadowBlur,
          offset: Offset(shadowDistance, shadowDistance),
        ),
      if (glowColor case final glow?) ...[
        Shadow(color: glow, blurRadius: 6),
        Shadow(color: glow, blurRadius: 16),
      ],
    ];
    return result.isEmpty ? null : result;
  }

  /// [base] with the effects on top.
  TextStyle style(TextStyle base) {
    return base.copyWith(
      letterSpacing: letterSpacing,
      height: lineHeight,
      fontStyle: italic ? FontStyle.italic : null,
      shadows: shadows,
    );
  }
}
