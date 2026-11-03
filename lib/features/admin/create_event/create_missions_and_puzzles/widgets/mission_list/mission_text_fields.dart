import 'package:flutter/material.dart';
import 'package:teamxperience/model/mission.dart';
import 'package:teamxperience/ui/components/inputs/app_text_field.dart';
import 'package:teamxperience/ui/ui.dart';

/// The mission's title, its line for the event page and whether the page shows
/// it before the game.
class MissionTextFields extends StatefulWidget {
  const MissionTextFields({super.key, required this.mission, required this.onChanged});

  final Mission mission;
  final void Function({String? title, String? teaser, bool? isTeaserPublic}) onChanged;

  @override
  State<MissionTextFields> createState() => _MissionTextFieldsState();
}

class _MissionTextFieldsState extends State<MissionTextFields> {
  late final TextEditingController _title = TextEditingController(text: widget.mission.title ?? '');
  late final TextEditingController _teaser = TextEditingController(text: widget.mission.teaser ?? '');
  late bool _public = widget.mission.isTeaserPublic;

  @override
  void dispose() {
    _title.dispose();
    _teaser.dispose();
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
      ],
    );
  }
}
