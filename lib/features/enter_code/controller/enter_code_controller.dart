import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/features/enter_code/logic/start_code_check.dart';
import 'package:teamxperience/features/enter_code/logic/start_code_flow.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/service/team_service/team_service.dart';

import '../../../constants/routes.dart';
import '../../../state_management/user_provider.dart';

class EnterCodeController {
  late BuildContext context;
  TextEditingController codeController = TextEditingController();
  TeamService teamService = TeamService();
  late Event event;
  late final StartCodeFlow _flow = StartCodeFlow(
    findTeam: () async {
      final user = context.read<UserProvider>().currentUser;
      if (user == null) return null;
      return teamService.getUserTeamForEvent(event.eventId, user.uid);
    },
    startTeam: (team) => teamService.startTeam(event.eventId, team.name),
  );

  EnterCodeController(this.event, this.context);

  /// Checks the typed code and, when it is right, starts the team and opens
  /// the game. Null while an earlier tap is still being handled.
  Future<StartCodeResult?> submit() async {
    final outcome = await _flow.submit(input: codeController.text, event: event, now: DateTime.now());
    if (outcome == null) return null;

    final (result, team) = outcome;
    if (team != null && context.mounted) {
      Navigator.pushNamed(context, Routes.eventGame, arguments: {'event': event, 'team': team});
    }
    return result;
  }

  /// The title and message the screen shows for a refused code.
  static (String, String)? messageFor(StartCodeResult? result) => switch (result) {
        null || StartCodeResult.ok => null,
        StartCodeResult.wrong => ('Cod greșit', 'Codul nu e corect. Verifică literele.'),
        StartCodeResult.tooEarly => ('Prea devreme', 'Jocul nu a început încă.'),
        StartCodeResult.closed => ('Prea târziu', 'Timpul pentru intrare s-a terminat.'),
        StartCodeResult.noTeam => ('Nu ai echipă', 'Nu găsim echipa ta la acest eveniment. Scrie-i organizatorului.'),
        StartCodeResult.failed => ('Nu a mers', 'Verifică internetul și încearcă din nou.'),
      };
}
