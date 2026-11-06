import 'package:flutter/material.dart';
import 'package:teamxperience/features/event_game/logic/trail_layout.dart';

import 'route_header.dart';
import 'route_trail_view.dart';

/// The route screen's content (mockup 06): the header, then the trail filling
/// the rest. Takes plain values, so the gallery shows the same thing.
class GameRouteView extends StatelessWidget {
  const GameRouteView({
    super.key,
    required this.eventName,
    required this.placeLine,
    required this.played,
    required this.left,
    required this.stops,
    required this.onClose,
    required this.onChat,
    required this.onContinue,
  });

  final String eventName;
  final String? placeLine;
  final String played;
  final String left;
  final List<TrailStop> stops;
  final VoidCallback onClose;
  final VoidCallback onChat;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RouteHeader(
          eventName: eventName,
          placeLine: placeLine,
          played: played,
          left: left,
          onClose: onClose,
          onChat: onChat,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: RouteTrailView(stops: stops, onContinue: onContinue),
          ),
        ),
      ],
    );
  }
}
