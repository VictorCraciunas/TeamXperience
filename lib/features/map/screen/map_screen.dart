import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:teamxperience/features/map/controller/map_controller.dart';
import 'package:teamxperience/model/team.dart';
import 'package:teamxperience/ui/components/navigation/my_appbar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MyMapController controller;
  final MapController _mapController = MapController();


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments =
    ModalRoute
        .of(context)!
        .settings
        .arguments as Map<String, dynamic>;
    final eventId = arguments['eventId'] as String;
    final teams = arguments['teams'] as Stream<List<Team>>;
    controller = MyMapController(teams: teams, eventId:eventId, context: context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: MyAppBar(appBarText: "Harta evenimentului"),
      body: StreamBuilder<List<Team>>(
        stream: controller.teams,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final teams = snapshot.data ?? [];

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(45.7833, 24.15),
              initialZoom: 15.0,
              maxZoom: 18.0,
              minZoom: 5.0,
            ),
            children: [
              // Map tiles layer
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.flutter_map_test',
              ),

              // Team markers layer
              MarkerLayer(
                markers: _buildAllMarkers(teams),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Marker> _buildAllMarkers(List<Team> teams) {
    List<Marker> markers = [];

    // Add team member markers
    markers.addAll(_buildTeamMarkers(teams));

    return markers;
  }

  List<Marker> _buildTeamMarkers(List<Team> teams) {
    return teams.map((member) {
      return Marker(
        point: LatLng(member.latitude, member.longitude),
        width: 60,
        height: 60,
        child: GestureDetector(
          onTap: () => _showMemberDetails(member),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.green,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: context.colors.panel,
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: context.colors.accent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    member.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Position? _currentPosition;

  void _showMemberDetails(Team team) {
    double? distance;
    if (_currentPosition != null) {
      distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        team.latitude,
        team.longitude,
      );
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: context.colors.accent,
              child: Text(
                team.name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              team.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              team.captainName,
              style: TextStyle(
                fontSize: 16,
                color: context.colors.muted,
              ),
            ),
            const SizedBox(height: 8),
            if (distance != null) ...[
              const SizedBox(height: 8),
              Text(
                'Distance: ${distance < 1000 ? '${distance.toInt()}m' : '${(distance / 1000).toStringAsFixed(1)}km'}',
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.muted,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    controller.callTeam(team);

                  },
                  icon: const Icon(Icons.phone),
                  label: const Text('Call'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    controller.navigateToChat(team);
                  },
                  icon: const Icon(Icons.message),
                  label: const Text('Message'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}