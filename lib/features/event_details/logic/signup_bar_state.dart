import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/utils/event_formats.dart';

import 'enrolment_window.dart';

/// What the action of the bar does.
enum SignupAction { register, teamDetails, enterCode, continueGame, none }

/// The colour of the bar's icon; the screen maps it to `BarTone`.
enum SignupTone { neutral, success, accent }

/// Everything the bar at the bottom of the event page shows.
class SignupBar {
  const SignupBar({
    required this.title,
    this.detail,
    this.inlineDetail = false,
    this.tone = SignupTone.neutral,
    this.highlighted = false,
    this.prominent = false,
    this.actionLabel,
    this.action = SignupAction.none,
  });

  final String title;
  final String? detail;
  final bool inlineDetail;
  final SignupTone tone;
  final bool highlighted;

  /// A navy button when true, an accent link when false.
  final bool prominent;
  final String? actionLabel;
  final SignupAction action;
}

String _teamsLine(int n) => switch (n) {
      0 => 'Fii prima echipă',
      1 => 'o echipă înscrisă',
      _ => '$n echipe înscrise',
    };

/// The bar for [event] at [now]. [team] is the player's team, or null when
/// they have none (or it could not be found).
SignupBar signupBar({required Event event, required DateTime now, Team? team, required int teamsCount}) {
  if (isOverAt(event, now)) return const SignupBar(title: 'Evenimentul s-a încheiat');

  if (team != null) {
    if (team.hasStarted && !team.hasFinished) {
      return SignupBar(
        title: 'Echipa ${team.name} e în joc',
        tone: SignupTone.accent,
        highlighted: true,
        actionLabel: 'Continuă',
        action: SignupAction.continueGame,
      );
    }
    if (!team.hasStarted && inEnterWindow(event, now)) {
      return SignupBar(
        title: 'A început',
        detail: '${enterMinutesLeft(event, now)} min să intri',
        inlineDetail: true,
        tone: SignupTone.accent,
        highlighted: true,
        actionLabel: 'Introdu codul',
        action: SignupAction.enterCode,
      );
    }
    final members = team.numberOfMembers;
    return SignupBar(
      title: team.name,
      detail: members == 1 ? '1 membru' : '$members membri',
      inlineDetail: true,
      tone: SignupTone.success,
      actionLabel: 'Echipa ta',
      action: SignupAction.teamDetails,
    );
  }

  final opens = event.dateStartEnrollment;
  if (opens != null && enrolmentNotOpenYet(event, now)) {
    return SignupBar(title: 'Înscrierile se deschid pe ${dayAndMonth(opens)}');
  }
  if (enrolmentClosed(event, now)) {
    return SignupBar(title: 'Înscrierile s-au închis', detail: _teamsLine(teamsCount));
  }
  final max = event.maxTeams;
  if (max != null && teamsCount >= max) {
    return SignupBar(title: 'Nu mai sunt locuri', detail: _teamsLine(teamsCount));
  }

  final days = enrolmentDaysLeft(event, now);
  return SignupBar(
    title: switch (days) {
      null => 'Înscrieri deschise',
      0 => 'Ultima zi',
      1 => 'Mai e o zi',
      _ => 'Mai sunt $days zile',
    },
    detail: _teamsLine(teamsCount),
    prominent: true,
    actionLabel: 'Înscrie echipa',
    action: SignupAction.register,
  );
}
