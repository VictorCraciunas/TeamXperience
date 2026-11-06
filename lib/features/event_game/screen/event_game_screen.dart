import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/features/event_game/logic/route_texts.dart';
import 'package:teamxperience/features/event_game/logic/style_hints.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/state_management/user_provider.dart';
import 'package:teamxperience/state_management/user_registered_events.dart';
import 'package:teamxperience/ui/ui.dart';

import '../../../constants/routes.dart';
import '../../../model/event.dart';
import '../controller/event_game_controller.dart';
import '../widgets/game_backdrop.dart';
import '../widgets/game_route_view.dart';
import '../widgets/keeps_presence.dart';
import '../widgets/refreshes_active_game.dart';

/// The mission route in the event's own colours (mockup 06): the header
/// with the team's place and the two clocks, then the winding trail. The
/// route takes `{'event': Event, 'team': Team?}`.
class EventGameScreen extends StatefulWidget {
  const EventGameScreen({super.key});

  @override
  State<EventGameScreen> createState() => _EventGameScreenState();
}

class _EventGameScreenState extends State<EventGameScreen> {
  late EventGameController controller;

  bool _initialized = false;
  bool _endedDialogShown = false;

  @override
  void dispose() {
    controller.removeListener(_onControllerChanged);
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final event = arguments['event'] as Event;
      final team = arguments['team'] as Team?;

      controller = EventGameController(event, team, context);
      controller.addListener(_onControllerChanged);
      _initialized = true;

      if (controller.eventEnded) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showEventEndedDialog();
        });
      }
    }
  }

  void _onControllerChanged() {
    if (controller.eventEnded && !_endedDialogShown) {
      _showEventEndedDialog();
    }
  }

  void _showEventEndedDialog() {
    if (_endedDialogShown || !mounted) return;
    _endedDialogShown = true;

    Navigator.popUntil(
      context,
      (route) => route.settings.name == Routes.eventGame || route.isFirst,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: const Text("Ne pare rău"),
            content: const Text("S-a terminat evenimentul."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<UserProvider>().currentUser?.uid;
    final screen = _screen(context);
    return RefreshesActiveGame(
      refresh: context.read<UserEventsProvider>().loadActiveEvent,
      child: uid == null || controller.team == null
          ? screen
          : KeepsPresence(markPresent: () => controller.markPresent(uid), child: screen),
    );
  }

  /// Opens the mission the team is on; the place line pauses meanwhile.
  Future<void> _openCurrentMission() async {
    final index = controller.currentMission;
    // The organisers' preview has no team: the trail shows, nothing opens.
    if (controller.team == null || index >= controller.event.missions.length) return;
    controller.watchRanking(false);
    final updated = await Navigator.pushNamed(
      context,
      Routes.puzzleGame,
      arguments: {
        'mission': controller.event.missions[index],
        'background': controller.background,
        'event': controller.event,
        'team': controller.team,
        'missionIndex': index,
      },
    );
    if (!mounted) return;
    controller.watchRanking(true);
    if (updated is Team) controller.takeTeam(updated);
  }

  void _openChat() {
    Navigator.pushNamed(
      context,
      Routes.chatScreen,
      arguments: {'eventId': controller.event.eventId, 'team': controller.team},
    );
  }

  Widget _screen(BuildContext context) {
    final palette = eventPaletteOf(controller.event, context.colors);
    return EventThemeScope(
      palette: palette,
      child: Scaffold(
        backgroundColor: palette.background,
        body: GameBackdrop(
          child: SafeArea(
            child: ListenableBuilder(
              listenable: Listenable.merge([controller, controller.now]),
              builder: (context, _) {
                final now = controller.now.value;
                return GameRouteView(
                  eventName: controller.event.name ?? '',
                  placeLine: controller.placeText,
                  played: playedClock(controller.team?.startedAt, controller.event.dateEvent, now),
                  left: leftClock(controller.event, now),
                  stops: controller.stops,
                  onClose: () => Navigator.maybePop(context),
                  onChat: _openChat,
                  onContinue: _openCurrentMission,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
