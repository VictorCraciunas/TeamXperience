import 'package:flutter/material.dart';
import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/features/chat/widgets/full_screen_image.dart';
import 'package:teamxperience/features/chat/widgets/reject_photo_dialog.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/components/feedback/app_dialog.dart';
import 'package:teamxperience/ui/components/feedback/snackbars.dart';
import 'package:teamxperience/ui/components/feedback/text_input_dialog.dart';

import '../controller/live_room_controller.dart';
import '../logic/attention_queue.dart';
import '../logic/live_board.dart';
import '../logic/live_map_points.dart';
import '../logic/live_status.dart';
import '../logic/live_texts.dart';
import '../widgets/team_sheet.dart';

/// What the live room's screens do with a tap: the dialogs, snackbars and
/// navigation around [LiveRoomController]'s work. Shared by the room, the
/// board and the big map.
class LiveRoomActions {
  const LiveRoomActions(this.context, this.controller);

  final BuildContext context;
  final LiveRoomController controller;

  void openBoard(BoardFilter filter) {
    controller.setFilter(filter);
    Navigator.pushNamed(context, Routes.liveBoard, arguments: controller);
  }

  void openBigMap() => Navigator.pushNamed(context, Routes.map, arguments: controller.event);

  void openChat(Team team) {
    Navigator.pushNamed(context, Routes.chatScreen, arguments: {'eventId': controller.event.eventId, 'team': team});
  }

  void openTeam(Team team, DateTime now) {
    final over = eventEnded(controller.event, now);
    final missions = controller.missionCount;
    final row = boardRows([team], missionCount: missions, now: now, eventOver: over).single;
    showTeamSheet(
      context,
      team: team,
      tone: pinToneOf(team, missionCount: missions, now: now, eventOver: over),
      status: boardStatusText(row, now),
      onCall: () => call(team),
      onMessage: () => openChat(team),
    );
  }

  Future<void> call(Team team) async {
    final result = await controller.callCaptain(team);
    if (!context.mounted) return;
    switch (result) {
      case CallResult.opened:
        break;
      case CallResult.noPhone:
        MySnackBars.errorSnackBar(context, title: 'Echipa nu are număr de telefon.');
      case CallResult.failed:
        MySnackBars.errorSnackBar(context, title: 'Nu am putut deschide telefonul.');
    }
  }

  void viewPhoto(PhotoAttention item) {
    final url = item.url;
    if (url == null) return;
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => FullScreenImage(imageUrl: url)));
  }

  Future<void> approve(PhotoAttention item) => _decide(item, approve: true);

  Future<void> reject(PhotoAttention item) async {
    final reason = await showRejectPhotoDialog(context);
    if (reason == null || !context.mounted) return;
    await _decide(item, approve: false, reason: reason);
  }

  Future<void> _decide(PhotoAttention item, {required bool approve, String? reason}) async {
    final result = await controller.decidePhoto(item, approve: approve, reason: reason);
    if (!context.mounted) return;
    switch (result) {
      case PhotoDecision.saved:
      case PhotoDecision.busy:
        break;
      case PhotoDecision.alreadyDecided:
        MySnackBars.errorSnackBar(context, title: 'Poza a fost deja decisă.');
      case PhotoDecision.failed:
        MySnackBars.errorSnackBar(context, title: 'Nu am putut salva decizia.');
    }
  }

  /// Asks for the text and sends it. A send that fails entirely asks again,
  /// with the text still there.
  Future<void> announce() async {
    var draft = '';
    while (true) {
      final text = await showTextInputDialog(
        context,
        title: 'Anunț',
        label: 'Mesajul pentru toate echipele',
        confirmLabel: 'Trimite',
        emptyMessage: 'Scrie un mesaj',
        initialText: draft,
      );
      if (text == null || !context.mounted) return;
      final result = await controller.announce(text);
      if (!context.mounted) return;
      switch (result) {
        case AnnounceResult.sent:
          MySnackBars.successSnackBar(context, title: 'Anunțul a fost trimis.');
          return;
        case AnnounceResult.chatsOnly:
          MySnackBars.errorSnackBar(context, title: 'Anunțul e în chat, dar notificarea n-a plecat.');
          return;
        case AnnounceResult.nothing:
          return;
        case AnnounceResult.failed:
          MySnackBars.errorSnackBar(context, title: 'Nu am putut trimite anunțul.');
          draft = text;
        case AnnounceResult.busy:
          MySnackBars.errorSnackBar(context, title: 'Un anunț se trimite deja. Încearcă peste câteva secunde.');
          draft = text;
      }
    }
  }

  Future<void> stop() async {
    final confirmed = await showAppDialog(
      context,
      title: 'Oprește evenimentul',
      message: 'Toate echipele vor vedea un mesaj că evenimentul s-a terminat. Ești sigur?',
      confirmLabel: 'Oprește',
      cancelLabel: 'Anulează',
      destructive: true,
    );
    if (!confirmed) return;
    final stopped = await controller.stop();
    if (stopped || !context.mounted) return;
    MySnackBars.errorSnackBar(context, title: 'Nu am putut opri evenimentul.');
  }
}
