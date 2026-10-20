import 'package:flutter/material.dart';

import '../../theme/app_radius.dart';
import '../../theme/theme_context.dart';
import '../feedback/status_pill.dart';
import 'countdown_tiles.dart';
import 'hero_action.dart';
import 'hero_card_frame.dart';

enum HeroStatus { live, soon, upcoming, recommended }

class EventHeroCard extends StatelessWidget {
  const EventHeroCard({
    super.key,
    required this.status,
    required this.statusLabel,
    required this.title,
    required this.primary,
    this.subtitle,
    this.timeChip,
    this.imageUrl,
    this.progressDone,
    this.progressTotal,
    this.countdown,
    this.secondaryIcon,
    this.onSecondary,
    this.secondaryLabel,
    this.moreActions = const [],
  });

  final HeroStatus status;
  final String statusLabel;
  final String title;
  final String? subtitle;
  final String? timeChip;
  final String? imageUrl;
  final int? progressDone;
  final int? progressTotal;
  final Duration? countdown;
  final HeroAction primary;
  final IconData? secondaryIcon;
  final VoidCallback? onSecondary;
  final String? secondaryLabel;

  /// Further icon buttons shown after [secondaryIcon].
  final List<HeroIconAction> moreActions;

  StatusPillKind get _pillKind {
    switch (status) {
      case HeroStatus.live:
        return StatusPillKind.live;
      case HeroStatus.soon:
        return StatusPillKind.soon;
      case HeroStatus.upcoming:
      case HeroStatus.recommended:
        return StatusPillKind.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtitleText = subtitle;
    final chip = timeChip;
    final total = progressTotal;
    final remaining = countdown;
    final secondary = secondaryIcon;
    final onSecondaryTap = onSecondary;

    return HeroCardFrame(
      imageUrl: imageUrl,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(child: StatusPill(label: statusLabel, kind: _pillKind)),
              if (chip != null) ...[
                const SizedBox(width: 8),
                Flexible(child: _TimeChip(label: chip)),
              ],
            ],
          ),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              if (subtitleText != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitleText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFD3DAE6),
                    fontSize: 12,
                  ),
                ),
              ],
              if (total != null && total > 0) ...[
                const SizedBox(height: 10),
                _Segments(done: progressDone ?? 0, total: total),
              ],
              if (remaining != null) ...[
                const SizedBox(height: 10),
                CountdownTiles(remaining: remaining),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _PrimaryButton(action: primary, status: status),
                  ),
                  if (secondary != null && onSecondaryTap != null) ...[
                    const SizedBox(width: 8),
                    _SecondaryButton(
                      icon: secondary,
                      onTap: onSecondaryTap,
                      label: secondaryLabel,
                    ),
                  ],
                  for (final action in moreActions) ...[
                    const SizedBox(width: 8),
                    _SecondaryButton(
                      icon: action.icon,
                      onTap: action.onTap,
                      label: action.label,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x80000000),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _Segments extends StatelessWidget {
  const _Segments({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    const filled = Color(0xFF7FE6EA);
    const empty = Color(0x47FFFFFF);
    final clampedDone = done.clamp(0, total);

    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: Container(
              key: ValueKey(
                i < clampedDone
                    ? 'hero-segment-done-$i'
                    : i == clampedDone
                    ? 'hero-segment-current-$i'
                    : 'hero-segment-todo-$i',
              ),
              height: 5,
              decoration: BoxDecoration(
                color: i < clampedDone ? filled : null,
                gradient:
                    i == clampedDone
                        ? const LinearGradient(
                          colors: [filled, filled, empty, empty],
                          stops: [0, 0.5, 0.5, 1],
                        )
                        : null,
                borderRadius: BorderRadius.circular(3),
              ),
              foregroundDecoration:
                  i > clampedDone
                      ? BoxDecoration(
                        color: empty,
                        borderRadius: BorderRadius.circular(3),
                      )
                      : null,
            ),
          ),
        ],
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.action, required this.status});

  final HeroAction action;
  final HeroStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final emphasised =
        status == HeroStatus.soon || status == HeroStatus.recommended;
    final foreground = emphasised ? Colors.white : const Color(0xFF0C092A);
    final icon = action.icon;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: emphasised ? null : const Color(0xFFF2F4F8),
          gradient: emphasised ? colors.ctaGradient : null,
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.button),
          onTap: action.onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: foreground),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      action.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.icon, required this.onTap, this.label});

  final IconData icon;
  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final button = _build();
    final text = label;
    return text == null ? button : Tooltip(message: text, child: button);
  }

  Widget _build() {
    return Material(
      color: const Color(0x2EFFFFFF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.button),
        side: const BorderSide(color: Color(0x66FFFFFF)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.button),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
