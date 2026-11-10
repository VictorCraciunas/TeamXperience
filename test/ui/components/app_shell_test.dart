import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/ui/components/navigation/app_nav_item.dart';
import 'package:teamxperience/ui/components/navigation/app_shell.dart';
import 'package:teamxperience/ui/components/navigation/shell_controller.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

class _Counter extends StatefulWidget {
  const _Counter({required this.label});

  final String label;

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int taps = 0;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => setState(() => taps++),
      child: Text('${widget.label}:$taps'),
    );
  }
}

Widget _raisedShell() => MaterialApp(
      theme: AppTheme.light,
      home: AppShell(
        tabs: [
          AppShellTab(
            item: const AppNavItem(icon: Icons.home_outlined, label: 'Acasă'),
            builder: (_) => const SizedBox.expand(key: ValueKey('page')),
          ),
          AppShellTab(
            item: const AppNavItem(icon: Icons.vpn_key_outlined, label: 'Joacă', raised: true),
            builder: (_) => const SizedBox.expand(),
          ),
          AppShellTab(
            item: const AppNavItem(icon: Icons.person_outline, label: 'Profil'),
            builder: (_) => const SizedBox.expand(),
          ),
        ],
      ),
    );

Widget _shell({ShellController? controller, List<String>? builtLog}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: AppShell(
      controller: controller,
      tabs: [
        AppShellTab(
          item: const AppNavItem(icon: Icons.home_outlined, label: 'Acasă'),
          builder: (_) {
            builtLog?.add('home');
            return const _Counter(label: 'home');
          },
        ),
        AppShellTab(
          item: const AppNavItem(icon: Icons.explore_outlined, label: 'Evenimente'),
          builder: (_) {
            builtLog?.add('events');
            return const _Counter(label: 'events');
          },
        ),
      ],
    ),
  );
}

void main() {
  group('action tabs', actionTabTests);

  testWidgets('the raised tab never covers the end of a page', (tester) async {
    await tester.pumpWidget(_raisedShell());
    final page = tester.getRect(find.byKey(const ValueKey('page')));
    final circle = tester.getRect(find.byKey(const ValueKey('nav-raised-circle')));
    expect(page.bottom, lessThanOrEqualTo(circle.top));
  });

  testWidgets('shows the first tab and builds the others lazily', (tester) async {
    final log = <String>[];
    await tester.pumpWidget(_shell(builtLog: log));
    expect(find.text('home:0'), findsOneWidget);
    expect(log, ['home']);
    await tester.tap(find.text('Evenimente'));
    await tester.pump();
    expect(log, ['home', 'events']);
    expect(find.text('events:0'), findsOneWidget);
  });

  testWidgets('works with only two tabs and keeps tab state alive', (tester) async {
    await tester.pumpWidget(_shell());
    await tester.tap(find.text('home:0'));
    await tester.pump();
    expect(find.text('home:1'), findsOneWidget);

    await tester.tap(find.text('Evenimente'));
    await tester.pump();
    await tester.tap(find.text('Acasă'));
    await tester.pump();
    expect(find.text('home:1'), findsOneWidget);
  });

  testWidgets('the system back press returns to the first tab', (tester) async {
    final controller = ShellController(2);
    await tester.pumpWidget(_shell(controller: controller));
    controller.select(1);
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(controller.index, 0);
  });

  testWidgets('an external controller can switch tabs', (tester) async {
    final controller = ShellController(2);
    await tester.pumpWidget(_shell(controller: controller));
    controller.select(1);
    await tester.pump();
    expect(find.text('events:0'), findsOneWidget);
  });
}

Widget _actionShell({
  required ShellController controller,
  required VoidCallback onPlay,
  Widget? overlay,
  VoidCallback? onOverlayBack,
  bool open = false,
}) =>
    MaterialApp(
      theme: AppTheme.light,
      home: AppShell(
        controller: controller,
        overlay: overlay,
        onOverlayBack: onOverlayBack,
        tabs: [
          AppShellTab(
            item: const AppNavItem(icon: Icons.home_outlined, label: 'Acasă'),
            builder: (_) => const SizedBox.expand(key: ValueKey('home-page')),
          ),
          AppShellTab(
            item: const AppNavItem(icon: Icons.map_outlined, label: 'Evenimente'),
            builder: (_) => const SizedBox.expand(key: ValueKey('events-page')),
          ),
          AppShellTab(
            item: AppNavItem(icon: Icons.vpn_key_outlined, label: 'Joacă', raised: true, open: open),
            onTap: onPlay,
          ),
        ],
      ),
    );

void actionTabTests() {
  testWidgets('an action tab runs its callback and keeps the current page', (tester) async {
    final controller = ShellController(3);
    var taps = 0;
    await tester.pumpWidget(_actionShell(controller: controller, onPlay: () => taps++));
    await tester.tap(find.text('Joacă'));
    await tester.pump();
    expect(taps, 1);
    expect(controller.index, 0);
    expect(find.byKey(const ValueKey('home-page')), findsOneWidget);
  });

  testWidgets('the overlay covers the pages and the bar still works', (tester) async {
    final controller = ShellController(3);
    await tester.pumpWidget(_actionShell(
      controller: controller,
      onPlay: () {},
      overlay: const SizedBox.expand(key: ValueKey('overlay')),
    ));
    expect(find.byKey(const ValueKey('overlay')), findsOneWidget);
    await tester.tap(find.text('Evenimente'));
    await tester.pump();
    expect(controller.index, 1);
  });

  testWidgets('back with an overlay closes it and stays on the tab', (tester) async {
    final controller = ShellController(3)..select(1);
    var backs = 0;
    await tester.pumpWidget(_actionShell(
      controller: controller,
      onPlay: () {},
      overlay: const SizedBox.expand(),
      onOverlayBack: () => backs++,
    ));
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(backs, 1);
    expect(controller.index, 1);
  });

  testWidgets('an open raised tab shows an X', (tester) async {
    await tester.pumpWidget(_actionShell(controller: ShellController(3), onPlay: () {}, open: true));
    await tester.pumpAndSettle();
    expect(find.byIcon(TablerIcons.x), findsOneWidget);
    expect(find.byIcon(Icons.vpn_key_outlined), findsNothing);
  });
}
