import 'package:flutter/material.dart';
import 'package:teamxperience/features/admin/create_event/common_widgets/pin_field_button.dart';
import 'package:teamxperience/features/admin/create_event/common_widgets/pin_picker_screen.dart';
import 'package:teamxperience/features/admin/create_event/logic/coordinates.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/ui/components/inputs/app_text_field.dart';
import 'package:teamxperience/ui/ui.dart';

/// The mission's title, its line for the event page, whether the page shows
/// it before the game, and where the mission is (optional).
class MissionTextFields extends StatefulWidget {
  const MissionTextFields({super.key, required this.mission, required this.onChanged, this.onPlaceChanged, this.near});

  final Mission mission;
  final void Function({String? title, String? teaser, bool? isTeaserPublic}) onChanged;

  /// A place that can be read, or null once the field is emptied. A half
  /// typed place reports nothing.
  final void Function(({double lat, double lng})? place)? onPlaceChanged;

  /// Where the map opens when the mission has no place: the event's start.
  final MapPlace? near;

  @override
  State<MissionTextFields> createState() => _MissionTextFieldsState();
}

class _MissionTextFieldsState extends State<MissionTextFields> {
  late final TextEditingController _title = TextEditingController(text: widget.mission.title ?? '');
  late final TextEditingController _teaser = TextEditingController(text: widget.mission.teaser ?? '');
  late bool _public = widget.mission.isTeaserPublic;
  late final TextEditingController _place = TextEditingController(text: _placeText(widget.mission));

  static String _placeText(Mission mission) {
    final lat = mission.latitude;
    final lng = mission.longitude;
    return lat == null || lng == null ? '' : formatCoordinates(lat, lng);
  }

  void _placeChanged(String text) {
    final report = widget.onPlaceChanged;
    if (report == null) return;
    if (text.trim().isEmpty) {
      report(null);
      return;
    }
    final place = parseCoordinates(text);
    if (place != null) report(place);
  }

  @override
  void dispose() {
    _title.dispose();
    _teaser.dispose();
    _place.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: _title,
          label: 'Titlul misiunii',
          hint: 'Ex. Scara Pasajului',
          onChanged: (text) => widget.onChanged(title: text),
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _teaser,
          label: 'O frază pentru pagina evenimentului',
          hint: 'Ex. Numără treptele. Nu toate sunt la vedere.',
          onChanged: (text) => widget.onChanged(teaser: text),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Arată pe pagina evenimentului', style: AppTextStyles.body(context)),
          value: _public,
          onChanged: (value) {
            setState(() => _public = value);
            widget.onChanged(isTeaserPublic: value);
          },
        ),
        AppTextField(
          controller: _place,
          label: 'Locul misiunii (opțional)',
          hint: 'Ex. 45.7971, 24.1520',
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          validator: (text) {
            final value = text ?? '';
            return value.trim().isEmpty || parseCoordinates(value) != null ? null : 'Coordonate greșite';
          },
          onChanged: _placeChanged,
        ),
        const SizedBox(height: 8),
        PinFieldButton(
          current: () => parseCoordinates(_place.text),
          near: widget.near,
          onPicked: (place) {
            final text = formatCoordinates(place.lat, place.lng);
            _place.text = text;
            _placeChanged(text);
          },
        ),
      ],
    );
  }
}
