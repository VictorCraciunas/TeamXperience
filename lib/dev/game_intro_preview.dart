import 'package:flutter/material.dart';
import 'package:teamxperience/features/event_game/logic/style_hints.dart';
import 'package:teamxperience/features/game_intro/widgets/game_intro_view.dart';
import 'package:teamxperience/ui/components/misc/segmented_switch.dart';
import 'package:teamxperience/ui/ui.dart';

import 'sample_event.dart';

/// The intro letter of mockup 05, dressed from the sample event's parchment
/// puzzles, and from an event whose puzzles set no colours (the app's).
class GameIntroPreview extends StatefulWidget {
  const GameIntroPreview({super.key});

  @override
  State<GameIntroPreview> createState() => _GameIntroPreviewState();
}

class _GameIntroPreviewState extends State<GameIntroPreview> {
  bool _parchment = true;

  @override
  Widget build(BuildContext context) {
    final sample = sampleEvent();
    final event = _parchment ? sample : (sample
      ..missions = []
      ..defaults = null);
    final palette = eventPaletteOf(event, context.colors);
    return Scaffold(
      backgroundColor: palette.background,
      body: Column(
        children: [
          Expanded(
            child: EventThemeScope(
              palette: palette,
              child: GameIntroView(
                event: event,
                onStart: () => ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(const SnackBar(content: Text('start'))),
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
                  labels: const ['Din puzzle-uri', 'Fără culori'],
                  selectedIndex: _parchment ? 0 : 1,
                  onSelected: (i) => setState(() => _parchment = i == 0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
