import 'package:flutter/cupertino.dart';
import 'package:teamxperience/widgets/registered_events/registered_event_card.dart';

import '../../model/event.dart';

class RegisteredEventsList extends StatelessWidget {
  final List<Event> events;
  final Function(Event) onEventTap;
  final bool shrinkWrap;

  const RegisteredEventsList({
    super.key,
    required this.events,
    required this.onEventTap,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Center(
        child: Text('Încă nu sunt evenimente programate'),
      );
    }
    if (shrinkWrap) {
      return Column(
        children: [
          for (final event in events)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: RegisteredEventCard(
                event: event,
                onEventTap: onEventTap,
              ),
            ),
        ],
      );
    }
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: RegisteredEventCard(
            event: event,
            onEventTap: onEventTap,
          ),
        );
      },
    );
  }
}
