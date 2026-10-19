import 'package:flutter/material.dart';
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
