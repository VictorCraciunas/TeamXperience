import 'package:flutter/material.dart';
import 'package:teamxperience/features/events_tab/logic/event_card_texts.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/event/open_event_card.dart';
import 'package:teamxperience/ui/components/event/registered_event_tile.dart';
import 'package:teamxperience/ui/components/misc/section_header.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/utils/event_formats.dart';

/// The Evenimente list: "Înscrierile tale", "Deschise pentru înscriere" and
/// "În curând"; an empty section is left out.
class EventsList extends StatelessWidget {
  const EventsList({
    super.key,
    required this.sections,
    required this.teamNames,
    required this.teamCounts,
    required this.now,
    required this.onOpen,
    required this.onShare,
    required this.onAll,
  });

  final ({List<Event> registered, List<Event> open, List<Event> soon}) sections;
  final Map<String, String> teamNames;
  final Map<String, int> teamCounts;
  final DateTime now;
  final void Function(Event) onOpen;
  final void Function(Event) onShare;
  final VoidCallback onAll;

  @override
  Widget build(BuildContext context) {
    final (:registered, :open, :soon) = sections;
    if (registered.isEmpty && open.isEmpty && soon.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 32, 14, 0),
        child: Column(
          children: [
            Text(
              'Niciun eveniment nu se potrivește.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, height: 1.45, color: context.colors.muted),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: onAll,
              behavior: HitTestBehavior.opaque,
              child: Text(
                'Arată toate',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.45, color: context.colors.accent),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (registered.isNotEmpty) ...[
          const SectionHeader(title: 'Înscrierile tale'),
          _cards([for (final e in registered) _registered(e)]),
        ],
        if (open.isNotEmpty) ...[
          SectionHeader(title: 'Deschise pentru înscriere', trailing: '${open.length}'),
          _cards([for (final e in open) _openCard(e)]),
        ],
        if (soon.isNotEmpty) ...[
          const SectionHeader(title: 'În curând'),
          _cards([for (final e in soon) _openCard(e)]),
        ],
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _cards(List<Widget> cards) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < cards.length; i++) ...[if (i > 0) const SizedBox(height: 8), cards[i]],
          ],
        ),
      );

  Widget _registered(Event e) {
    final date = e.dateEvent;
    final until = date == null ? '' : untilText(now, date);
    final team = teamNames[e.eventId];
    return RegisteredEventTile(
      day: date == null ? '–' : '${date.day}',
      month: date == null ? '' : shortMonth(date.month),
      title: e.name ?? '',
      subtitle: team == null ? until : '$team · $until',
      badge: 'Înscriși',
      onTap: () => onOpen(e),
    );
  }

  Widget _openCard(Event e) {
    final date = e.dateEvent;
    return OpenEventCard(
      imageUrl: e.landingImageUrl,
      badge: spotsBadge(e.maxTeams, teamCounts[e.eventId] ?? 0),
      title: e.name ?? '',
      date: date == null ? '' : cardDate(date),
      facts: cardRouteFacts(e),
      onTap: () => onOpen(e),
      onShare: () => onShare(e),
    );
  }
}
