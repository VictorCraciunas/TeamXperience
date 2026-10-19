import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';
import 'package:teamxperience/ui/components/buttons/my_button.dart';
import 'package:teamxperience/ui/components/inputs/app_text_field.dart';
import 'package:teamxperience/ui/components/inputs/my_text_field.dart';

import '../pump_ui.dart';

AppButton _button(WidgetTester tester) => tester.widget<AppButton>(find.byType(AppButton));

void main() {
  group('MyButton', () {
    testWidgets('renders an AppButton with the text and fires buttonOnTap', (tester) async {
      var taps = 0;
      await pumpUi(
        tester,
        MyButton(
          buttonText: 'Înscrie-ți echipa',
          textColor: Colors.white,
          withBorder: false,
          gradient: MyColors.myGradient,
          buttonOnTap: () => taps++,
        ),
      );
      expect(find.text('Înscrie-ți echipa'), findsOneWidget);
      await tester.tap(find.byType(AppButton));
      expect(taps, 1);
    });

    testWidgets('a gradient button becomes the primary variant', (tester) async {
      await pumpUi(
        tester,
        MyButton(
          buttonText: 'x',
          textColor: Colors.white,
          withBorder: false,
          gradient: MyColors.myGradient,
          buttonOnTap: () {},
        ),
      );
      expect(_button(tester).variant, AppButtonVariant.primary);
      expect(_button(tester).backgroundColor, isNull);
    });

    testWidgets('a bordered button without a fill becomes the secondary variant',
        (tester) async {
      await pumpUi(
        tester,
        MyButton(
          buttonText: 'x',
          textColor: const Color(0xFF0C092A),
          withBorder: true,
          buttonOnTap: () {},
        ),
      );
      expect(_button(tester).variant, AppButtonVariant.secondary);
    });

    testWidgets('theme colours map to the primary variant without an override',
        (tester) async {
      await pumpUi(
        tester,
        MyButton(
          buttonText: 'x',
          textColor: Colors.white,
          withBorder: false,
          buttonColor: MyColors.lightBlue,
          buttonOnTap: () {},
        ),
      );
      expect(_button(tester).variant, AppButtonVariant.primary);
      expect(_button(tester).backgroundColor, isNull);
    });

    testWidgets('a brand colour is passed through as an override', (tester) async {
      await pumpUi(
        tester,
        MyButton(
          buttonText: 'Logare cu Facebook',
          textColor: Colors.white,
          withBorder: false,
          buttonColor: const Color(0xFF0056B2),
          buttonOnTap: () {},
        ),
      );
      expect(_button(tester).backgroundColor, const Color(0xFF0056B2));
      expect(_button(tester).foregroundColor, Colors.white);
    });

    testWidgets('a finite buttonWidth fixes the width', (tester) async {
      await pumpUi(
        tester,
        Align(
          alignment: Alignment.topLeft,
          child: MyButton(
            buttonText: 'Adaugă',
            textColor: Colors.white,
            withBorder: false,
            gradient: MyColors.myGradient,
            buttonWidth: 270,
            buttonOnTap: () {},
          ),
        ),
      );
      expect(tester.getSize(find.byType(AppButton)).width, 270);
    });
  });

  group('MyTextField', () {
    testWidgets('shows its label and hint', (tester) async {
      await pumpUi(
        tester,
        const MyTextField(labelText: 'Nume echipă', hintText: 'Vulturii'),
      );
      expect(find.text('Nume echipă'), findsOneWidget);
      expect(find.text('Vulturii'), findsOneWidget);
    });

    testWidgets('requires a value by default with the existing Romanian message',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      await pumpUi(
        tester,
        Form(key: formKey, child: const MyTextField(labelText: 'Nume')),
      );
      expect(formKey.currentState?.validate(), isFalse);
      await tester.pump();
      await tester.pump();
      expect(find.text('Introdu Nume'), findsOneWidget);
    });

    testWidgets('does not require a value when validateRequired is false',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      await pumpUi(
        tester,
        Form(
          key: formKey,
          child: const MyTextField(labelText: 'Nume', validateRequired: false),
        ),
      );
      expect(formKey.currentState?.validate(), isTrue);
    });

    testWidgets('uses a custom validator when given', (tester) async {
      final formKey = GlobalKey<FormState>();
      await pumpUi(
        tester,
        Form(
          key: formKey,
          child: MyTextField(labelText: 'Email', validator: (_) => 'Email invalid'),
        ),
      );
      expect(formKey.currentState?.validate(), isFalse);
      await tester.pump();
      await tester.pump();
      expect(find.text('Email invalid'), findsOneWidget);
    });

    testWidgets('passes obscureText through', (tester) async {
      await pumpUi(tester, const MyTextField(labelText: 'Parola', obscureText: true));
      expect(tester.widget<AppTextField>(find.byType(AppTextField)).obscure, isTrue);
    });

    testWidgets('renders no label when labelText is null', (tester) async {
      await pumpUi(tester, const MyTextField(hintText: 'Caută'));
      expect(find.byKey(const ValueKey('app-text-field-label')), findsNothing);
    });
  });
}
