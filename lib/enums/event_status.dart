/// Whether an event is still being built (visible only to organisers) or is
/// live for players. A document without a status is a published event.
enum EventStatus {
  draft,
  published;

  /// Reads the stored name; anything missing or unknown is [published], so
  /// events saved before drafts existed keep working.
  static EventStatus fromName(String? name) {
    for (final status in EventStatus.values) {
      if (status.name == name) return status;
    }
    return EventStatus.published;
  }
}
