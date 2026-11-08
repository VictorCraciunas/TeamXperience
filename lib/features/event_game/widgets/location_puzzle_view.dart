import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/features/event_game/logic/location_texts.dart';
import 'package:teamxperience/ui/components/game/distance_compass.dart';
import 'package:teamxperience/ui/components/game/game_filled_button.dart';
import 'package:teamxperience/ui/components/game/game_outline_button.dart';
import 'package:teamxperience/ui/components/game/photo_status_banner.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

import 'frame_band.dart';

/// Where a location puzzle stands.
enum LocationViewState {
  /// Fixes are coming in.
  tracking,

  /// Waiting for the first fix.
  waiting,

  /// Location permission refused.
  denied,

  /// The phone's location is switched off.
  serviceOff,

  /// The organiser set no place.
  noTarget,

  /// The mission was already solved; only "Continuă".
  done,
}

/// A location puzzle as mockup 07, from plain values: the map card, how far
/// and which way (or "Ești în cerc"), and the bar with "Indiciu" and
/// "Intră în cerc".
class LocationPuzzleView extends StatelessWidget {
  const LocationPuzzleView({
    super.key,
    required this.state,
    required this.map,
    this.meters,
    this.bearing,
    this.trend,
    required this.inside,
    required this.onEnter,
    this.onHint,
    required this.onOpenSettings,
    this.onOpenLocationSettings,
    this.onPicture = false,
    this.header,
  });

  final LocationViewState state;
  final Widget map;
  final double? meters;
  final double? bearing;
  final DistanceTrend? trend;
  final bool inside;
  final VoidCallback onEnter;
  final VoidCallback? onHint;
  final VoidCallback onOpenSettings;

  /// Opens the phone's location settings; the app settings when null.
  final VoidCallback? onOpenLocationSettings;

  /// Whether the puzzle is drawn on the organiser's picture (the bar then
  /// gets its band).
  final bool onPicture;

  /// The organiser's content above the map; it scrolls with the map, so the
  /// bar stays on the screen however long it is.
  final Widget? header;

  bool get _canEnter => switch (state) {
        LocationViewState.tracking => inside,
        LocationViewState.noTarget || LocationViewState.done => true,
        LocationViewState.waiting || LocationViewState.denied || LocationViewState.serviceOff => false,
      };

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    final top = header;
    final far = meters;
    final way = bearing;

    Widget message(String text, {Widget? action}) => Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: palette.surface,
              border: Border.all(color: palette.border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(TablerIcons.map_pin, size: 22, color: palette.accent),
                  const SizedBox(height: 8),
                  Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, height: 1.45, color: palette.ink)),
                  if (action != null) ...[const SizedBox(height: 12), action],
                ],
              ),
            ),
          ),
        );

    final body = switch (state) {
      LocationViewState.denied => [
          message(
            'Permite accesul la locație ca să vedeți cât de aproape sunteți.',
            action: GameFilledButton(label: 'Deschide setările', icon: TablerIcons.settings, onTap: onOpenSettings),
          ),
        ],
      LocationViewState.serviceOff => [
          message(
            'Pornește locația ca să vedeți cât de aproape sunteți.',
            action: GameFilledButton(
              label: 'Deschide setările',
              icon: TablerIcons.settings,
              onTap: onOpenLocationSettings ?? onOpenSettings,
            ),
          ),
        ],
      LocationViewState.noTarget => [message('Organizatorul n-a pus locul pe hartă. Puteți merge mai departe.')],
      LocationViewState.done => <Widget>[],
      LocationViewState.tracking || LocationViewState.waiting => [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: SizedBox(
              key: const ValueKey('location-map-card'),
              height: 210,
              child: DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: BoxDecoration(
                  border: Border.all(color: palette.border),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ClipRRect(borderRadius: BorderRadius.circular(14), child: map),
              ),
            ),
          ),
          if (state == LocationViewState.tracking && inside)
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: PhotoStatusBanner(kind: PhotoBannerKind.approved, text: 'Ești în cerc'),
            )
          else if (state == LocationViewState.tracking && far != null && way != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: DistanceCompass(
                distance: shortDistance(far),
                line: walkLine(far, way),
                bearing: way,
                trend: trendLabel(trend),
                closer: trend != DistanceTrend.farther,
              ),
            ),
        ],
    };

    return Column(
      children: [
        Expanded(child: SingleChildScrollView(child: Column(children: [if (top != null) top, ...body]))),
        FrameBand(
          onPicture: onPicture,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
            child: Row(
              children: [
                Expanded(
                  flex: 10,
                  child: GameOutlineButton(label: 'Indiciu', icon: TablerIcons.bulb, onTap: onHint),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 14,
                  child: GameFilledButton(
                    label: state == LocationViewState.done ? 'Continuă' : 'Intră în cerc',
                    onTap: _canEnter ? onEnter : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
