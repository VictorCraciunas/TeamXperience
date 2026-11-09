import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/features/team_photo/logic/team_album.dart';
import 'package:teamxperience/features/team_photo/widgets/album_strip.dart';
import 'package:teamxperience/ui/components/game/game_filled_button.dart';
import 'package:teamxperience/ui/components/game/game_outline_button.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

import 'finish_seal.dart';
import 'finish_stat_tile.dart';
import 'mission_dots_card.dart';
import 'rating_stars.dart';

/// The finish recap of mockup 08, from plain values: the seal and the texts,
/// place / time / km, the route line, the photos, the rating, and the bar
/// with "Distribuie" and "Vezi clasamentul". Sections without data are left
/// out; the page scrolls.
class FinishView extends StatelessWidget {
  const FinishView({
    super.key,
    required this.title,
    required this.message,
    required this.place,
    required this.placeLabel,
    required this.time,
    required this.km,
    required this.missions,
    required this.solved,
    this.fastest,
    required this.hints,
    required this.photos,
    this.onPhoto,
    this.photoCard,
    this.rating,
    required this.onRate,
    required this.onShare,
    required this.onLeaderboard,
  });

  final String title;
  final String message;

  /// "2"; null until the ranking arrives ("–").
  final String? place;
  final String placeLabel;
  final String time;
  final String km;
  final int missions;
  final int solved;
  final String? fastest;
  final String hints;
  final List<AlbumPhoto> photos;

  /// Opens a photo.
  final ValueChanged<AlbumPhoto>? onPhoto;

  /// The optional final team photo.
  final Widget? photoCard;
  final int? rating;
  final ValueChanged<int> onRate;
  final VoidCallback onShare;
  final VoidCallback onLeaderboard;

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    final card = photoCard;
    final label = TextStyle(fontSize: 11, height: 1.45, color: palette.ink.withValues(alpha: .8));

    Widget section(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
          child: Text(text, style: label),
        );

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 26, 16, 0),
                  child: Column(
                    children: [
                      const FinishSeal(),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: palette.voiceFont, fontSize: 21, height: 1.3, color: palette.ink),
                      ),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, height: 1.45, color: palette.ink.withValues(alpha: .8)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
                  child: Row(
                    children: [
                      Expanded(child: FinishStatTile(value: place ?? '–', label: placeLabel, accent: true)),
                      const SizedBox(width: 6),
                      Expanded(child: FinishStatTile(value: time, label: 'timp total', mono: true)),
                      const SizedBox(width: 6),
                      Expanded(child: FinishStatTile(value: km, label: 'km pe jos')),
                    ],
                  ),
                ),
                if (missions > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                    child: MissionDotsCard(missions: missions, solved: solved, fastest: fastest, hints: hints),
                  ),
                if (card != null) Padding(padding: const EdgeInsets.fromLTRB(14, 12, 14, 0), child: card),
                if (photos.isNotEmpty) ...[
                  section('Pozele voastre'),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: AlbumStrip(photos: photos, onTap: onPhoto)),
                ],
                section('Cum ți s-a părut?'),
                RatingStars(rating: rating, onRate: onRate),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Row(
            children: [
              Expanded(
                flex: 10,
                child: GameOutlineButton(label: 'Distribuie', icon: TablerIcons.share, onTap: onShare),
              ),
              const SizedBox(width: 8),
              Expanded(flex: 13, child: GameFilledButton(label: 'Vezi clasamentul', onTap: onLeaderboard)),
            ],
          ),
        ),
      ],
    );
  }
}
