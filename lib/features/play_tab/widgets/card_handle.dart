import 'package:flutter/widgets.dart';

/// The small bar on top of a pop-up card that says it can be dragged down.
class CardHandle extends StatelessWidget {
  const CardHandle({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 40,
          height: 5,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
      );
}
