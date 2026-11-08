import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:teamxperience/ui/components/misc/app_chip.dart';
import 'package:teamxperience/ui/components/misc/app_chip_style.dart';

import 'pin_picker_screen.dart';

/// "Alege pe hartă", under a coordinates field. Cancelling the map changes
/// nothing.
class PinFieldButton extends StatelessWidget {
  const PinFieldButton({super.key, required this.current, this.near, required this.onPicked, this.picker});

  /// The place the field holds now, or null when it cannot be read.
  final MapPlace? Function() current;

  /// Where to start from when the field holds no place.
  final MapPlace? near;
  final ValueChanged<MapPlace> onPicked;

  /// Replaces the map (for tests).
  final Future<MapPlace?> Function(BuildContext context, MapPlace? initial, MapPlace? near)? picker;

  Future<void> _open(BuildContext context) async {
    final initial = current();
    final open = picker;
    final place = open == null
        ? await showPinPicker(context, initial: initial, near: near)
        : await open(context, initial, near);
    if (place != null) onPicked(place);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: AppChip(
        label: 'Alege pe hartă',
        icon: TablerIcons.map_pin,
        style: AppChipStyle.outlined,
        onTap: () => _open(context),
      ),
    );
  }
}
