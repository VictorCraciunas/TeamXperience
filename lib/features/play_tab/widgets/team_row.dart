import 'dart:math';

import 'package:flutter/material.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/ui.dart';

/// The team on a ticket: overlapping initials, a dashed circle per free
/// place, then "Echipa Vulpile" over [line] (mockup 10).
class TeamRow extends StatelessWidget {
  const TeamRow({super.key, required this.team, required this.places, required this.line});

  final Team team;

  /// The team's largest size, for the free places.
  final int places;
  final String line;

  static const double _size = 32;
  static const double _step = 24;
  static const int _most = 6;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shown = team.memberList.take(_most).toList();
    final free = max(0, min(places, _most) - shown.length);
    final fills = [colors.tickOnNavy, colors.amber, colors.navActivePill];
    final count = shown.length + free;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (count > 0) ...[
            SizedBox(
              width: _size + (count - 1) * _step,
              height: _size,
              child: Stack(
                children: [
                  for (var i = 0; i < shown.length; i++)
                    _circle(
                      i,
                      BoxDecoration(
                        color: fills[i % fills.length],
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.panel, width: 2),
                      ),
                      Text(
                        shown[i].initials,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.onTick),
                      ),
                    ),
                  for (var i = 0; i < free; i++)
                    _circle(
                      shown.length + i,
                      BoxDecoration(
                        color: colors.panel,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.border, width: 2),
                      ),
                      null,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Echipa ${team.name}',
                  style: TextStyle(fontSize: 14, height: 1.45, fontWeight: FontWeight.w600, color: colors.text),
                ),
                Text(line, style: TextStyle(fontSize: 13, height: 1.45, color: colors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(int index, BoxDecoration decoration, Widget? child) => Positioned(
        left: index * _step,
        child: Container(
          width: _size,
          height: _size,
          alignment: Alignment.center,
          decoration: decoration,
          child: child,
        ),
      );
}
