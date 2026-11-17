import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:teamxperience/enums/role.dart';
import 'package:teamxperience/enums/stire_type.dart';
import 'package:teamxperience/features/news_dashboard/screen/stiri_dashboard_screen.dart';
import 'package:teamxperience/model/newsCategory.dart';
import 'package:teamxperience/model/stire.dart';
import 'package:teamxperience/model/user.dart';
import 'package:teamxperience/service/news_service/news_service.dart';
import 'package:teamxperience/state_management/news_state_management.dart';
import 'package:teamxperience/state_management/user_provider.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

class _FakeNewsService extends Fake implements NewsService {
  final deleted = <String>[];

  @override
  Future<List<Stire>> getAllStire() async => [
    Stire(
      id: 'n1',
      title: 'Noaptea Breslelor',
      description: 'Înscrieri deschise.',
      category: NewsCategory(name: 'Evenimente'),
      type: StireType.PUBLICA,
      publicationDate: DateTime(2026, 11, 14),
    ),
  ];

  @override
  Future<void> deleteStire(String id) async => deleted.add(id);
}

class _FakeFirebaseUser extends Fake implements User {}

Future<_FakeNewsService> _pump(WidgetTester tester) async {
  final service = _FakeNewsService();
  final users = UserProvider()
    ..setUser(
      AppUser(email: 'a@b.ro', firstName: 'Ana', lastName: 'Pop', uid: 'u1', role: Role.ADMIN, fcmToken: ''),
      _FakeFirebaseUser(),
    );
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>.value(value: users),
        ChangeNotifierProvider<NewsList>(create: (_) => NewsList(service)),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const StiriDashboard()),
    ),
  );
  await tester.pumpAndSettle();
  return service;
}

void main() {
  testWidgets('the trash asks first; Anulează keeps the news', (tester) async {
    final service = await _pump(tester);

    await tester.tap(find.byTooltip('Șterge știrea'));
    await tester.pumpAndSettle();
    expect(find.text('Vrei să ștergi "Noaptea Breslelor"? Nu se poate anula.'), findsOneWidget);
    expect(service.deleted, isEmpty);

    await tester.tap(find.text('Anulează'));
    await tester.pumpAndSettle();
    expect(service.deleted, isEmpty);
    expect(find.text('Noaptea Breslelor'), findsOneWidget);
  });

  testWidgets('the trash deletes the news once confirmed', (tester) async {
    final service = await _pump(tester);

    await tester.tap(find.byTooltip('Șterge știrea'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Șterge'));
    await tester.pumpAndSettle();

    expect(service.deleted, ['n1']);
    expect(find.text('Noaptea Breslelor'), findsNothing);
    expect(find.text('Știrea a fost ștearsă'), findsOneWidget);
  });
}
