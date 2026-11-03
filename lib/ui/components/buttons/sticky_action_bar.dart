import 'package:flutter/material.dart';

import '../../theme/app_radius.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/theme_context.dart';
import 'bar_tone.dart';

/// The bar pinned to the bottom of a page, with a short status on the left
/// and one action on the right ("Mai sunt 5 zile · Înscrie echipa").
class StickyActionBar extends StatelessWidget {
  const StickyActionBar({
    super.key,
    required this.title,
    this.detail,
    this.inlineDetail = false,
    this.leadingIcon,
    this.tone = BarTone.neutral,
    this.highlighted = false,
    required this.actionLabel,
    this.actionIcon,
    this.prominent = true,
    this.onAction,
  });

  final String title;
  final String? detail;

  /// Puts [detail] after the title on one line ("Vulpile · 4 membri")
  /// instead of on a second line.
  final bool inlineDetail;
  final IconData? leadingIcon;
  final BarTone tone;

  /// A teal top border, for a bar that asks for action now.
  final bool highlighted;
  final String actionLabel;
  final IconData? actionIcon;

  /// A navy button when true, an accent text link when false.
  final bool prominent;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final icon = leadingIcon;
    final iconColor = switch (tone) {
      BarTone.success => colors.success,
      BarTone.accent => colors.accent,
      BarTone.neutral => colors.muted,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border(top: BorderSide(color: highlighted ? colors.tick : colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: iconColor),
                  const SizedBox(width: 10),
                ],
                Expanded(child: _texts(context)),
                const SizedBox(width: 10),
                prominent ? _button(context) : _link(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _texts(BuildContext context) {
    final extra = detail;
    final titleStyle = AppTextStyles.cardTitle(context);
    if (extra == null) return Text(title, style: titleStyle, maxLines: 2, overflow: TextOverflow.ellipsis);

    if (inlineDetail) {
      return Text.rich(
        TextSpan(children: [
          TextSpan(text: title, style: titleStyle),
          TextSpan(text: ' · $extra', style: AppTextStyles.pageBody(context).copyWith(color: context.colors.muted)),
        ]),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: titleStyle, maxLines: 2, overflow: TextOverflow.ellipsis),
        Text(extra, style: AppTextStyles.smallMuted(context), maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _button(BuildContext context) {
    final colors = context.colors;
    final icon = actionIcon;
    final radius = BorderRadius.circular(AppRadius.button);
    return Ink(
      decoration: BoxDecoration(color: colors.navy, borderRadius: radius),
      child: InkWell(
        onTap: onAction,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: colors.onNavy),
                const SizedBox(width: 6),
              ],
              Text(
                actionLabel,
                style: AppTextStyles.cardTitle(context).copyWith(color: colors.onNavy),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _link(BuildContext context) {
    return InkWell(
      onTap: onAction,
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Center(
          widthFactor: 1,
          child: Text(
            actionLabel,
            style: AppTextStyles.cardTitle(context).copyWith(color: context.colors.accent),
          ),
        ),
      ),
    );
  }
}
