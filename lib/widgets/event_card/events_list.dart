import 'package:flutter/material.dart';
import '../../model/event.dart';
import '../../widgets/event_card/event_card.dart';

class EventsList extends StatelessWidget {
  final List<Event> events;
  final Function(Event) onEventTap;
  final bool isAdmin;
  final bool shrinkWrap; // Add this parameter to control behavior

  const EventsList({
    super.key,
    required this.events,
    required this.onEventTap,
    this.isAdmin = false,
    this.shrinkWrap = false, // Default to ListView behavior
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Center(
        child: Text('No events available'),
      );
    }

    // If shrinkWrap is true, use Column instead of ListView
    if (shrinkWrap) {
      return Column(
        children: events.map((event) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: EventCard(
              event: event,
              onTap: () => onEventTap(event),
              isAdmin: isAdmin,
            ),
          );
        }).toList(),
      );
    }

    // Default ListView behavior
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: EventCard(
            event: event,
            onTap: () => onEventTap(event),
            isAdmin: isAdmin,
          ),
        );
      },
    );
  }
}