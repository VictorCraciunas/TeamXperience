import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/features/chat/controller/chat_controller.dart';
import 'package:teamxperience/model/team.dart';

Team _team() => Team(name: 'Vulpile', teamMembers: '', captainName: '', phoneNumber: '', captainEmail: '');

void main() {
  testWidgets('approving and rejecting keep the photo\'s picture', (tester) async {
    await tester.pumpWidget(const SizedBox());
    final writes = <(String, PhotoApprovalStatus, String?, String?)>[];
    final controller = ChatController(
      'e1',
      _team(),
      tester.element(find.byType(SizedBox)),
      writeApproval: (key, status, {reason, url}) async => writes.add((key, status, reason, url)),
    );
    await controller.approvePhoto(_team(), '2_0_1', url: 'https://x/p.jpg');
    await controller.denyPhoto(_team(), '2_0_2', '  Nu se vede ceasul ', url: 'https://x/q.jpg');
    expect(writes, [
      ('2_0_1', PhotoApprovalStatus.approved, null, 'https://x/p.jpg'),
      ('2_0_2', PhotoApprovalStatus.denied, 'Nu se vede ceasul', 'https://x/q.jpg'),
    ]);
  });
}
