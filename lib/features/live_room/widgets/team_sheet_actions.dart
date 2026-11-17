import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/ui.dart';

import 'board_action_button.dart';

/// The team sheet's three ways to reach a team: "Sună căpitanul", "Mesaj",
/// "Hartă". Side by side when every label fits whole; otherwise the call gets
/// its own row above the other two. "Hartă" is greyed out without [onMap].
class TeamSheetActions extends StatelessWidget {
  const TeamSheetActions({super.key, required this.onCall, required this.onMessage, required this.onMap});

  static const double _gap = 8;
  static const String _call = 'Sună căpitanul';
  static const String _message = 'Mesaj';
  static const String _map = 'Hartă';

  final VoidCallback onCall;
  final VoidCallback onMessage;
  final VoidCallback? onMap;

  bool _fitInOneRow(BuildContext context, double width) {
    final style = DefaultTextStyle.of(context).style.merge(BoardActionButton.labelStyle(context.colors.accent));
    final scaler = MediaQuery.textScalerOf(context);
    final each = (width - 2 * _gap) / 3 - BoardActionButton.chromeWidth;
    for (final label in const [_call, _message, _map]) {
      final painter = TextPainter(
        text: TextSpan(text: label, style: style),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
        maxLines: 1,
      )..layout();
      final fits = painter.width <= each;
      painter.dispose();
      if (!fits) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final colour = context.colors.accent;
    final call = BoardActionButton(label: _call, icon: TablerIcons.phone, colour: colour, onTap: onCall);
    final message = BoardActionButton(label: _message, icon: TablerIcons.message_circle, colour: colour, onTap: onMessage);
    final map = BoardActionButton(label: _map, icon: TablerIcons.map_pin, colour: colour, onTap: onMap);
    return LayoutBuilder(builder: (context, constraints) {
      if (_fitInOneRow(context, constraints.maxWidth)) {
        return Row(children: [
          Expanded(child: call),
          const SizedBox(width: _gap),
          Expanded(child: message),
          const SizedBox(width: _gap),
          Expanded(child: map),
        ]);
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          call,
          Row(children: [
            Expanded(child: message),
            const SizedBox(width: _gap),
            Expanded(child: map),
          ]),
        ],
      );
    });
  }
}
