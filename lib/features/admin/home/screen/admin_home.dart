import 'package:flutter/material.dart';
import 'package:teamxperience/constants/routes.dart';
import '../../../../backend/authentication/AuthenticationRepository.dart';
import '../../../../model/event.dart';
import '../../../../widgets/event_card.dart';
import '../controller/admin_controller.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  late AdminHomeController controller;
  final AuthenticationRepository authenticationRepository = AuthenticationRepository();

  @override
  void initState() {
    super.initState();
    controller = AdminHomeController();

    // Set the callback to trigger setState
    controller.setStateCallback(() {
      if (mounted) {
        setState(() {
          // UI will rebuild because setState is called
        });
      }
    });

    // Load events when the page initializes
    controller.loadEvents();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _logout() {
    authenticationRepository.logout();
    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.splash,
          (Route<dynamic> route) => false,
    );
  }

  void _navigateToCreateEvent({Event? event}) {
    Navigator.pushNamed(
      context,
      Routes.createEvent,
      arguments: {'event': event, 'isBlueprint': true},
    );
  }

  void _navigateToEventDetails(Event event){
    Navigator.pushNamed(context, Routes.eventDetails,arguments: event);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Home"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshEvents,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateEvent(),
        child: const Icon(Icons.add),
        tooltip: 'Create New Event',
      ),
    );
  }

  Widget _buildBody() {
    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (controller.errorMessage != null) {
      return _buildErrorState();
    }

    if (controller.events.isEmpty) {
      return _buildEmptyState();
    }

    return _buildEventsList();
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            controller.errorMessage!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.red[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.refreshEvents,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No events found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first event to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToCreateEvent(),
            icon: const Icon(Icons.add),
            label: const Text('Create Event'),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    return RefreshIndicator(
      onRefresh: controller.refreshEvents,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: controller.events.length,
        itemBuilder: (context, index) {
          final event = controller.events[index];
          return EventCard(
            event: event,
            onTap: () => _navigateToEventDetails(event),
          );
        },
      ),
    );
  }
}