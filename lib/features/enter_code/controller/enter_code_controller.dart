import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/features/enter_code/logic/start_code_check.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/service/team_service/team_service.dart';

import '../../../constants/routes.dart';
import '../../../state_management/user_provider.dart';

class EnterCodeController {
  late BuildContext context;
  TextEditingController codeController = TextEditingController();
  TeamService teamService = TeamService();
  late Event event;

  EnterCodeController(this.event, this.context);

  /// Checks the typed code and, when it is right, starts the team and opens
  /// the game. A user without a team for this event gets [StartCodeResult.wrong].
  Future<StartCodeResult> submit() async {
    final user = context.read<UserProvider>().currentUser;
    if (user == null) return StartCodeResult.wrong;

    final result = checkStartCode(input: codeController.text, event: event, now: DateTime.now());
    if (result != StartCodeResult.ok) return result;

    final team = await teamService.getUserTeamForEvent(event.eventId, user.uid);
    if (team == null) return StartCodeResult.wrong;

    await teamService.startTeam(event.eventId, team.name);
    if (context.mounted) {
      Navigator.pushNamed(context, Routes.eventGame, arguments: {'event': event, 'team': team});
    }
    return StartCodeResult.ok;
  }

  /// The title and message the screen shows for a refused code.
  static (String, String)? messageFor(StartCodeResult result) => switch (result) {
        StartCodeResult.ok => null,
        StartCodeResult.wrong => ('Cod greșit', 'Codul nu e corect. Verifică literele.'),
        StartCodeResult.tooEarly => ('Prea devreme', 'Jocul nu a început încă.'),
        StartCodeResult.closed => ('Prea târziu', 'Timpul pentru intrare s-a terminat.'),
      };
}
