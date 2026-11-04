import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/components/buttons/bar_tone.dart';
import 'package:teamxperience/ui/components/buttons/sticky_action_bar.dart';
import 'package:teamxperience/ui/components/event/date_fact_tile.dart';
import 'package:teamxperience/ui/components/event/difficulty_dots.dart';
import 'package:teamxperience/ui/components/event/fact_row.dart';
import 'package:teamxperience/ui/components/event/fact_tile.dart';
import 'package:teamxperience/ui/components/feedback/field_status_line.dart';
import 'package:teamxperience/ui/components/inputs/code_boxes_input.dart';
import 'package:teamxperience/ui/components/inputs/size_picker.dart';
import 'package:teamxperience/ui/components/misc/app_chip.dart';
import 'package:teamxperience/ui/components/misc/app_chip_style.dart';
import 'package:teamxperience/ui/components/misc/avatar_stack.dart';
import 'package:teamxperience/ui/components/route/route_strip.dart';
import 'package:teamxperience/ui/components/route/route_trail.dart';
import 'package:teamxperience/ui/components/route/route_trail_section.dart';
import 'package:teamxperience/ui/components/route/waypoint_dot.dart';
import 'package:teamxperience/ui/components/team/invite_code_card.dart';
import 'package:teamxperience/ui/ui.dart';

import 'event_page_preview_launcher.dart';
import 'gallery_section.dart';
import 'parchment_swatches.dart';

/// Every redesign component with the copy of mockup 01, to hold next to
/// docs/roadmap/mockups/01-event-details.html.
class ComponentGallery extends StatelessWidget {
  const ComponentGallery({super.key, this.actions});

  /// App bar actions (the theme switch of the gallery app).
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final heading = AppTextStyles.trailHeading(context);
    final body = AppTextStyles.pageBody(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Component gallery'), actions: actions),
      body: ListView(
        padding: const EdgeInsets.only(top: AppSpacing.lg),
        children: [
          const GallerySection(title: 'Ecrane', child: EventPagePreviewLauncher()),
          GallerySection(
            title: 'Route strip',
            child: RouteStrip(
              centerLabel: '4,5 km · 6 misiuni',
              startLabel: 'Piața Mare',
              endLabel: 'Turnul Sfatului',
              mapLabel: 'Hartă',
              onMapTap: () {},
            ),
          ),
          const GallerySection(
            title: 'Fact row',
            child: FactRow(
              date: DateFactTile(day: '14', detail: 'nov · 10:00'),
              facts: [
                FactTile(icon: TablerIcons.clock, value: '2 h', label: 'durată'),
                FactTile(leading: DifficultyDots(level: 2), value: 'Medie', label: 'dificultate'),
                FactTile(icon: TablerIcons.users, value: '12', label: 'echipe'),
              ],
            ),
          ),
          GallerySection(
            title: 'Route trail',
            child: RouteTrail(sections: [
              RouteTrailSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Povestea', style: heading),
                    const SizedBox(height: 6),
                    Text(
                      'Un cartograf a lăsat o hartă neterminată ascunsă în zidurile orașului. '
                      'Echipa care o completează prima moștenește secretul lui.',
                      style: body,
                    ),
                  ],
                ),
              ),
              RouteTrailSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ce vă așteaptă', style: heading),
                    const SizedBox(height: 6),
                    const Wrap(spacing: 5, runSpacing: 5, children: [
                      AppChip(label: 'Coduri', icon: TablerIcons.key),
                      AppChip(label: 'Fotografii', icon: TablerIcons.camera),
                      AppChip(label: 'Locuri pe hartă', icon: TablerIcons.current_location),
                    ]),
                  ],
                ),
              ),
              RouteTrailSection(
                kind: WaypointKind.finish,
                child: Text('Organizator', style: heading),
              ),
            ]),
          ),
          GallerySection(
            title: 'Chips',
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Wrap(spacing: 6, runSpacing: 6, children: [
                AppChip(label: 'Toate', style: AppChipStyle.selected, onTap: () {}),
                AppChip(label: 'Luna asta', onTap: () {}),
                AppChip(label: 'Hartă', icon: TablerIcons.map, style: AppChipStyle.outlined, onTap: () {}),
              ]),
            ),
          ),
          GallerySection(
            title: 'Sticky action bar',
            child: Column(
              children: [
                StickyActionBar(
                  title: 'Mai sunt 5 zile',
                  detail: '12 echipe înscrise',
                  actionLabel: 'Înscrie echipa',
                  actionIcon: TablerIcons.users_plus,
                  onAction: () {},
                ),
                const SizedBox(height: 8),
                StickyActionBar(
                  title: 'Vulpile',
                  detail: '4 membri',
                  inlineDetail: true,
                  leadingIcon: TablerIcons.circle_check,
                  tone: BarTone.success,
                  actionLabel: 'Echipa ta',
                  prominent: false,
                  onAction: () {},
                ),
                const SizedBox(height: 8),
                StickyActionBar(
                  title: 'A început',
                  detail: '42 min să intri',
                  inlineDetail: true,
                  leadingIcon: TablerIcons.player_play,
                  tone: BarTone.accent,
                  highlighted: true,
                  actionLabel: 'Introdu codul',
                  prominent: false,
                  onAction: () {},
                ),
              ],
            ),
          ),
          const GallerySection(title: 'Echipe', child: _TeamsGallery()),
          const GallerySection(
            title: 'Event palette: parchment',
            child: EventThemeScope(palette: EventPalette.parchment, child: ParchmentSwatches()),
          ),
        ],
      ),
    );
  }
}

/// The team components with the copy of mockup 04. Stateful so the size
/// picker and the code boxes can be tried.
class _TeamsGallery extends StatefulWidget {
  const _TeamsGallery();

  @override
  State<_TeamsGallery> createState() => _TeamsGalleryState();
}

class _TeamsGalleryState extends State<_TeamsGallery> {
  int _size = 4;
  bool _wrongCode = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FieldStatusLine(text: 'Numele e liber', status: FieldStatus.ok),
          const SizedBox(height: AppSpacing.sm),
          const FieldStatusLine(text: 'Numele e deja luat', status: FieldStatus.problem),
          const SizedBox(height: AppSpacing.sm),
          const FieldStatusLine(text: 'Verific numele...', status: FieldStatus.checking),
          const SizedBox(height: AppSpacing.lg),
          SizePicker(min: 2, max: 6, value: _size, onChanged: (n) => setState(() => _size = n)),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const AvatarStack(initials: ['VC', 'AM'], total: 4, highlightNext: true),
              const SizedBox(width: 6),
              Flexible(
                child: Text('2 din 4 · tu ești al 3-lea', style: AppTextStyles.smallMuted(context)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          CodeBoxesInput(
            length: 6,
            dashAfter: 3,
            error: _wrongCode,
            onChanged: (_) => setState(() => _wrongCode = false),
            onCompleted: (code) => setState(() => _wrongCode = code != 'VLP482'),
          ),
          const SizedBox(height: AppSpacing.lg),
          InviteCodeCard(
            code: 'VLP-482',
            caption: 'Gata. Trimite codul coechipierilor',
            shareLabel: 'WhatsApp',
            copyLabel: 'Copiază',
            onShare: () {},
            onCopy: () {},
            footer: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AvatarStack(initials: ['VC'], total: 4, onDark: true),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '1 din 4 în echipă',
                    style: TextStyle(
                      fontSize: 11,
                      color: context.colors.onNavy.withValues(alpha: .8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
