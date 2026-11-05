import 'package:flutter/material.dart';
import 'package:teamxperience/enums/event_look.dart';
import 'package:teamxperience/features/game_intro/widgets/game_intro_view.dart';
import 'package:teamxperience/ui/components/misc/segmented_switch.dart';
import 'package:teamxperience/ui/ui.dart';

import 'sample_event.dart';

/// The intro letter of mockup 05, in parchment and in the app's own look.
class GameIntroPreview extends StatefulWidget {
  const GameIntroPreview({super.key});

  @override
  State<GameIntroPreview> createState() => _GameIntroPreviewState();
}

class _GameIntroPreviewState extends State<GameIntroPreview> {
  EventLook _look = EventLook.parchment;

  @override
  Widget build(BuildContext context) {
    final event = sampleEvent()..look = _look;
    final palette = paletteFor(_look, context.colors);
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
                  labels: const ['Pergament', 'Aplicație'],
                  selectedIndex: _look == EventLook.parchment ? 0 : 1,
                  onSelected: (i) => setState(() => _look = i == 0 ? EventLook.parchment : EventLook.app),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
