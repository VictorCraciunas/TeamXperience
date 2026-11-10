import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/components/game/round_icon_button.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

/// The top of the route screen (mockup 06): close, the event's name in its
/// voice font with the team's place under it, chat; then the played and left
/// clocks.
class RouteHeader extends StatelessWidget {
  const RouteHeader({
    super.key,
    required this.eventName,
    required this.placeLine,
    required this.played,
    required this.left,
    required this.onClose,
    required this.onChat,
  });

  final String eventName;

  /// "Vulpile · locul 2 din 12"; null until the ranking arrives.
  final String? placeLine;
  final String played;
  final String left;
  final VoidCallback onClose;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    final place = placeLine;
    final small = TextStyle(fontSize: 13, height: 1.45, color: palette.ink);

    Widget clock(IconData icon, String value, String word) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: palette.ink),
        const SizedBox(width: 3),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: value, style: const TextStyle(fontFamily: 'Monospace', fontWeight: FontWeight.w500)),
              TextSpan(text: ' $word'),
            ],
          ),
          style: small,
        ),
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          // The buttons' 48 px tap areas take up 8 of the mockup's padding.
          padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
          child: Row(
            children: [
              RoundIconButton(icon: TablerIcons.x, label: 'Închide', onTap: onClose),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      Text(
                        eventName,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontFamily: palette.voiceFont, fontSize: 17, height: 1.45, color: palette.ink),
                      ),
                      if (place != null)
                        Text(place, textAlign: TextAlign.center, style: small.copyWith(color: palette.muted)),
                    ],
                  ),
                ),
              ),
              RoundIconButton(icon: TablerIcons.message_circle, label: 'Chat cu organizatorul', onTap: onChat),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            children: [clock(TablerIcons.clock, played, 'jucat'), clock(TablerIcons.hourglass, left, 'rămas')],
          ),
        ),
      ],
    );
  }
}
