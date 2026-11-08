import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/features/profile/logic/badge_catalog.dart';
import 'package:teamxperience/ui/ui.dart';

/// Opens the list of all the badges.
Future<void> showBadgeSheet(BuildContext context, {required List<String> earned}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.page,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => BadgeSheet(earned: earned),
  );
}

/// All the badges: the earned ones with their colours, the locked ones with
/// how to earn them.
class BadgeSheet extends StatelessWidget {
  const BadgeSheet({super.key, required this.earned});

  final List<String> earned;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .8),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Insigne',
                      style: TextStyle(fontSize: 17, height: 1.45, fontWeight: FontWeight.w500, color: colors.text),
                    ),
                  ),
                  Text(
                    '${earnedCount(earned)} din ${badgeCatalog.length}',
                    style: TextStyle(fontSize: 12, height: 1.45, color: colors.muted),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  for (final badge in badgeCatalog) _row(context, badge, earned.contains(badge.id)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, ProfileBadge badge, bool has) {
    final colors = context.colors;
    final fill = !has ? colors.inset : (badge.gold ? colors.warningSoft : colors.iconButtonBg);
    final ink = !has ? colors.muted : (badge.gold ? colors.warning : colors.accent);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
            child: SizedBox.square(
              dimension: 40,
              child: Center(child: Icon(has ? badge.icon : TablerIcons.lock, size: has ? 20 : 16, color: ink)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(badge.title, style: TextStyle(fontSize: 13, height: 1.45, fontWeight: FontWeight.w500, color: colors.text)),
                if (!has) Text(badge.rule, style: TextStyle(fontSize: 11, height: 1.45, color: colors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
