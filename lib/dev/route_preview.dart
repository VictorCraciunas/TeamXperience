import 'package:flutter/material.dart';
import 'package:teamxperience/features/event_game/logic/style_hints.dart';
import 'package:teamxperience/features/event_game/logic/trail_layout.dart';
import 'package:teamxperience/features/event_game/widgets/game_backdrop.dart';
import 'package:teamxperience/features/event_game/widgets/game_route_view.dart';
import 'package:teamxperience/ui/components/misc/segmented_switch.dart';
import 'package:teamxperience/ui/ui.dart';

import 'sample_event.dart';

/// The route of mockup 06 for the sample event, dressed from its parchment
/// puzzles or from the same event with black and green puzzles.
class RoutePreview extends StatefulWidget {
  const RoutePreview({super.key});

  @override
  State<RoutePreview> createState() => _RoutePreviewState();
}

class _RoutePreviewState extends State<RoutePreview> {
  bool _neon = false;

  void _say(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final event = _neon ? neonSampleEvent() : sampleEvent();
    final palette = eventPaletteOf(event, context.colors);
    return Scaffold(
      backgroundColor: palette.background,
      body: Column(
        children: [
          Expanded(
            child: EventThemeScope(
              palette: palette,
              child: GameBackdrop(
                child: SafeArea(
                  bottom: false,
                  child: GameRouteView(
                    eventName: event.name ?? '',
                    placeLine: 'Vulpile · locul 2 din 12',
                    played: '0:42:18',
                    left: '1:17:42',
                    stops: trailStops(event, 3, 'la 180 m de tine'),
                    onClose: () => Navigator.maybePop(context),
                    onChat: () => _say('chat'),
                    onContinue: () => _say('continuă'),
                  ),
                ),
              ),
            ),
          ),
          ColoredBox(
            color: context.colors.page,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: SegmentedSwitch(
                  labels: const ['Pergament', 'Neon'],
                  selectedIndex: _neon ? 1 : 0,
                  onSelected: (i) => setState(() => _neon = i == 1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
