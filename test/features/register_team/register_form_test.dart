import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/features/register_team/widgets/consent_row.dart';
import 'package:teamxperience/features/register_team/widgets/register_form.dart';
import 'package:teamxperience/ui/components/buttons/navy_button.dart';
import 'package:teamxperience/ui/components/feedback/field_status_line.dart';
import 'package:teamxperience/ui/components/inputs/size_picker.dart';

import '../../ui/pump_ui.dart';

Widget _form({
  TextEditingController? name,
  TextEditingController? phone,
  FieldStatus status = FieldStatus.neutral,
  String statusText = '',
  int sizeMin = 2,
  int sizeMax = 6,
  int size = 4,
  ValueChanged<int>? onSize,
  bool rules = false,
  bool data = false,
  bool photo = false,
  ValueChanged<bool>? onRules,
  ValueChanged<bool>? onData,
  ValueChanged<bool>? onPhoto,
  VoidCallback? onSubmit,
  bool sending = false,
  bool locked = false,
}) {
  return SingleChildScrollView(
    child: RegisterForm(
      nameController: name ?? TextEditingController(),
      phoneController: phone ?? TextEditingController(),
      onNameChanged: (_) {},
      onPhoneChanged: (_) {},
      nameStatus: status,
      nameStatusText: statusText,
      sizeMin: sizeMin,
      sizeMax: sizeMax,
      size: size,
      onSizeChanged: onSize ?? (_) {},
      rulesAccepted: rules,
      onRulesChanged: onRules ?? (_) {},
      dataAccepted: data,
      onDataChanged: onData ?? (_) {},
      photoConsent: photo,
      onPhotoChanged: onPhoto ?? (_) {},
      onSubmit: onSubmit,
      sending: sending,
      locked: locked,
    ),
  );
}

const _rules = 'Sunt de acord cu Regulamentul Specific al activității.';
const _data = 'Sunt de acord cu folosirea datelor cu caracter personal.';
const _photo = 'Sunt de acord ca imaginile și video-urile care sunt realizate de organizatori sau de membrii echipei mele în timpul activității să îmi fie trimise după eveniment. În același timp ASOCIAȚIA VBE SIBIU poate folosi aceste resurse pentru promovare.';

NavyButton _button(WidgetTester tester) =>
    tester.widget<NavyButton>(find.byType(NavyButton));

