import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/enums/role.dart';
import 'package:teamxperience/features/news_dashboard/screen/stiri_dashboard_screen.dart';
import 'package:teamxperience/model/stire.dart';
import 'package:teamxperience/model/user.dart';
import 'package:teamxperience/service/news_service/news_service.dart';
import 'package:teamxperience/state_management/news_state_management.dart';
import 'package:teamxperience/state_management/user_provider.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

class _FakeNewsService extends Fake implements NewsService {
  @override
  Future<List<Stire>> getAllStire() async => [];
}

class _FakeFirebaseUser extends Fake implements User {}

Future<void> _pump(WidgetTester tester, Role role) async {
  final users = UserProvider()
    ..setUser(
      AppUser(
        email: 'a@b.ro',
        firstName: 'Ana',
        lastName: 'Pop',
        uid: 'u1',
        role: role,
        fcmToken: '',
      ),
      _FakeFirebaseUser(),
    );
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>.value(value: users),
        ChangeNotifierProvider<NewsList>(create: (_) => NewsList(_FakeNewsService())),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const StiriDashboard()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('admins can create news', (tester) async {
    await _pump(tester, Role.ADMIN);
    expect(find.text('Creează știre'), findsOneWidget);
  });

  testWidgets('players cannot create news', (tester) async {
    await _pump(tester, Role.USER);
    expect(find.text('Creează știre'), findsNothing);
  });
}
