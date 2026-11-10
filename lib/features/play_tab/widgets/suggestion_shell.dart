import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// The white card of the suggestion: 22 px corners and the pop-up shadow.
class SuggestionShell extends StatelessWidget {
  const SuggestionShell({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PhysicalModel(
      color: colors.panel,
      elevation: 14,
      shadowColor: colors.liveCard,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
