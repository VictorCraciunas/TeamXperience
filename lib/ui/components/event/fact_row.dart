import 'package:flutter/material.dart';

/// The row of event facts under the route strip: the date tile 62 wide, then
/// the facts sharing the rest, all the same height.
class FactRow extends StatelessWidget {
  const FactRow({super.key, required this.date, required this.facts});

  final Widget date;
  final List<Widget> facts;

  static const double _gap = 6;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: 76, child: date),
            for (final fact in facts) ...[
              const SizedBox(width: _gap),
              Expanded(child: fact),
            ],
          ],
        ),
      ),
    );
  }
}
