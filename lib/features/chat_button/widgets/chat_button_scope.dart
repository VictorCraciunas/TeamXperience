import 'package:flutter/widgets.dart';

import '../controller/chat_button_controller.dart';
import '../controller/chat_button_spots.dart';

/// Hands the pages under the navigator the [ChatButtonSpots] the floating
/// chat button reads (it lives above the navigator, in MaterialApp.builder),
/// and its [controller], so a page can keep room for the button.
class ChatButtonScope extends InheritedWidget {
  const ChatButtonScope({super.key, required this.spots, this.controller, required super.child});

  final ChatButtonSpots spots;
  final ChatButtonController? controller;

  static ChatButtonScope? _of(BuildContext context) => context.getInheritedWidgetOfExactType<ChatButtonScope>();

  /// Null outside the app's layer (a page pumped alone in a test).
  static ChatButtonSpots? maybeOf(BuildContext context) => _of(context)?.spots;

  /// The button's controller; null outside the app's layer.
  static ChatButtonController? controllerOf(BuildContext context) => _of(context)?.controller;

  @override
  bool updateShouldNotify(ChatButtonScope oldWidget) =>
      spots != oldWidget.spots || controller != oldWidget.controller;
}
