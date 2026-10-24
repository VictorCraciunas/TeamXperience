/// The look an organiser sets once for the whole event. Every new component
/// starts with these values; changing them later does not rewrite components
/// that already exist. Colours are hex strings like the rest of `Component`.
class EventDefaults {
  const EventDefaults({
    this.backgroundColor,
    this.textColor,
    this.accentColor,
    this.fontFamily,
  });

  final String? backgroundColor;
  final String? textColor;
  final String? accentColor;
  final String? fontFamily;

  /// Null when nothing is set, so events without defaults stay without.
  static EventDefaults? fromMap(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) return null;
    return EventDefaults(
      backgroundColor: map['backgroundColor'] as String?,
      textColor: map['textColor'] as String?,
      accentColor: map['accentColor'] as String?,
      fontFamily: map['fontFamily'] as String?,
    );
  }

  /// Only the values that are set.
  Map<String, dynamic> toJson() {
    return {
      if (backgroundColor != null) 'backgroundColor': backgroundColor,
      if (textColor != null) 'textColor': textColor,
      if (accentColor != null) 'accentColor': accentColor,
      if (fontFamily != null) 'fontFamily': fontFamily,
    };
  }
}
