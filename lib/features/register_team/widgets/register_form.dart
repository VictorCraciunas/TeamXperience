import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/buttons/navy_button.dart';
import 'package:teamxperience/ui/components/feedback/field_status_line.dart';
import 'package:teamxperience/ui/components/inputs/size_picker.dart';
import 'package:teamxperience/ui/components/layout/outline_card.dart';
import 'package:teamxperience/ui/theme/app_text_styles.dart';

import 'consent_row.dart';
import 'field_label.dart';
import 'package:teamxperience/ui/components/inputs/register_input.dart';
import 'team_name_field.dart';

/// The form of mockup 04 (left phone), fed by values and callbacks: the team
/// name, the size, the captain's phone, two consents and the button. [onSubmit]
/// null greys the button out. [locked] makes the form read-only and hides the
/// button, for after the team is registered; while [sending] it is read-only
/// too, with the button shown as busy.
/// The organiser's consent texts. The first two are needed to sign up.
const rulesConsentText = 'Sunt de acord cu Regulamentul Specific al activității.';
const dataConsentText = 'Sunt de acord cu folosirea datelor cu caracter personal.';
const photoConsentText = 'Sunt de acord ca imaginile și video-urile care sunt realizate de organizatori sau de membrii echipei mele în timpul activității să îmi fie trimise după eveniment. În același timp ASOCIAȚIA VBE SIBIU poate folosi aceste resurse pentru promovare.';

class RegisterForm extends StatelessWidget {
  const RegisterForm({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.onNameChanged,
    required this.onPhoneChanged,
    required this.nameStatus,
    required this.nameStatusText,
    required this.sizeMin,
    required this.sizeMax,
    required this.size,
    required this.onSizeChanged,
    required this.rulesAccepted,
    required this.onRulesChanged,
    required this.dataAccepted,
    required this.onDataChanged,
    required this.photoConsent,
    required this.onPhotoChanged,
    required this.onSubmit,
    this.sending = false,
    this.locked = false,
  });

  final TextEditingController nameController;
  final TextEditingController phoneController;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onPhoneChanged;
  final FieldStatus nameStatus;
  final String nameStatusText;
  final int sizeMin;
  final int sizeMax;
  final int size;
  final ValueChanged<int> onSizeChanged;
  final bool rulesAccepted;
  final ValueChanged<bool> onRulesChanged;
  final bool dataAccepted;
  final ValueChanged<bool> onDataChanged;
  final bool photoConsent;
  final ValueChanged<bool> onPhotoChanged;
  final VoidCallback? onSubmit;
  final bool sending;
  final bool locked;

  static const double _gap = 12;

  @override
  Widget build(BuildContext context) {
    final readOnly = locked || sending;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FieldLabel('Numele echipei'),
          TeamNameField(
            controller: nameController,
            onChanged: onNameChanged,
            status: nameStatus,
            statusText: nameStatusText,
            readOnly: readOnly,
          ),
          const SizedBox(height: _gap),
          const FieldLabel('Câți veți fi?'),
          IgnorePointer(
            ignoring: readOnly,
            child: SizePicker(
              min: sizeMin,
              max: sizeMax,
              value: size,
              onChanged: onSizeChanged,
            ),
          ),
          const SizedBox(height: _gap),
          const FieldLabel('Telefonul căpitanului'),
          RegisterInput(
            controller: phoneController,
            onChanged: onPhoneChanged,
            readOnly: readOnly,
            hint: '0722 123 456',
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              'Numele și emailul le luăm din contul tău.',
              style: AppTextStyles.smallMuted(context),
            ),
          ),
          const SizedBox(height: _gap),
          OutlineCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConsentRow(
                  label: rulesConsentText,
                  value: rulesAccepted,
                  onChanged: readOnly ? null : onRulesChanged,
                ),
                const SizedBox(height: 10),
                ConsentRow(
                  label: dataConsentText,
                  value: dataAccepted,
                  onChanged: readOnly ? null : onDataChanged,
                ),
                const SizedBox(height: 10),
                ConsentRow(
                  label: photoConsentText,
                  value: photoConsent,
                  onChanged: readOnly ? null : onPhotoChanged,
                ),
              ],
            ),
          ),
          if (!locked) ...[
            const SizedBox(height: _gap),
            NavyButton(
              label: 'Înscrie echipa',
              onPressed: onSubmit,
              isLoading: sending,
            ),
          ],
        ],
      ),
    );
  }
}
