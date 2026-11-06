import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/theme/event_palette.dart';
import 'package:teamxperience/ui/theme/event_theme_scope.dart';

/// Opens a puzzle's hint in a sheet in the event's colours. The sheet lives
/// above the screen's scope, so the [palette] is passed in.
Future<void> showHintSheet(BuildContext context, {required String hint, required EventPalette palette}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: palette.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => EventThemeScope(palette: palette, child: HintSheet(hint: hint)),
  );
}

/// The hint text under a bulb and "Indiciu" in the event's voice font.
class HintSheet extends StatelessWidget {
  const HintSheet({super.key, required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    final palette = context.eventPalette;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(TablerIcons.bulb, size: 18, color: palette.accent),
                const SizedBox(width: 6),
                Text('Indiciu', style: TextStyle(fontFamily: palette.voiceFont, fontSize: 17, height: 1.3, color: palette.ink)),
              ],
            ),
            const SizedBox(height: 10),
            Flexible(
              child: SingleChildScrollView(
                child: Text(hint, style: TextStyle(fontSize: 14, height: 1.5, color: palette.ink)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
