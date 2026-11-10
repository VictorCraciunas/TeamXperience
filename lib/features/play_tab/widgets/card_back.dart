import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/ui.dart';

/// The back of a card in the deck: navy with teal stripes, the key and
/// "TeamXperience" (mockup 10).
class CardBack extends StatelessWidget {
  const CardBack({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PhysicalModel(
      color: colors.navy,
      elevation: 10,
      shadowColor: colors.liveCard,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: colors.panel, width: 3),
          borderRadius: BorderRadius.circular(22),
        ),
        child: CustomPaint(
          painter: _Stripes(colors.tickOnNavy.withValues(alpha: .13)),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(TablerIcons.key, size: 56, color: colors.tickOnNavy),
                Text('TeamXperience', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.onNavy)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 12 px stripes at 45°, 12 px apart.
class _Stripes extends CustomPainter {
  _Stripes(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 12 / 1.4142;
    for (var x = -size.height; x < size.width; x += 24 / 1.4142) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), paint);
    }
  }

  @override
  bool shouldRepaint(_Stripes oldDelegate) => oldDelegate.color != color;
}
