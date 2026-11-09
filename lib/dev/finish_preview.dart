import 'package:flutter/material.dart';
import 'package:teamxperience/features/event_game/logic/style_hints.dart';
import 'package:teamxperience/features/event_game/widgets/game_backdrop.dart';
import 'package:teamxperience/features/team_photo/logic/team_album.dart';
import 'package:teamxperience/features/finish/logic/finish_recap.dart';
import 'package:teamxperience/features/finish/widgets/finish_view.dart';
import 'package:teamxperience/ui/components/misc/segmented_switch.dart';
import 'package:teamxperience/ui/ui.dart';

import 'sample_event.dart';

/// Mockup 08's finish recap for the sample event: the route done, or the
/// event stopped after three missions; in parchment or neon.
class FinishPreview extends StatefulWidget {
  const FinishPreview({super.key});

  @override
  State<FinishPreview> createState() => _FinishPreviewState();
}

class _FinishPreviewState extends State<FinishPreview> {
  bool _neon = false;
  bool _partial = false;
  int? _rating;

  @override
  Widget build(BuildContext context) {
    final event = _neon ? neonSampleEvent() : sampleEvent();
    final team = sampleFinishedTeam(solved: _partial ? 3 : 6);
    final palette = eventPaletteOf(event, context.colors);
    final texts = finishTexts(event, team);
    final fastest = fastestMission(team);
    final now = DateTime(2026, 11, 14, 11, 30);
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
                  child: FinishView(
                    title: texts.title,
                    message: texts.message,
                    place: _partial ? '5' : '2',
                    placeLabel: placeLabel(12),
                    time: hoursMinutes(playedTime(event, team, now)),
                    km: kmLabel(team.distanceMeters),
                    missions: event.missions.length,
                    solved: team.missionProgress,
                    fastest: fastest == null ? null : fastestLine(fastest),
                    hints: hintsLabel(team),
                    photos: teamAlbum(team),
                    rating: _rating,
                    onRate: (stars) => setState(() => _rating = stars),
                    onShare: () {},
                    onLeaderboard: () {},
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SegmentedSwitch(
                      labels: const ['Pergament', 'Neon'],
                      selectedIndex: _neon ? 1 : 0,
                      onSelected: (i) => setState(() => _neon = i == 1),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    SegmentedSwitch(
                      labels: const ['Traseu complet', 'Oprit mai devreme'],
                      selectedIndex: _partial ? 1 : 0,
                      onSelected: (i) => setState(() => _partial = i == 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
