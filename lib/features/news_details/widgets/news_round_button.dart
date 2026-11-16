import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// A 44 px round button over the news picture (back, share), labelled for
/// screen readers and with a tooltip.
class NewsRoundButton extends StatelessWidget {
  const NewsRoundButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: Material(
          color: context.colors.panel.withValues(alpha: .56),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Center(child: icon),
            ),
          ),
        ),
      ),
    );
  }
}
