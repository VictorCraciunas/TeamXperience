import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/event/registered_event_card.dart';

class RegisteredEventsCarousel extends StatefulWidget {
  final List<Event> events;
  final Function(Event) onEventTap;

  const RegisteredEventsCarousel({
    super.key,
    required this.events,
    required this.onEventTap,
  });

  @override
  State<RegisteredEventsCarousel> createState() => _RegisteredEventsCarouselState();
}

class _RegisteredEventsCarouselState extends State<RegisteredEventsCarousel> {
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
        child: Text('No registered events'),
      );
    }

    return Column(
      children: [
        // Horizontal scrollable registered event cards
        SizedBox(
          width: double.infinity,
          height: 165, // Adjusted height for RegisteredEventCard
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
              return RegisteredEventCard(
                event: event,
                onEventTap: widget.onEventTap,
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
                ? context.colors.accent
                : const Color(0x2453C4C7),
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
      ),
    );
  }
}