import 'package:flutter/material.dart';
import 'package:teamxperience/features/admin/create_event/create_event_landing/controller/create_event_controller.dart';
import 'package:teamxperience/ui/components/inputs/app_text_field.dart';
import 'package:teamxperience/ui/ui.dart';

/// "Începutul jocului" on the event form: the letter teams read before the
/// first mission, who signs it, how many hints a mission allows and how long
/// after the start the code still works; then "Sfârșitul jocului", what the
/// finish screen says. All optional.
class GameStartSection extends StatelessWidget {
  const GameStartSection({
    super.key,
    required this.letter,
    required this.signature,
    required this.hintsPerMission,
    required this.enterWindow,
    required this.finishTitle,
    required this.finishMessage,
  });

  final TextEditingController letter;
  final TextEditingController signature;
  final TextEditingController hintsPerMission;
  final TextEditingController enterWindow;
  final TextEditingController finishTitle;
  final TextEditingController finishMessage;

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 20);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Începutul jocului', style: AppTextStyles.sectionTitle(context)),
        const SizedBox(height: 12),
        AppTextField(
          controller: letter,
          label: 'Scrisoarea de început',
          hint: 'Ce citesc echipele înainte de prima misiune',
          maxLines: null,
          keyboardType: TextInputType.multiline,
        ),
        gap,
        AppTextField(controller: signature, label: 'Semnătura', hint: 'Ex. Cartograful'),
        gap,
        AppTextField(
          controller: hintsPerMission,
          label: 'Indicii pe misiune',
          hint: 'Gol = 1',
          keyboardType: TextInputType.number,
          validator: (text) => CreateEventController.hintsProblem(text ?? ''),
        ),
        gap,
        AppTextField(
          controller: enterWindow,
          label: 'Minute pentru codul de start',
          hint: 'Gol = 60',
          keyboardType: TextInputType.number,
          validator: (text) => CreateEventController.enterWindowProblem(text ?? ''),
        ),
        const SizedBox(height: 28),
        Text('Sfârșitul jocului', style: AppTextStyles.sectionTitle(context)),
        const SizedBox(height: 12),
        AppTextField(controller: finishTitle, label: 'Titlul de final', hint: 'Gol = „Ați terminat traseul!”'),
        gap,
        AppTextField(
          controller: finishMessage,
          label: 'Mesajul de final',
          hint: 'Ex. Vulpile au moștenit secretul cartografului.',
          maxLines: null,
          keyboardType: TextInputType.multiline,
        ),
      ],
    );
  }
}
