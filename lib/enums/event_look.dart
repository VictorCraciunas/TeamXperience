/// How an event's own screens look, from the start code onwards.
enum EventLook {
  /// The app's own colours.
  app,

  /// The old-map look of mockups 05 to 08.
  parchment;

  /// The stored name, or [app] for a missing or unknown one.
  static EventLook fromName(String? name) =>
      EventLook.values.where((l) => l.name == name).firstOrNull ?? EventLook.app;
}
