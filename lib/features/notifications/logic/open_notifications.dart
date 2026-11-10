import 'package:flutter/widgets.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/ui/components/navigation/shell_controller.dart';

/// Opens the notifications page. It is pushed above the shell, so it cannot
/// switch tabs itself: it closes with the tab to show, and this selects it.
Future<void> openNotificationsPage(NavigatorState navigator, ShellController shell) async {
  final tab = await navigator.pushNamed<Object?>(Routes.notifications);
  if (tab is int) shell.select(tab);
}
