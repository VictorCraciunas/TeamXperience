import 'package:flutter/widgets.dart';

class AppNavItem {
  const AppNavItem({
    required this.icon,
    required this.label,
    this.showBadge = false,
    this.raised = false,
    this.live = false,
  });

  final IconData icon;
  final String label;
  final bool showBadge;

  /// Drawn as the round button in the middle of the bar ("Joacă").
  final bool raised;

  /// A raised item turns red while a game is on ("În joc").
  final bool live;
}
