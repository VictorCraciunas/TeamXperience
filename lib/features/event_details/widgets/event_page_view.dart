import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/features/event_details/logic/event_page_content.dart';
import 'package:teamxperience/features/event_details/logic/event_page_data.dart';
import 'package:teamxperience/features/event_details/logic/hero_badge.dart';
import 'package:teamxperience/features/event_details/logic/signup_bar_state.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/ui/components/misc/app_chip.dart';
import 'package:teamxperience/ui/components/route/route_strip.dart';
import 'package:teamxperience/ui/components/route/route_trail.dart';
import 'package:teamxperience/ui/components/route/route_trail_section.dart';
import 'package:teamxperience/ui/components/route/waypoint_dot.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/utils/event_formats.dart';

import 'event_facts.dart';
import 'event_hero.dart';
import 'event_signup_bar.dart';
import 'how_you_play_section.dart';
import 'logistics_section.dart';
import 'mission_teaser_card.dart';
import 'organiser_card.dart';
import 'story_section.dart';
import 'trail_section_body.dart';

/// The event page of mockup 01, built from plain values: no Firestore here.
class EventPageView extends StatelessWidget {
  const EventPageView({
    super.key,
    required this.event,
    required this.data,
    required this.now,
    required this.onBack,
    required this.onShare,
    this.onOpenMap,
    this.onMessageOrganiser,
    required this.onSignupAction,
    this.adminActions = const [],
    this.showHeroButtons = true,
    this.appBar,
  });

  final Event event;
  final EventPageData data;
  final DateTime now;
  final VoidCallback onBack;
  final VoidCallback onShare;

  /// Shown as the "Hartă" chip; give it only when the event has a start pin.
  final VoidCallback? onOpenMap;
  final VoidCallback? onMessageOrganiser;
  final void Function(SignupAction) onSignupAction;
  final List<Widget> adminActions;
  final bool showHeroButtons;

  /// The admin app bar; players have none, the hero is the top.
  final PreferredSizeWidget? appBar;

  static const _organiser = 'TeamXperience';

  @override
  Widget build(BuildContext context) {
    final teasers = missionTeasers(event);
    final kinds = puzzleKinds(event);
    final story = event.storyText.trim();
    final organiser = (event.organiserName ?? '').trim();
    final place = [event.location ?? '', event.area ?? ''].where((s) => s.trim().isNotEmpty).join(' · ');

    final sections = <RouteTrailSection>[
      if (story.isNotEmpty) RouteTrailSection(child: TrailSectionBody(title: 'Povestea', child: StorySection(text: story))),
      if (event.missions.isNotEmpty)
        RouteTrailSection(
          child: TrailSectionBody(
            title: 'Ce vă așteaptă',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MissionTeaserCard(shown: teasers.shown, secret: teasers.secret),
                if (kinds.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(spacing: 5, runSpacing: 5, children: [
                    for (final kind in kinds) AppChip(label: puzzleKindLabel(kind), icon: _kindIcon(kind)),
                  ]),
                ],
              ],
            ),
          ),
        ),
      RouteTrailSection(
        child: TrailSectionBody(
          title: 'Cum jucați',
          child: HowYouPlaySection(teamSizeMin: event.teamSizeMin, teamSizeMax: event.teamSizeMax),
        ),
      ),
      RouteTrailSection(child: TrailSectionBody(title: 'Logistică', child: LogisticsSection(event: event))),
      RouteTrailSection(
        kind: WaypointKind.finish,
        child: TrailSectionBody(
          title: 'Organizator',
          child: OrganiserCard(
            name: organiser.isEmpty ? _organiser : organiser,
            eventsCount: data.organiserEventsCount,
            onMessage: onMessageOrganiser,
          ),
        ),
      ),
    ];

    return Scaffold(
      appBar: appBar,
      bottomNavigationBar: data.isAdmin
          ? null
          : EventSignupBar(
              bar: signupBar(event: event, now: now, team: data.team, teamsCount: data.teamsCount),
              onAction: onSignupAction,
            ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EventHero(
              name: event.name ?? '',
              place: place,
              imageUrl: event.landingImageUrl,
              badge: heroBadge(event, now),
              showButtons: showHeroButtons,
              onBack: onBack,
              onShare: onShare,
            ),
            RouteStrip(
              centerLabel: routeSummary(event.effectiveRouteKm, event.missions.length),
              startLabel: event.punctDeStart ?? '',
              endLabel: event.finishPoint ?? '',
              mapLabel: 'Hartă',
              onMapTap: event.hasStartPin ? onOpenMap : null,
            ),
            EventFacts(event: event, teamsCount: data.teamsCount),
            RouteTrail(sections: sections),
            if (adminActions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.page),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < adminActions.length; i++) ...[
                      if (i > 0) const SizedBox(height: AppSpacing.md),
                      adminActions[i],
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  static IconData _kindIcon(PuzzleKind kind) => switch (kind) {
        PuzzleKind.codes => TablerIcons.key,
        PuzzleKind.photos => TablerIcons.camera,
        PuzzleKind.places => TablerIcons.current_location,
      };
}
