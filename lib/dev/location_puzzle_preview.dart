import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/features/event_game/logic/location_texts.dart';
import 'package:teamxperience/features/event_game/widgets/location_puzzle_view.dart';
import 'package:teamxperience/ui/ui.dart';

import 'puzzle_preview_frame.dart';
import 'sample_event.dart';

/// Mockup 07's location puzzle ("Unde dorm clopotele") on the way, inside the
/// circle and with location refused, in parchment or neon. The map is a
/// stand-in (no tiles in the gallery).
class LocationPuzzlePreview extends StatefulWidget {
  const LocationPuzzlePreview({super.key});

  @override
  State<LocationPuzzlePreview> createState() => _LocationPuzzlePreviewState();
}

class _LocationPuzzlePreviewState extends State<LocationPuzzlePreview> {
  bool _neon = false;
  int _state = 0;

  @override
  Widget build(BuildContext context) {
    final event = _neon ? neonSampleEvent() : sampleEvent();
    return PuzzlePreviewFrame(
      event: event,
      mission: 4,
      clock: '0:58:03',
      body: Builder(
        builder: (context) => LocationPuzzleView(
          state: _state == 2 ? LocationViewState.denied : LocationViewState.tracking,
          map: ColoredBox(
            color: context.eventPalette.ink.withValues(alpha: .08),
            child: Center(child: Icon(TablerIcons.map_2, size: 40, color: context.eventPalette.accent)),
          ),
          meters: _state == 1 ? 12 : 140,
          bearing: 40,
          trend: DistanceTrend.closer,
          inside: _state == 1,
          onEnter: () {},
          onHint: () {},
          onOpenSettings: () {},
        ),
      ),
      switches: [
        (const ['Pergament', 'Neon'], _neon ? 1 : 0, (i) => setState(() => _neon = i == 1)),
        (const ['Pe drum', 'În cerc', 'Fără acces'], _state, (i) => setState(() => _state = i)),
      ],
    );
  }
}
