import 'package:flutter/widgets.dart';

class AppNavItem {
  const AppNavItem({
    required this.icon,
    required this.label,
    this.showBadge = false,
  });

  final IconData icon;
  final String label;
  final bool showBadge;
}
