import 'package:flutter/widgets.dart';

import 'event_palette.dart';
import 'theme_context.dart';

/// Gives the screens below it an event's own colours.
class EventThemeScope extends InheritedWidget {
  const EventThemeScope({super.key, required this.palette, required super.child});

  final EventPalette palette;

  @override
  bool updateShouldNotify(EventThemeScope oldWidget) => palette != oldWidget.palette;
}

extension EventPaletteContext on BuildContext {
  /// The nearest event's colours, or the app's own when there is no event.
  EventPalette get eventPalette =>
      dependOnInheritedWidgetOfExactType<EventThemeScope>()?.palette ?? EventPalette.fromApp(colors);
}
