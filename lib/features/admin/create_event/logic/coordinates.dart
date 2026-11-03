/// Coordinates as organisers paste them from Google Maps ("45.7971, 24.1520").
({double lat, double lng})? parseCoordinates(String text) {
  final parts = text.trim().split(RegExp(r'[\s,]+')).where((p) => p.isNotEmpty).toList();
  if (parts.length != 2) return null;
  final lat = double.tryParse(parts[0]);
  final lng = double.tryParse(parts[1]);
  if (lat == null || lng == null || lat.abs() > 90 || lng.abs() > 180) return null;
  return (lat: lat, lng: lng);
}

/// "45.7971, 24.1520".
String formatCoordinates(double lat, double lng) => '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
