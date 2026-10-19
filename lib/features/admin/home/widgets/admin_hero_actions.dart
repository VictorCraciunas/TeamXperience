import 'package:teamxperience/model/event.dart';

/// What the admin Home hero can do, supplied by the screen.
class AdminHeroActions {
  const AdminHeroActions({
    required this.onManage,
    required this.onMap,
    required this.onChats,
    required this.onTeams,
    required this.onNotify,
  });

  final void Function(Event event) onManage;
  final void Function(Event event) onMap;
  final void Function(Event event) onChats;
  final void Function(Event event) onTeams;
  final void Function(Event event) onNotify;
}
