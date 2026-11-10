import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:provider/provider.dart';

import 'package:teamxperience/constants/routes.dart';
import 'package:teamxperience/model/event.dart';
import 'package:teamxperience/state_management/events_state_management.dart';

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
        color: context.colors.panel,
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
          _buildDivider(context),
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
          _buildDivider(context),
          _buildMenuItem(
            context,
            'Șterge eveniment',
                () {
              onClose();
              // Show delete confirmation dialog
              _showDeleteConfirmation(context);
            },
          ),
          _buildDivider(context),
          _buildMenuItem(
            context,
            'Vezi Eveniment',
                () {
              onClose();
              // Navigate to teams screen
              Navigator.pushNamed(
                  context,
                  Routes.eventGame,
                  arguments:{
                    'event' : event
                  }
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
            style:  TextStyle(
              fontSize: 18,
              color: context.colors.text,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 1,
      color: context.colors.iconButtonBg,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: context.colors.panel,
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
              child: Text('Șterge', style: TextStyle(color: context.colors.danger)),
            ),
          ],
        );
      },
    );
  }

  void _handleDeleteEvent(BuildContext context) {
    final eventList = context.read<EventList>();
    eventList.deleteEvent(event!.eventId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Evenimentul a fost șters')),
    );
    Navigator.pop(context);
  }
}