/// Coordinates as organisers paste them from Google Maps ("45.7971, 24.1520").
({double lat, double lng})? parseCoordinates(String text) {
  final parts = text.trim().split(RegExp(r'[\s,]+')).where((p) => p.isNotEmpty).toList();
  if (parts.length != 2) return null;
  final lat = double.tryParse(parts[0]);
  final lng = double.tryParse(parts[1]);
  if (lat == null || lng == null || lat.abs() > 90 || lng.abs() > 180) return null;
  return (lat: lat, lng: lng);
}

/// Where a map opens when nothing is set yet: Sibiu.
const ({double lat, double lng}) defaultPlace = (lat: 45.7983, lng: 24.1256);

/// Where the pin picker starts: the place set, else somewhere near, else
/// [defaultPlace].
({double lat, double lng}) pinStart(({double lat, double lng})? initial, ({double lat, double lng})? near) =>
    initial ?? near ?? defaultPlace;

/// "45.7971, 24.1520".
String formatCoordinates(double lat, double lng) => '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
