import 'package:flutter/widgets.dart';

import '../controller/chat_button_spots.dart';

/// Hands the pages under the navigator the [ChatButtonSpots] the floating
/// chat button reads (it lives above the navigator, in MaterialApp.builder).
class ChatButtonScope extends InheritedWidget {
  const ChatButtonScope({super.key, required this.spots, required super.child});

  final ChatButtonSpots spots;

  /// Null outside the app's layer (a page pumped alone in a test).
  static ChatButtonSpots? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<ChatButtonScope>()?.spots;

  @override
  bool updateShouldNotify(ChatButtonScope oldWidget) => spots != oldWidget.spots;
}
