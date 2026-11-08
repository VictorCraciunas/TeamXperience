import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:latlong2/latlong.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';
import 'package:teamxperience/ui/ui.dart';

import '../logic/coordinates.dart';

/// A place on the map, as the editor passes it around.
typedef MapPlace = ({double lat, double lng});

/// Opens the map; the place chosen, or null when cancelled.
Future<MapPlace?> showPinPicker(BuildContext context, {MapPlace? initial, MapPlace? near}) {
  return Navigator.of(context).push<MapPlace>(
    MaterialPageRoute(fullscreenDialog: true, builder: (_) => PinPickerScreen(initial: initial, near: near)),
  );
}

/// The organiser moves the map under a fixed pin, so a thumb never hides the
/// spot being chosen.
class PinPickerScreen extends StatefulWidget {
  const PinPickerScreen({super.key, this.initial, this.near});

  /// The place already set.
  final MapPlace? initial;

  /// Somewhere to start from when no place is set yet.
  final MapPlace? near;

  @override
  State<PinPickerScreen> createState() => _PinPickerScreenState();
}

class _PinPickerScreenState extends State<PinPickerScreen> {
  final MapController _map = MapController();

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  void _choose() {
    final centre = _map.camera.center;
    Navigator.of(context).pop<MapPlace>((lat: centre.latitude, lng: centre.longitude));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final start = pinStart(widget.initial, widget.near);
    return Scaffold(
      appBar: const MyAppBar(appBarText: 'Alege locul'),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                FlutterMap(
                  mapController: _map,
                  options: MapOptions(
                    initialCenter: LatLng(start.lat, start.lng),
                    initialZoom: widget.initial == null && widget.near == null ? 13 : 16,
                    maxZoom: 19,
                    minZoom: 4,
                    backgroundColor: colors.inset,
                    interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.teamxperience.app',
                    ),
                  ],
                ),
                IgnorePointer(
                  child: Padding(
                    // The tip of the pin sits on the map's centre.
                    padding: const EdgeInsets.only(bottom: 36),
                    child: Icon(TablerIcons.map_pin_filled, size: 36, color: colors.danger),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.page),
              child: AppButton(label: 'Alege acest loc', onPressed: _choose),
            ),
          ),
        ],
      ),
    );
  }
}
