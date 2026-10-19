import 'package:flutter/material.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/event/event_card.dart';

class EventsCarousel extends StatefulWidget {
  final List<Event> events;
  final Function(Event) onEventTap;
  final bool isAdmin;
  final Map<String, Map<String, int>> eventStats;

  const EventsCarousel({
    super.key,
    required this.events,
    required this.onEventTap,
    this.isAdmin = false,
    required this.eventStats,
  });

  @override
  State<EventsCarousel> createState() => _EventsCarouselState();
}

class _EventsCarouselState extends State<EventsCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.events.isEmpty) {
      return const Center(
        child: Text('Încă nu sunt evenimente programate'),
      );
    }

    return Column(
      children: [
        // Horizontal scrollable event cards - let the card determine its own height
        SizedBox(
          width: double.infinity,
          height: 282, // Increased height to accommodate your EventCard's natural size
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.events.length,
            itemBuilder: (context, index) {
              final event = widget.events[index];
              final stats = widget.eventStats[event.eventId] ?? {'nrTeams': 0, 'nrPerson': 0};

              return EventCard(
                event: event,
                onTap: () => widget.onEventTap(event),
                isAdmin: widget.isAdmin,
                nrTeams: stats['nrTeams'] ?? 0,
                nrPerson: stats['nrPerson'] ?? 0,
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Dots indicator
        _buildDotsIndicator(),
      ],
    );
  }

  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.events.length,
            (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: _currentIndex == index ? 34.0 : 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            color: _currentIndex == index
                ? MyColors.lightBlue
                : const Color(0x2453C4C7),
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
      ),
    );
  }
}