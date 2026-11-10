import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/components/event/open_event_card.dart';
import 'package:teamxperience/ui/components/event/registered_event_tile.dart';
import 'package:teamxperience/ui/components/misc/pill_switch.dart';
import 'package:teamxperience/ui/components/misc/section_header.dart';

/// The Evenimente list pieces with the copy of mockup 03.
class EventsGallery extends StatefulWidget {
  const EventsGallery({super.key});

  @override
  State<EventsGallery> createState() => _EventsGalleryState();
}

class _EventsGalleryState extends State<EventsGallery> {
  int _mode = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: PillSwitch(
            options: const [(TablerIcons.list, 'Listă'), (TablerIcons.map, 'Hartă')],
            selected: _mode,
            onSelected: (i) => setState(() => _mode = i),
          ),
        ),
        const SectionHeader(title: 'Înscrierile tale'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: RegisteredEventTile(
            day: '14',
            month: 'nov',
            title: 'Moștenirea Cartografului',
            subtitle: 'Vulpile · peste 3 zile',
            badge: 'Înscriși',
            onTap: () {},
          ),
        ),
        const SectionHeader(title: 'Deschise pentru înscriere', trailing: '4'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: OpenEventCard(
            badge: 'Mai sunt 2 locuri',
            title: 'Protocolul Cerber',
            date: 'Sâm 21 nov',
            facts: '3,2 km · 1 h 30',
            onTap: () {},
            onShare: () {},
          ),
        ),
      ],
    );
  }
}
