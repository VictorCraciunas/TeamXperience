import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/layout/outline_card.dart';
import 'package:teamxperience/ui/ui.dart';

/// The events that share one spot on the map: "3 evenimente aici" and their
/// cards, scrolling when there are many.
class EventsHereList extends StatelessWidget {
  const EventsHereList({super.key, required this.count, required this.children});

  final int count;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tallest = MediaQuery.sizeOf(context).height * .45;
    return OutlineCard(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: tallest),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
              child: Text(
                '$count evenimente aici',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, height: 1.45, color: colors.text),
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: children.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) => children[i],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
