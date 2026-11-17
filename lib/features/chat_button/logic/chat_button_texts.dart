import 'package:teamxperience/enums/message_type.dart';
import 'package:teamxperience/model/message.dart';

/// "1 mesaj nou", "2 mesaje noi", "20 de mesaje noi".
String newMessagesText(int count) {
  if (count == 1) return '1 mesaj nou';
  final rest = count % 100;
  final de = count >= 20 && (rest == 0 || rest >= 20);
  return '$count ${de ? 'de ' : ''}mesaje noi';
}

String chatButtonLabel(int count) => 'Deschide chatul cu organizatorul, ${newMessagesText(count)}';

String chatBadgeText(int count) => count > 99 ? '99+' : '$count';

const previewHeader = 'Organizator · acum';

String previewText(Message message) {
  final text = message.text.trim();
  if (message.type == MessageType.image) return text.isEmpty ? 'Fotografie' : text;
  return text;
}
