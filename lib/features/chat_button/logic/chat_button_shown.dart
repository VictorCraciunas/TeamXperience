import 'package:teamxperience/constants/routes.dart';

/// The route on top of the app's navigator.
class TopRoute {
  const TopRoute({required this.name, required this.isPage, this.arguments, this.aboveChat = false});

  final String? name;

  /// A full page, not a dialog, sheet or menu.
  final bool isPage;
  final Object? arguments;

  /// Pushed without a name over the chat, like its full-screen photo.
  final bool aboveChat;
}

/// Whether the route on top, [names] being the navigator's routes bottom to
/// top, is an unnamed one opened from the chat (its full-screen photo): the
/// first named route under it is [Routes.chatScreen].
bool aboveChat(List<String?> names) {
  if (names.isEmpty || names.last != null) return false;
  for (final name in names.reversed) {
    if (name != null) return name == Routes.chatScreen;
  }
  return false;
}

/// The chat itself, and the pages before signing in.
const routesWithoutChatButton = {
  Routes.chatScreen,
  Routes.redirect,
  Routes.splash,
  Routes.login,
  Routes.signup,
  Routes.register,
  Routes.forgotPassword,
};

/// The floating chat button shows for a [player] with unread organiser
/// messages, on a page (never over a dialog or sheet, which it could cover,
/// nor over a page opened from the chat), while the keyboard is down and the
/// page has not asked to hide it.
bool chatButtonShown({
  required bool player,
  required int unread,
  required TopRoute? top,
  required bool keyboardOpen,
  required bool hiddenByPage,
}) {
  if (!player || unread <= 0 || keyboardOpen || hiddenByPage || top == null) return false;
  if (!top.isPage || top.aboveChat) return false;
  return !routesWithoutChatButton.contains(top.name);
}
