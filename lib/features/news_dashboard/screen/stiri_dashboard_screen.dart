import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/enums/role.dart';
import 'package:teamxperience/features/news_dashboard/controller/stiri_dashboard_controller.dart';
import 'package:teamxperience/features/news_dashboard/widgets/admin_news_view.dart';
import 'package:teamxperience/features/news_dashboard/widgets/player_news_view.dart';
import 'package:teamxperience/model/stire.dart';
import 'package:teamxperience/state_management/news_state_management.dart';
import 'package:teamxperience/state_management/user_provider.dart';
import 'package:teamxperience/ui/components/feedback/app_dialog.dart';
import 'package:teamxperience/ui/components/feedback/load_failed.dart';
import 'package:teamxperience/ui/components/feedback/snackbars.dart';
import 'package:teamxperience/ui/ui.dart';

/// The Știri list: [PlayerNewsView] for players (pushed from Acasă's news),
/// [AdminNewsView] for organisers (a tab of the admin shell).
class StiriDashboard extends StatefulWidget {
  const StiriDashboard({super.key});

  @override
  State<StiriDashboard> createState() => _StiriDashboardState();
}

class _StiriDashboardState extends State<StiriDashboard> {
  late final StiriDashboardController controller = StiriDashboardController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final news = context.read<NewsList>();
      await Future.wait([news.loadStire(), controller.loadCategories()]);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool get _isAdmin => context.read<UserProvider>().currentUser?.role == Role.ADMIN;

  void _open(Stire stire) {
    Navigator.pushNamed(context, Routes.newsDetails, arguments: {'stire': stire, 'isAdmin': _isAdmin});
  }

  void _edit(Stire stire) {
    Navigator.pushNamed(context, Routes.createNews, arguments: {'stire': stire});
  }

  void _create() {
    Navigator.pushNamed(context, Routes.createNews, arguments: {'stire': null});
  }

  /// The categories screen can add categories, so they are read again after.
  Future<void> _openCategories() async {
    await Navigator.pushNamed(context, Routes.chooseNewsType);
    await controller.loadCategories(force: true);
  }

  /// A row's trash button or long press: confirm, then delete the news.
  Future<void> _deleteStire(Stire stire) async {
    final id = stire.id;
    if (id == null) return;

    final confirmed = await showAppDialog(
      context,
      title: 'Șterge știrea',
      message: 'Vrei să ștergi "${stire.title ?? 'această știre'}"? Nu se poate anula.',
      confirmLabel: 'Șterge',
      cancelLabel: 'Anulează',
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    try {
      await context.read<NewsList>().deleteStire(id);
      if (!mounted) return;
      MySnackBars.successSnackBar(context, title: 'Știrea a fost ștearsă');
    } catch (_) {
      if (!mounted) return;
      MySnackBars.errorSnackBar(context, title: 'Nu am putut șterge știrea');
    }
  }

  Widget? _status(NewsList newsList) {
    if (newsList.isLoading && newsList.stireList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (newsList.error != null && newsList.stireList.isEmpty) {
      return LoadFailed(
        message: 'Nu am putut încărca știrile.',
        onRetry: () => newsList.loadStire(forceRefresh: true),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.select<UserProvider, bool>((u) => u.currentUser?.role == Role.ADMIN);
    return Scaffold(
      backgroundColor: context.colors.page,
      body: Consumer<NewsList>(
        builder: (context, newsList, _) {
          return ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              final news = newsList.stireList;
              final now = DateTime.now();
              final status = _status(newsList);
              if (isAdmin) {
                return AdminNewsView(
                  controller: controller,
                  news: news,
                  now: now,
                  status: status,
                  onOpen: _open,
                  onEdit: _edit,
                  onDelete: _deleteStire,
                  onCreate: _create,
                  onCategories: _openCategories,
                );
              }
              return PlayerNewsView(
                controller: controller,
                news: news,
                now: now,
                status: status,
                onOpen: _open,
              );
            },
          );
        },
      ),
    );
  }
}
