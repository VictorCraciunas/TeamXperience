import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/features/chat/widgets/image_message_bubble.dart';
import 'package:teamxperience/features/chat/widgets/reject_photo_dialog.dart';
import 'package:teamxperience/ui/theme/app_colors.dart';

import '../../ui/pump_ui.dart';

Future<List<String?>> _open(WidgetTester tester) async {
  final results = <String?>[];
  await pumpUi(
    tester,
    Builder(
      builder: (context) => TextButton(
        onPressed: () async => results.add(await showRejectPhotoDialog(context)),
        child: const Text('deschide'),
      ),
    ),
  );
  await tester.tap(find.text('deschide'));
  await tester.pumpAndSettle();
  return results;
}

TextButton _reject(WidgetTester tester) => tester.widget<TextButton>(find.widgetWithText(TextButton, 'Respinge'));

void main() {
  testWidgets('asks for the reason the team will see', (tester) async {
    await _open(tester);
    expect(find.text('Respinge poza'), findsOneWidget);
    expect(find.text('Motivul (îl vede echipa)'), findsOneWidget);
  });

  testWidgets('"Respinge" waits for a reason, then gives it back trimmed', (tester) async {
    final results = await _open(tester);
    expect(_reject(tester).onPressed, isNull);
    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();
    expect(_reject(tester).onPressed, isNull);
    await tester.enterText(find.byType(TextField), '  Nu se vede ceasul ');
    await tester.pump();
    await tester.tap(find.text('Respinge'));
    await tester.pumpAndSettle();
    expect(results, ['Nu se vede ceasul']);
  });

  testWidgets('"Anulează" gives nothing back', (tester) async {
    final results = await _open(tester);
    await tester.tap(find.text('Anulează'));
    await tester.pumpAndSettle();
    expect(results, [null]);
  });

  testWidgets('a rejected photo in the chat shows its reason', (tester) async {
    await pumpUi(
      tester,
      const ImageMessageBubble(
        imageUrl: '',
        isMe: false,
        status: PhotoApprovalStatus.denied,
        rejectReason: 'Nu se vede ceasul',
      ),
    );
    await tester.pump();
    final reason = tester.widget<Text>(find.text('Nu se vede ceasul'));
    expect(reason.style?.color, AppColors.light.danger);
  });
}
