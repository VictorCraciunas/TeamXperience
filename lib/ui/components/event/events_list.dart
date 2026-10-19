import 'package:flutter/material.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/event/event_card.dart';

class EventsList extends StatelessWidget {
  final List<Event> events;
  final Function(Event) onEventTap;
  final bool isAdmin;
  final bool shrinkWrap; // Add this parameter to control behavior
  final Map<String, Map<String, int>> eventStats;

  const EventsList({
    super.key,
    required this.events,
    required this.onEventTap,
    this.isAdmin = false,
    this.shrinkWrap = false, // Default to ListView behavior
    required this.eventStats,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Center(
        child: Text('Încă nu sunt evenimente programate'),
      );
    }

    // If shrinkWrap is true, use Column instead of ListView
    if (shrinkWrap) {
      return Column(
        children: events.map((event) {
          final stats = eventStats[event.eventId] ?? {'nrTeams': 0, 'nrPerson': 0};
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: EventCard(
              event: event,
              onTap: () => onEventTap(event),
              isAdmin: isAdmin,
              nrTeams: stats['nrTeams'] ?? 0,
              nrPerson: stats['nrPerson'] ?? 0,
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
        final stats = eventStats[event.eventId] ?? {'nrTeams': 0, 'nrPerson': 0};
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: EventCard(
            event: event,
            onTap: () => onEventTap(event),
            isAdmin: isAdmin,
            nrTeams: stats['nrTeams'] ?? 0,
            nrPerson: stats['nrPerson'] ?? 0,
          ),
        );
      },
    );
  }
}