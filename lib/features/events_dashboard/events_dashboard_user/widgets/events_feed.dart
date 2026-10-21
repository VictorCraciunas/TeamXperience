import 'package:flutter/material.dart';
import 'package:teamxperience/features/feed/logic/post_text.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/event/event_post_card.dart';
import 'package:teamxperience/ui/theme/theme_context.dart';

/// The player's vertical feed of event posts. Events that are over come last
/// and are dimmed; events the player registered for carry an "Înscris" tag.
class EventsFeed extends StatelessWidget {
  const EventsFeed({
    super.key,
    required this.upcoming,
    required this.registeredIds,
    required this.onTap,
    required this.onShare,
    this.past = const [],
    this.header,
    this.emptyMessage = 'Nu există evenimente',
  });

  final List<Event> upcoming;
  final List<Event> past;
  final Set<String> registeredIds;
  final void Function(Event event) onTap;
  final void Function(Event event) onShare;
  final String emptyMessage;

  /// Scrolls with the posts as the first item (search, filters).
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final total = upcoming.length + past.length;

    final top = header;
    final offset = top == null ? 0 : 1;

    if (total == 0) {
      return ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          if (top != null) top,
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Center(
              child: Text(emptyMessage, style: TextStyle(color: context.colors.muted, fontSize: 15)),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: total + offset,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, listIndex) {
        if (top != null && listIndex == 0) return top;
        final index = listIndex - offset;
        final isPast = index >= upcoming.length;
        final event = isPast ? past[index - upcoming.length] : upcoming[index];

        return EventPostCard(
          title: event.name ?? '',
          dateLabel: eventPosterDate(event),
          place: event.location ?? '',
          details: eventPostDetails(event),
          imageUrl: event.landingImageUrl,
          tag: registeredIds.contains(event.eventId) ? 'Înscris' : null,
          dimmed: isPast,
          onTap: () => onTap(event),
          onShare: () => onShare(event),
        );
      },
    );
  }
}
