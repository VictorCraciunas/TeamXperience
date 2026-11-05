import 'package:flutter/material.dart';
import 'package:teamxperience/features/game_intro/controller/game_intro_controller.dart';
import 'package:teamxperience/features/game_intro/widgets/game_intro_view.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/theme/event_palette.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';
import 'package:teamxperience/ui/ui.dart';

/// The intro letter before the first mission (mockup 05), in the event's
/// look. The route takes `{'event': Event, 'team': Team}`.
class GameIntroScreen extends StatefulWidget {
  const GameIntroScreen({super.key});

  @override
  State<GameIntroScreen> createState() => _GameIntroScreenState();
}

class _GameIntroScreenState extends State<GameIntroScreen> {
  GameIntroController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! Map) return;
    final event = args['event'];
    final team = args['team'];
    if (event is Event && team is Team) _controller = GameIntroController(event: event, team: team);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return Scaffold(backgroundColor: context.colors.page);
    final palette = paletteFor(controller.event.look, context.colors);
    return EventThemeScope(
      palette: palette,
      child: Scaffold(
        backgroundColor: palette.background,
        body: GameIntroView(
          event: controller.event,
          onStart: () => controller.start(Navigator.of(context)),
        ),
      ),
    );
  }
}
