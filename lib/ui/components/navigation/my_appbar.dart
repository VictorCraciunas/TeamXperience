import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/misc/app_svg_icon.dart';
import 'package:teamxperience/ui/ui.dart';

/// The plain screen bar: a centred title (with an optional [subtitle]) and,
/// on the right, either a [trailing] widget or a round [iconString] button
/// that calls [onIconTap] (what it opens is up to the page).
class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String appBarText;
  final String? subtitle;
  final String? iconString;
  final VoidCallback? onIconTap;

  /// Read out for the icon button ("Mai multe acțiuni").
  final String? iconLabel;
  final Widget? trailing;

  const MyAppBar({
    super.key,
    required this.appBarText,
    this.subtitle,
    this.iconString,
    this.onIconTap,
    this.iconLabel,
    this.trailing,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final sub = subtitle;
    final end = trailing;
    final icon = iconString;
    return AppBar(
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: Border(bottom: BorderSide(color: context.colors.border)),
      backgroundColor: context.colors.panel,
      title: sub != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  appBarText,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: context.colors.text,
                  ),
                ),
                Text(
                  sub,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: context.colors.muted,
                  ),
                ),
              ],
            )
          : Text(
              appBarText,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: context.colors.text,
              ),
            ),
      centerTitle: true,
      actions: [
        if (end != null)
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: end,
          )
        else if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Semantics(
              button: true,
              label: iconLabel,
              child: Material(
                color: context.colors.iconButtonBg,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onIconTap,
                  child: SizedBox(
                    width: 45,
                    height: 45,
                    child: Center(
                      child: AppSvgIcon(icon, width: 24, height: 24),
                    ),
                  ),
                ),
              ),
            ),
          )
      ],
    );
  }
}
