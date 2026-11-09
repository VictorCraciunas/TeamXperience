import 'package:flutter/material.dart';

import '../../theme/app_radius.dart';
import '../../theme/theme_context.dart';
import '../layout/outline_card.dart';
import 'event_picture.dart';

/// An event in a two-column grid: its picture with the date on it, then the
/// name and the route facts.
class EventGridCard extends StatelessWidget {
  const EventGridCard({
    super.key,
    required this.title,
    required this.date,
    required this.facts,
    this.imageUrl,
    required this.onTap,
  });

  final String title;
  final String date;
  final String facts;
  final String? imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: OutlineCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                EventPicture(
                  url: imageUrl,
                  height: 96,
                  fill: colors.accent,
                  bottomLeft: date.isEmpty
                      ? null
                      : DecoratedBox(
                          decoration: BoxDecoration(color: colors.panel, borderRadius: BorderRadius.circular(99)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                            child: Text(date, style: TextStyle(fontSize: 13, height: 1.45, color: colors.text)),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.45, color: colors.text),
                      ),
                      if (facts.isNotEmpty)
                        Text(
                          facts,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, height: 1.45, color: colors.muted),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
