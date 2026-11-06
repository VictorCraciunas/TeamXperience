import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/features/event_game/logic/style_hints.dart';
import 'package:teamxperience/features/event_game/widgets/game_backdrop.dart';
import 'package:teamxperience/features/finish/controller/finish_controller.dart';
import 'package:teamxperience/features/finish/logic/finish_recap.dart';
import 'package:teamxperience/features/finish/widgets/finish_view.dart';
import 'package:teamxperience/features/home/widgets/leaderboard_sheet.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/service/share_service.dart';
import 'package:teamxperience/service/team_service/team_service.dart';
import 'package:teamxperience/state_management/user_provider.dart';
import 'package:teamxperience/ui/ui.dart';

/// The finish recap of mockup 08, in the event's colours: opened when the
/// team solves its last mission or the event ends. The route takes
/// `{'event': Event, 'team': Team}`.
class FinishScreen extends StatefulWidget {
  const FinishScreen({super.key});

  @override
  State<FinishScreen> createState() => _FinishScreenState();
}

class _FinishScreenState extends State<FinishScreen> {
  FinishController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! Map) return;
    final event = args['event'];
    final team = args['team'];
    if (event is! Event || team is! Team) return;
    final uid = context.read<UserProvider>().currentUser?.uid;
    final service = TeamService();
    _controller = FinishController(
      event: event,
      team: team,
      teams: service.getStreamTeams(event.eventId),
      teamStream: service.getStreamTeam(event.eventId, team.name),
      saveRating: (stars) async {
        if (uid != null) await service.saveRating(event.eventId, uid, teamName: team.name, rating: stars);
      },
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return Scaffold(backgroundColor: context.colors.page);
    final palette = eventPaletteOf(controller.event, context.colors);
    return EventThemeScope(
      palette: palette,
      child: Scaffold(
        backgroundColor: palette.background,
        body: GameBackdrop(
          child: SafeArea(
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                final event = controller.event;
                final team = controller.team;
                final texts = finishTexts(event, team);
                final place = controller.place;
                final fastest = fastestMission(team);
                return FinishView(
                  title: texts.title,
                  message: texts.message,
                  place: place == null ? null : '${place.place}',
                  placeLabel: placeLabel(place?.teams ?? 0),
                  time: hoursMinutes(controller.timePlayed),
                  km: kmLabel(team.distanceMeters),
                  missions: event.missions.length,
                  solved: team.missionProgress.clamp(0, event.missions.length),
                  fastest: fastest == null ? null : fastestLine(fastest),
                  hints: hintsLabel(team),
                  photos: approvedPhotos(team),
                  rating: controller.rating,
                  onRate: controller.rate,
                  onShare: () => ShareService().shareText(
                    context,
                    subject: event.name ?? '',
                    text: controller.shareText,
                  ),
                  onLeaderboard: () => showLeaderboardSheet(
                    context,
                    ranked: controller.ranked,
                    ownName: team.name,
                    missionCount: event.missions.length,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