void main() {
  testWidgets('three consents, with the organiser\'s texts', (tester) async {
    bool? data;
    await pumpUi(tester, _form(onData: (v) => data = v));
    for (final text in [_rules, _data, _photo]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    await tester.tap(find.text(_data));
    expect(data, isTrue);
  });

  testWidgets('each consent is easy to tap, with room between them', (tester) async {
    await pumpUi(tester, _form());
    final rows = find.byType(ConsentRow);
    expect(rows, findsNWidgets(3));
    for (var i = 0; i < 3; i++) {
      expect(tester.getSize(rows.at(i)).height, greaterThanOrEqualTo(44));
    }
    for (var i = 1; i < 3; i++) {
      expect(tester.getRect(rows.at(i)).top - tester.getRect(rows.at(i - 1)).bottom, greaterThanOrEqualTo(8));
    }
    expect(tester.getSize(find.byKey(const ValueKey('consent-box')).first).width, greaterThanOrEqualTo(22));
  });

  testWidgets('shows the copy of mockup 04', (tester) async {
    await pumpUi(
      tester,
      _form(status: FieldStatus.ok, statusText: 'Numele e liber'),
    );
    expect(find.text('Numele echipei'), findsOneWidget);
    expect(find.text('Numele e liber'), findsOneWidget);
    expect(find.text('Câți veți fi?'), findsOneWidget);
    expect(find.text('Telefonul căpitanului'), findsOneWidget);
    expect(find.text('0722 123 456'), findsOneWidget);
    expect(
      find.text('Numele și emailul le luăm din contul tău.'),
      findsOneWidget,
    );
    expect(find.text(_rules), findsOneWidget);
    expect(find.text(_photo), findsOneWidget);
    expect(find.text('Înscrie echipa'), findsOneWidget);
    expect(find.byIcon(TablerIcons.paw), findsOneWidget);
  });

  testWidgets('the check shows in the name field only when the name is ok', (
    tester,
  ) async {
    await pumpUi(tester, _form());
    expect(find.byIcon(TablerIcons.circle_check), findsNothing);
    await pumpUi(
      tester,
      _form(status: FieldStatus.ok, statusText: 'Numele e liber'),
    );
    // One in the field, one in the status line.
    expect(find.byIcon(TablerIcons.circle_check), findsNWidgets(2));
  });

  testWidgets('the size picker runs from the event minimum to its maximum', (
    tester,
  ) async {
    await pumpUi(tester, _form(sizeMin: 2, sizeMax: 6));
    final picker = tester.widget<SizePicker>(find.byType(SizePicker));
    expect((picker.min, picker.max, picker.value), (2, 6, 4));
    for (final n in [2, 3, 4, 5, 6]) {
      expect(find.text('$n'), findsOneWidget);
    }
    expect(find.text('1'), findsNothing);
    expect(find.text('7'), findsNothing);
  });

  testWidgets('picking a size reports it', (tester) async {
    int? picked;
    await pumpUi(tester, _form(onSize: (n) => picked = n));
    await tester.tap(find.text('5'));
    expect(picked, 5);
  });

  testWidgets('the button is disabled while there is no onSubmit', (
    tester,
  ) async {
    await pumpUi(tester, _form());
    expect(_button(tester).onPressed, isNull);
  });

  testWidgets('the button calls onSubmit when it is given', (tester) async {
    var submitted = 0;
    await pumpUi(tester, _form(onSubmit: () => submitted++));
    await tester.ensureVisible(find.text('Înscrie echipa'));
    await tester.pump();
    await tester.tap(find.text('Înscrie echipa'));
    expect(submitted, 1);
  });

  testWidgets('while sending the button shows a spinner and does not submit', (
    tester,
  ) async {
    var submitted = 0;
    await pumpUi(tester, _form(onSubmit: () => submitted++, sending: true));
    expect(_button(tester).isLoading, isTrue);
    await tester.tap(find.byType(NavyButton));
    expect(submitted, 0);
  });

  testWidgets('the consent rows toggle and report the new value', (
    tester,
  ) async {
    bool? rules;
    bool? photo;
    await pumpUi(
      tester,
      _form(onRules: (v) => rules = v, onPhoto: (v) => photo = v, photo: true),
    );
    await tester.tap(find.text(_rules));
    expect(rules, isTrue);
    await tester.ensureVisible(find.text(_photo));
    await tester.pump();
    await tester.tap(find.text(_photo));
    expect(photo, isFalse);
  });

  testWidgets(
    'a ticked consent shows a check',
    (tester) async {
      await pumpUi(tester, _form(rules: true));
      expect(find.byIcon(TablerIcons.check), findsOneWidget);
    },
  );

  testWidgets('typing in the fields fills their controllers', (tester) async {
    final name = TextEditingController();
    final phone = TextEditingController();
    await pumpUi(tester, _form(name: name, phone: phone));
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Vulpile');
    await tester.enterText(fields.at(1), '0722 123 456');
    expect(name.text, 'Vulpile');
    expect(phone.text, '0722 123 456');
  });

  testWidgets('the phone field opens the phone keyboard', (tester) async {
    await pumpUi(tester, _form());
    final phone = tester.widget<TextField>(find.byType(TextField).at(1));
    expect(phone.keyboardType, TextInputType.phone);
  });

  testWidgets('locked: no button, fields and consents cannot be changed', (
    tester,
  ) async {
    bool? rules;
    await pumpUi(
      tester,
      _form(locked: true, rules: true, onRules: (v) => rules = v),
    );
    expect(find.byType(NavyButton), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField).at(0)).readOnly,
      isTrue,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).readOnly,
      isTrue,
    );
    await tester.tap(find.text(_rules));
    expect(rules, isNull);
  });

  testWidgets('lays out at 320 wide and 1.3x text without an exception', (
    tester,
  ) async {
    await pumpUi(
      tester,
      _form(
        status: FieldStatus.problem,
        statusText: 'Numele are 2–30 de litere, fără /',
      ),
      width: 320,
      textScale: 1.3,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('while sending, the fields and pickers ignore the user', (
    tester,
  ) async {
    final name = TextEditingController();
    int? picked;
    var rules = 0;
    var photo = 0;
    await pumpUi(
      tester,
      _form(
        name: name,
        sending: true,
        onSize: (n) => picked = n,
        onRules: (_) => rules++,
        onPhoto: (_) => photo++,
      ),
    );
    await tester.enterText(find.byType(EditableText).first, 'Vulpile');
    expect(name.text, isEmpty);
    await tester.tap(find.text('5'));
    await tester.tap(find.text(_rules));
    await tester.tap(find.text(_photo));
    expect((picked, rules, photo), (null, 0, 0));
  });
}
