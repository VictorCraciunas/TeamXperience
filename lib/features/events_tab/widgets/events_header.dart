import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/components/misc/pill_switch.dart';
import 'package:teamxperience/ui/components/navigation/tab_header.dart';
import 'package:teamxperience/ui/ui.dart';

/// The top of the Evenimente tab, as in mockup 03: the title, a round search
/// button and the Listă / Hartă switch.
class EventsHeader extends StatelessWidget {
  const EventsHeader({
    super.key,
    required this.mapMode,
    required this.onMode,
    required this.onToggleSearch,
  });

  final bool mapMode;
  final ValueChanged<bool> onMode;
  final VoidCallback onToggleSearch;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TabHeader(
      title: 'Evenimente',
      trailing: Semantics(
        button: true,
        label: 'Caută',
        child: GestureDetector(
          onTap: onToggleSearch,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: colors.iconButtonBg, shape: BoxShape.circle),
            child: Icon(TablerIcons.search, size: 17, color: colors.text),
          ),
        ),
      ),
      bottom: PillSwitch(
        options: const [(TablerIcons.list, 'Listă'), (TablerIcons.map, 'Hartă')],
        selected: mapMode ? 1 : 0,
        onSelected: (i) => onMode(i == 1),
      ),
    );
  }
}
