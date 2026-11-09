import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/features/event_details/logic/hero_badge.dart';
import 'package:teamxperience/ui/ui.dart';

import 'event_hero_pattern.dart';
import 'hero_badge_pill.dart';
import 'hero_round_button.dart';

/// The top of the event page: picture (or navy rings), back and share, the
/// badge, the name and the place. 200 tall below the status bar.
class EventHero extends StatelessWidget {
  const EventHero({
    super.key,
    required this.name,
    required this.place,
    this.imageUrl,
    this.badge,
    this.showButtons = true,
    this.onBack,
    this.onShare,
  });

  final String name;
  final String place;
  final String? imageUrl;
  final HeroBadge? badge;
  final bool showButtons;
  final VoidCallback? onBack;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final top = showButtons ? MediaQuery.paddingOf(context).top : 0.0;
    final pill = badge;
    final back = onBack;
    final share = onShare;

    return SizedBox(
      height: 200 + top,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: colors.navy,
            child: CustomPaint(painter: EventHeroPattern(colors.tickOnNavy.withValues(alpha: 0.18))),
          ),
          if (_hasImage) ...[
            _image(),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.4, 1],
                  colors: [colors.navy.withValues(alpha: 0), colors.navy.withValues(alpha: 0.85)],
                ),
              ),
            ),
          ],
          if (showButtons)
            Positioned(
              top: top + 12,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  if (back != null) HeroRoundButton(icon: TablerIcons.arrow_left, tooltip: 'Înapoi', onTap: back),
                  const Spacer(),
                  if (share != null) HeroRoundButton(icon: TablerIcons.share, tooltip: 'Distribuie', onTap: share),
                ],
              ),
            ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (pill != null) ...[HeroBadgePill(badge: pill), const SizedBox(height: 8)],
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.heroTitle(context).copyWith(color: colors.onNavy),
                ),
                Text(
                  place,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, height: 1.45, color: colors.onNavy.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool get _hasImage => (imageUrl ?? '').isNotEmpty;

  Widget _image() {
    final url = imageUrl ?? '';
    if (url.startsWith('http')) {
      return CachedNetworkImage(imageUrl: url, fit: BoxFit.cover, errorWidget: (_, _, _) => const SizedBox.shrink());
    }
    return Image.file(File(url), fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink());
  }
}
