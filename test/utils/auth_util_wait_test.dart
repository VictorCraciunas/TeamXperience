import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/backend/authentication/AuthenticationRepository.dart';
import 'package:teamxperience/backend/repo/user_repo.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/state_management/user_provider.dart';
import 'package:teamxperience/utils/auth_util.dart';

class _SignedOut implements AuthenticationRepository {
  @override
  User? get authUser => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoUsers implements UserRepo {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('start-up moves on only once the logo has played', (tester) async {
    final intro = Completer<void>();
    final auth = AuthUtil(_NoUsers(), _SignedOut(), UserProvider());
    await tester.pumpWidget(MaterialApp(
      routes: {Routes.splash: (_) => const Text('splash')},
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => auth.checkUserAndRedirect(context, after: intro.future),
          child: const Text('start'),
        ),
      ),
    ));
    await tester.tap(find.text('start'));
    await tester.pumpAndSettle();
    expect(find.text('splash'), findsNothing);

    intro.complete();
    await tester.pumpAndSettle();
    expect(find.text('splash'), findsOneWidget);
  });
}
