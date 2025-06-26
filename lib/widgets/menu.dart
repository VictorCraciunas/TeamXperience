import 'package:flutter/material.dart';
import 'package:teamxperience/backend/repo/event_repo.dart';
import 'package:teamxperience/constants/colors.dart';

import '../constants/routes.dart';
import '../model/event.dart';

class MenuWidget extends StatelessWidget {
  final VoidCallback onClose;
  final Event? event;

  const MenuWidget({
    super.key,
    required this.onClose,
    required this.event
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          const BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMenuItem(
            context,
            'Editează evenimentul',
                () {
              onClose();
              // Navigate to edit event screen
              Navigator.pushNamed(
                context,
                Routes.createEvent,
                arguments: {'event': event, 'isBlueprint': false},
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            context,
            'Duplică eveniment',
                () {
              onClose();
              // Navigate to duplicate event screen
              Navigator.pushNamed(
                context,
                Routes.createEvent,
                arguments: {'event': event, 'isBlueprint': true},
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            context,
            'Șterge eveniment',
                () {
              onClose();
              // Show delete confirmation dialog
              _showDeleteConfirmation(context);
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            context,
            'Vezi Eveniment',
                () {
              onClose();
              // Navigate to teams screen
              Navigator.pushNamed(
                  context,
                  Routes.eventGame,
                  arguments: event
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Center(
          child: Text(
            title,
            style:  const TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              color: MyColors.blackColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: MyColors.transparentLightBlue,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Confirmare ștergere'),
          content: const Text('Ești sigur că vrei să ștergi acest eveniment?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Anulează'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleDeleteEvent(context);
              },
              child: const Text('Șterge', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _handleDeleteEvent(BuildContext context) {
    EventRepo eventRepo = EventRepo();
    eventRepo.deleteEvent(event!.eventId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Evenimentul a fost șters')),
    );
    Navigator.pop(context);
  }
}