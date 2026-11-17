import 'package:flutter/widgets.dart';

import 'chat_button_overlay.dart';
import 'chat_button_scope.dart';
import 'chat_float_button.dart';

/// Space at the end of a scrolling page that has no bottom bar, as tall as
/// the floating chat button while it is up (nothing otherwise), so the page's
/// last button ("Salvează schimbările", "Înscrie echipa") scrolls clear of
/// it. Put it as the scroll's last child. Outside the app's layer it is
/// empty.
class ChatButtonRoom extends StatelessWidget {
  const ChatButtonRoom({super.key});

  /// The button's height and its gap to the bottom edge (or the safe area).
  static const double room = ChatButtonOverlay.side + ChatFloatButton.size;

  @override
  Widget build(BuildContext context) {
    final controller = ChatButtonScope.controllerOf(context);
    if (controller == null) return const SizedBox.shrink();
    // Inside a SafeArea this is 0, the safe area being under the page already.
    final inset = MediaQuery.paddingOf(context).bottom;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => SizedBox(height: controller.unread > 0 ? room + inset : 0),
    );
  }
}
