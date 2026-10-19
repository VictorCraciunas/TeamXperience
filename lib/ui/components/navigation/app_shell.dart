import 'package:flutter/material.dart';

import 'app_bottom_nav.dart';
import 'app_nav_item.dart';
import 'shell_controller.dart';

class AppShellTab {
  const AppShellTab({required this.item, required this.builder});

  final AppNavItem item;
  final WidgetBuilder builder;
}

/// A tab shell: one body per tab (built the first time the tab is opened and
/// kept alive afterwards) and the bottom bar. The system back press returns to
/// the first tab before leaving the app.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.tabs, this.controller});

  final List<AppShellTab> tabs;
  final ShellController? controller;

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
    if (!_controller.hasVisited(tab)) return const SizedBox.shrink();
    return _bodies[tab] ??= widget.tabs[tab].builder(context);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return PopScope(
          canPop: _controller.index == 0,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _controller.handleBack();
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: IndexedStack(
              index: _controller.index,
              children: [for (var i = 0; i < widget.tabs.length; i++) _body(i)],
            ),
            bottomNavigationBar: AppBottomNav(
              currentIndex: _controller.index,
              onSelected: _controller.select,
              items: [for (final tab in widget.tabs) tab.item],
            ),
          ),
        );
      },
    );
  }
}
