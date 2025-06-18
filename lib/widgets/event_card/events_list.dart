import 'package:flutter/material.dart';
import '../../model/event.dart';
import '../../widgets/event_card/event_card.dart';

class EventsList extends StatelessWidget {
  final List<Event> events;
  final Function(Event) onEventTap;
  final bool isAdmin;

  const EventsList({
    super.key,
    required this.events,
    required this.onEventTap,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Center(
        child: Text('No events available'),
      );
    }

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