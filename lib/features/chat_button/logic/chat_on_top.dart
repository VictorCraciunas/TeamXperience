import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/model/team.dart';

import 'chat_key.dart';

/// The chat a route shows: [Routes.chatScreen] with the arguments every
/// caller passes, `{'eventId': String, 'team': Team}`.
ChatKey? chatOnTop(String? routeName, Object? arguments) {
  if (routeName != Routes.chatScreen || arguments is! Map) return null;
  final eventId = arguments['eventId'];
  final team = arguments['team'];
  if (eventId is! String || team is! Team) return null;
  return ChatKey(eventId, team.name);
}
