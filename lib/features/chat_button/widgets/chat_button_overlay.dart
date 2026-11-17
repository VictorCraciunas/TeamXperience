import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../controller/chat_button_controller.dart';
import '../controller/chat_button_spots.dart';
import '../controller/chat_route_watch.dart';
import '../logic/chat_button_shown.dart';
import '../logic/chat_button_texts.dart';
import '../logic/watched_chat.dart';
import 'chat_float_button.dart';
import 'chat_preview_bubble.dart';

/// Draws the floating chat button (and a new message's preview) over the
/// app's pages, bottom right: above the page's bottom bar when it has one
/// ([ChatButtonSpots]), else above the phone's bottom edge.
class ChatButtonOverlay extends StatelessWidget {
  const ChatButtonOverlay({
    super.key,
    required this.controller,
    required this.routes,
    required this.spots,
    required this.player,
    required this.onOpen,
    required this.child,
  });

  final ChatButtonController controller;
  final ChatRouteWatch routes;
  final ChatButtonSpots spots;

  /// A signed-in player; organisers never get the button.
  final bool player;
  final void Function(WatchedChat chat) onOpen;
  final Widget child;

  static const double side = 16;

  /// The gap between a page's bottom bar and the button (the mockup's 104
  /// over its 84 px bar).
  static const double aboveBar = 20;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        ListenableBuilder(
          listenable: Listenable.merge([controller, routes, spots]),
          builder: (context, _) {
            final route = routes.topRoute;
            final chat = controller.chatToOpen;
            final shown = chatButtonShown(
              player: player,
              unread: controller.unread,
              top: routes.top,
              keyboardOpen: MediaQuery.viewInsetsOf(context).bottom > 0,
              hiddenByPage: spots.hiddenOn(route),
            );
            if (!shown || chat == null) return const SizedBox.shrink();

            final padding = MediaQuery.viewPaddingOf(context);
            final bar = spots.clearanceFor(route);
            final bottom = bar > 0 ? bar + aboveBar : padding.bottom + side;
            final width = MediaQuery.sizeOf(context).width;
            final preview = controller.preview;

            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  right: side + padding.right,
                  bottom: bottom,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: preview == null
                            ? const SizedBox.shrink()
                            : Padding(
                                key: ValueKey(preview.message),
                                padding: const EdgeInsets.only(bottom: 10),
                                child: ChatPreviewBubble(
                                  text: previewText(preview.message),
                                  maxWidth: math.min(250, width - 2 * side),
                                  onTap: () => onOpen(preview.chat),
                                ),
                              ),
                      ),
                      ChatFloatButton(count: controller.unread, onTap: () => onOpen(chat)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
