import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';

import 'dashed_line.dart';
import 'measure_size.dart';
import 'ticket_clipper.dart';

/// The ticket of mockup 10: a coloured top, a dashed tear with a notch on
/// each side, and a white bottom.
class TicketCard extends StatefulWidget {
  const TicketCard({super.key, required this.topFill, required this.top, required this.bottom});

  final Color topFill;
  final Widget top;
  final Widget bottom;

  @override
  State<TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends State<TicketCard> {
  double _cut = 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PhysicalShape(
      clipper: TicketClipper(_cut),
      color: colors.panel,
      elevation: 14,
      shadowColor: colors.liveCard,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MeasureSize(
            onChange: (size) {
              if (mounted && size.height != _cut) setState(() => _cut = size.height);
            },
            child: ColoredBox(
              color: widget.topFill,
              child: Padding(padding: const EdgeInsets.fromLTRB(18, 10, 18, 18), child: widget.top),
            ),
          ),
          DashedLine(color: colors.border),
          Padding(padding: const EdgeInsets.fromLTRB(18, 16, 18, 18), child: widget.bottom),
        ],
      ),
    );
  }
}
