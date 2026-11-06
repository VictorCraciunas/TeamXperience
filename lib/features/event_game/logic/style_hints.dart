import 'package:flutter/painting.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/event_defaults.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';
import 'package:teamxperience/ui/theme/event_palette.dart';
import 'package:teamxperience/ui/theme/event_palette_resolver.dart';

/// A colour written as 6 hex digits (JSON) or as #aarrggbb (what the editor's
/// colour picker saves), with or without the #, as an opaque colour; null for
/// anything else and for a fully transparent one.
Color? _hex(String? value) {
  final text = (value ?? '').trim().replaceFirst('#', '');
  if (RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(text)) return Color(int.parse('FF$text', radix: 16));
  if (RegExp(r'^[0-9A-Fa-f]{8}$').hasMatch(text)) {
    if (int.parse(text.substring(0, 2), radix: 16) == 0) return null;
    return Color(int.parse('FF${text.substring(2)}', radix: 16));
  }
  return null;
}

/// The value seen most often; a tie goes to the first seen.
T? _mostCommon<T>(Iterable<T?> values) {
  final counts = <T, int>{};
  for (final value in values) {
    if (value != null) counts[value] = (counts[value] ?? 0) + 1;
  }
  T? best;
  var bestCount = 0;
  counts.forEach((value, count) {
    if (count > bestCount) {
      best = value;
      bestCount = count;
    }
  });
  return best;
}

/// What an event's components already use, falling back to its component
/// [defaults]: the accent from buttons (else code-field borders), the ink and
/// font from text pieces, the surface from code fields, the page from the
/// defaults (else code frames), the second accent from glows.
StyleHints styleHintsFrom(Iterable<Component> components, EventDefaults? defaults) {
  final all = components.toList();
  Iterable<Component> ofType(ComponentType type) => all.where((c) => c.type == type);
  Color? common(Iterable<Component> from, String? Function(Component) pick) =>
      _mostCommon(from.map((c) => _hex(pick(c))));

  final buttons = ofType(ComponentType.button);
  final texts = ofType(ComponentType.text);
  final codes = ofType(ComponentType.code);
  final fonts = texts.map((c) => c.fontFamily?.trim()).where((f) => f != null && f.isNotEmpty);

  return StyleHints(
    accent: common(buttons, (c) => c.buttonColor) ??
        common(codes, (c) => c.colorBorderInput) ??
        _hex(defaults?.accentColor),
    ink: common(texts, (c) => c.textColor) ?? _hex(defaults?.textColor),
    font: _mostCommon(fonts) ?? _blankToNull(defaults?.fontFamily),
    surface: common(codes, (c) => c.inputBackgroundColor) ?? common(all, (c) => c.frameBackgroundColor),
    background: _hex(defaults?.backgroundColor) ?? common(all, (c) => c.frameBackgroundColor),
    // The editor writes a glow colour on every code piece; only a glow that is
    // switched on is the organiser's choice.
    glow: common(all.where((c) => c.enableGlow == true), (c) => c.glowColor),
  );
}

String? _blankToNull(String? text) {
  final value = text?.trim() ?? '';
  return value.isEmpty ? null : value;
}

/// The picture behind the event's puzzles; null when the organiser set none
/// (the game screens then show the palette's page colour).
ImageProvider? gameBackgroundOf(Event event) {
  final url = event.taskBackgroundImageUrl?.trim() ?? '';
  if (url.isEmpty) return null;
  if (url.startsWith('http://') || url.startsWith('https://')) return NetworkImage(url);
  return AssetImage(url);
}

/// The palette of an event's game screens, from every component of every
/// puzzle of every mission. The one call screens use.
EventPalette eventPaletteOf(Event event, AppColors app) {
  final components = [
    for (final mission in event.missions)
      for (final puzzle in mission.puzzles) ...puzzle.components,
  ];
  return resolveEventPalette(
    hints: styleHintsFrom(components, event.defaults),
    app: app,
    backgroundImage: gameBackgroundOf(event),
  );
}
