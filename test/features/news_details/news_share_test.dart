import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/feed/logic/post_text.dart';
import 'package:teamxperience/features/news_details/news_screen.dart';
import 'package:teamxperience/model/stire.dart';
import 'package:teamxperience/ui/theme/app_theme.dart';

void main() {
  testWidgets('the share button shares the news like the list does', (tester) async {
    final stire = Stire(
      title: 'Rezultate',
      description: 'Vulturii au câștigat.',
      publicationDate: DateTime(2026, 11, 14),
    );
    final shared = <(String, String)>[];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: (_) => MaterialPageRoute(
          settings: RouteSettings(arguments: {'stire': stire, 'isAdmin': false}),
          builder: (_) => NewsScreen(
            share: (context, {required subject, required text}) => shared.add((subject, text)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final button = find.bySemanticsLabel('Distribuie');
    expect(button, findsOneWidget);
    expect(tester.getSize(button), const Size(44, 44));

    await tester.tap(button);
    expect(shared, [(newsShareSubject(stire), newsShareText(stire))]);
    expect(shared.single.$2, contains('Vulturii au câștigat.'));
  });
}
