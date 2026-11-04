import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/event.dart';
import '../model/team.dart';
import '../utils/calendar_helper.dart';

class ShareService {
  /// Opens the share sheet with plain text (an event or a news item).
  Future<void> shareText(BuildContext context, {required String subject, required String text}) async {
    try {
      await Share.share(text, subject: subject, sharePositionOrigin: _getSharePositionOrigin(context));
    } catch (_) {}
  }

  /// Shares the invite code of a team through the share sheet.
  Future<void> shareInvite(
    BuildContext context, {
    required String code,
    required String teamName,
    required String eventName,
  }) {
    return shareText(
      context,
      subject: 'Intră în echipa $teamName',
      text: 'Intră în echipa $teamName la $eventName: '
          'deschide TeamXperience → Echipe → Intră și scrie codul $code.',
    );
  }

  /// Builds the formatted message for team registration sharing
  String _buildTeamRegistrationMessage(Team team, Event event) {
    return '''Salut! Am înscris echipa "${team.name}" la evenimentul "${event.name ?? 'eveniment'}".

Detalii echipă:
👥 Nume echipă: ${team.name}
👨‍💼 Căpitan: ${team.captainName}
📧 Email: ${team.captainEmail}
📱 Telefon: ${team.phoneNumber}
👫 Membri: ${team.teamMembers}

📅 Eveniment: ${event.name ?? 'N/A'}
📍 Locație: ${event.location ?? 'N/A'}
📅 Data: ${event.dateEvent != null ? CalendarHelper.formatEventDate(event.dateEvent) : 'N/A'}

Ne vedem acolo! 🎉''';
  }

  /// Shares team registration details using the device's share sheet
  /// This allows users to choose from available apps (WhatsApp, Email, SMS, etc.)
  /// Returns true if successful, false otherwise
  Future<bool> shareTeamRegistration(Team team, Event event, BuildContext context) async {
    try {
      final message = _buildTeamRegistrationMessage(team, event);

      // Using share_plus package to show native share sheet
      await Share.share(
        message,
        subject: 'Înscriere echipă - ${event.name ?? 'Eveniment'}',
        sharePositionOrigin: _getSharePositionOrigin(context),
      );

      // Share.share() doesn't reliably indicate success/failure across platforms
      // so we assume success if no exception is thrown
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Shares team registration details via WhatsApp directly
  /// Returns true if successful, false otherwise
  Future<bool> shareToWhatsApp(Team team, Event event, BuildContext context) async {
    try {
      final message = _buildTeamRegistrationMessage(team, event);
      final encodedMessage = Uri.encodeComponent(message);

      // WhatsApp URL scheme
      final whatsappUrl = 'https://wa.me/?text=$encodedMessage';
      final uri = Uri.parse(whatsappUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Shares team registration details via Email
  /// Returns true if successful, false otherwise
  Future<bool> shareToEmail(Team team, Event event, BuildContext context) async {
    try {
      final message = _buildTeamRegistrationMessage(team, event);
      final subject = Uri.encodeComponent('Înscriere echipă - ${event.name ?? 'Eveniment'}');
      final body = Uri.encodeComponent(message);

      // Email URL scheme
      final emailUrl = 'mailto:?subject=$subject&body=$body';
      final uri = Uri.parse(emailUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Shares team registration details via SMS
  /// Returns true if successful, false otherwise
  Future<bool> shareToSMS(Team team, Event event, BuildContext context) async {
    try {
      final message = _buildTeamRegistrationMessage(team, event);
      final encodedMessage = Uri.encodeComponent(message);

      // SMS URL scheme
      final smsUrl = 'sms:?body=$encodedMessage';
      final uri = Uri.parse(smsUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Shows a bottom sheet with sharing options
  /// Returns a callback function that handles the sharing result
  void showShareOptions(Team team, Event event, BuildContext context, {Function(bool success, String method)? onShareResult}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Partajează înscrierea echipei',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.share, color: Colors.blue),
                    title: const Text('Partajează cu orice aplicație'),
                    subtitle: const Text('Alege din aplicațiile disponibile'),
                    onTap: () async {
                      Navigator.pop(context);
                      final success = await shareTeamRegistration(team, event, context);
                      onShareResult?.call(success, 'general');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.chat, color: Colors.green),
                    title: const Text('WhatsApp'),
                    subtitle: const Text('Partajează direct pe WhatsApp'),
                    onTap: () async {
                      Navigator.pop(context);
                      final success = await shareToWhatsApp(team, event, context);
                      onShareResult?.call(success, 'whatsapp');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.email, color: Colors.red),
                    title: const Text('Email'),
                    subtitle: const Text('Trimite prin email'),
                    onTap: () async {
                      Navigator.pop(context);
                      final success = await shareToEmail(team, event, context);
                      onShareResult?.call(success, 'email');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.sms, color: Colors.orange),
                    title: const Text('SMS'),
                    subtitle: const Text('Trimite prin SMS'),
                    onTap: () async {
                      Navigator.pop(context);
                      final success = await shareToSMS(team, event, context);
                      onShareResult?.call(success, 'sms');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Gets the share position origin for better UX on tablets
  Rect? _getSharePositionOrigin(BuildContext context) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    return box != null ? box.localToGlobal(Offset.zero) & box.size : null;
  }
}