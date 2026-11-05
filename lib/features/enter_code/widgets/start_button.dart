import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

/// The start screen's main button (mockup 05: tick fill, radius 12,
/// padding 11, w500); a spinner while busy.
class StartButton extends StatelessWidget {
  const StartButton({super.key, required this.label, required this.busy, required this.onTap});

  final String label;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.45, color: colors.onTick);
    return Material(
      color: colors.tickOnNavy,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: busy ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Center(
            child: busy
                ? SizedBox(
                    height: 12 * 1.45,
                    width: 12 * 1.45,
                    child: CircularProgressIndicator(strokeWidth: 2, color: colors.onTick),
                  )
                : Text(label, textAlign: TextAlign.center, style: style),
          ),
        ),
      ),
    );
  }
}
