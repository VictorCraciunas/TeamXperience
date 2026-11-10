import 'package:flutter/widgets.dart';

/// A ticket: a rounded card with a round notch cut into each side at [cut]
/// px from the top, where the ticket's two parts meet (mockup 10).
class TicketClipper extends CustomClipper<Path> {
  const TicketClipper(this.cut, {this.radius = 22, this.notch = 13});

  final double cut;
  final double radius;
  final double notch;

  @override
  Path getClip(Size size) {
    final card = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)));
    final notches = Path()
      ..addOval(Rect.fromCircle(center: Offset(0, cut), radius: notch))
      ..addOval(Rect.fromCircle(center: Offset(size.width, cut), radius: notch));
    return Path.combine(PathOperation.difference, card, notches);
  }

  @override
  bool shouldReclip(TicketClipper oldClipper) =>
      oldClipper.cut != cut || oldClipper.radius != radius || oldClipper.notch != notch;
}
