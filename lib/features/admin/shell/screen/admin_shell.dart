import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/features/admin/home/screen/admin_home.dart';
import 'package:teamxperience/features/events_dashboard/events_dashboard_admin/screen/events_dasboard_screen.dart';
import 'package:teamxperience/features/news_dashboard/screen/stiri_dashboard_screen.dart';
import 'package:teamxperience/features/profile/screen/profile_screen.dart';
import 'package:teamxperience/ui/components/navigation/app_nav_item.dart';
import 'package:teamxperience/ui/components/navigation/app_shell.dart';
import 'package:teamxperience/ui/components/navigation/shell_controller.dart';

/// The organiser tab shell: Acasă, Evenimente, Știri and Profil.
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  static const _tabCount = 4;

  final ShellController _controller = ShellController(_tabCount);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ShellController>.value(
      value: _controller,
      child: AppShell(
        controller: _controller,
        tabs: [
          AppShellTab(
            item: const AppNavItem(icon: Icons.home_outlined, label: 'Acasă'),
            builder: (_) => const AdminHome(),
          ),
          AppShellTab(
            item: const AppNavItem(icon: Icons.explore_outlined, label: 'Evenimente'),
            builder: (_) => const EventsDashboard(),
          ),
          AppShellTab(
            item: const AppNavItem(icon: Icons.article_outlined, label: 'Știri'),
            builder: (_) => const StiriDashboard(),
          ),
          AppShellTab(
            item: const AppNavItem(icon: Icons.person_outline, label: 'Profil'),
            builder: (_) => const ProfileScreen(),
          ),
        ],
      ),
    );
  }
}
