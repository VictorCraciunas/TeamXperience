import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/model/team.dart';

/// What the Home hero card can do, supplied by the screen so the card itself
/// stays free of navigation and Firebase code.
class HomeHeroActions {
  const HomeHeroActions({
    required this.onContinue,
    required this.onChat,
    required this.onEnterCode,
    required this.onDetails,
    required this.onShare,
    required this.onRegister,
  });

  final void Function(Event event, Team team) onContinue;
  final void Function(Event event, Team team) onChat;
  final void Function(Event event) onEnterCode;
  final void Function(Event event) onDetails;
  final void Function(Event event) onShare;
  final void Function(Event event) onRegister;
}
