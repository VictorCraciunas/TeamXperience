import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/play_tab/widgets/ticket_clipper.dart';

void main() {
  test('the ticket has a notch on each side at the cut', () {
    final path = const TicketClipper(100).getClip(const Size(300, 400));
    expect(path.contains(const Offset(5, 100)), isFalse);
    expect(path.contains(const Offset(295, 100)), isFalse);
    expect(path.contains(const Offset(150, 100)), isTrue);
    expect(path.contains(const Offset(5, 50)), isTrue);
    expect(path.contains(const Offset(1, 1)), isFalse, reason: 'rounded corner');
  });

  test('a new cut reclips', () {
    expect(const TicketClipper(100).shouldReclip(const TicketClipper(120)), isTrue);
    expect(const TicketClipper(100).shouldReclip(const TicketClipper(100)), isFalse);
  });
}
