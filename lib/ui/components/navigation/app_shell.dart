import 'package:flutter/material.dart';

import 'app_bottom_nav.dart';
import 'app_nav_item.dart';
import 'shell_controller.dart';

class AppShellTab {
  const AppShellTab({required this.item, this.builder, this.onTap})
      : assert((builder == null) != (onTap == null), 'A tab has either a page or an action');

  final AppNavItem item;

  /// The tab's page.
  final WidgetBuilder? builder;

  /// An action tab: tapping it runs this and keeps the current page.
  final VoidCallback? onTap;
}

/// A tab shell: one body per tab (built the first time the tab is opened and
/// kept alive afterwards) and the bottom bar. The system back press returns to
/// the first tab before leaving the app.
///
/// An [overlay] is drawn over the pages but under the bar, so the bar stays
/// usable; while it is shown, the back press calls [onOverlayBack] instead.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.tabs, this.controller, this.overlay, this.onOverlayBack});

  final List<AppShellTab> tabs;
  final ShellController? controller;
  final Widget? overlay;
  final VoidCallback? onOverlayBack;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final ShellController _controller =
      widget.controller ?? ShellController(widget.tabs.length);
  late final List<Widget?> _bodies = List.filled(widget.tabs.length, null);

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  Widget _body(int tab) {
    final builder = widget.tabs[tab].builder;
    if (builder == null || !_controller.hasVisited(tab)) return const SizedBox.shrink();
    return _bodies[tab] ??= builder(context);
  }

  void _tap(int tab) {
    final action = widget.tabs[tab].onTap;
    if (action != null) {
      action();
    } else {
      _controller.select(tab);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final raised = widget.tabs.any((tab) => tab.item.raised);
        final overlay = widget.overlay;
        final pages = IndexedStack(
          index: _controller.index,
          children: [for (var i = 0; i < widget.tabs.length; i++) _body(i)],
        );
        return PopScope(
          canPop: _controller.index == 0 && overlay == null,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            if (overlay != null) {
              widget.onOverlayBack?.call();
            } else {
              _controller.handleBack();
            }
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            // A raised tab sticks up above the bar: the pages end above it, so
            // their last row is never under it.
            body: Padding(
              padding: EdgeInsets.only(bottom: raised ? AppBottomNav.raisedRise : 0),
              child: overlay == null ? pages : Stack(fit: StackFit.expand, children: [pages, overlay]),
            ),
            bottomNavigationBar: AppBottomNav(
              currentIndex: _controller.index,
              onSelected: _tap,
              items: [for (final tab in widget.tabs) tab.item],
            ),
          ),
        );
      },
    );
  }
}
