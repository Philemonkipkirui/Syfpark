import 'package:geolocator/geolocator.dart';

class LocationResult {
  final Position? position;
  final bool serviceEnabled;
  final LocationPermission permission;
  final String? error; // human-readable

  const LocationResult({
    required this.position,
    required this.serviceEnabled,
    required this.permission,
    this.error,
  });
}

class LocationService {
  LocationService._();
  static final instance = LocationService._();

  Future<LocationResult> getCurrentPositionOnce() async {
    // Check service
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationResult(
        position: null,
        serviceEnabled: false,
        permission: LocationPermission.denied,
        error: 'Location services are disabled.',
      );
    }

    // Check/request permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return LocationResult(
        position: null,
        serviceEnabled: true,
        permission: permission,
        error: 'Location permission denied.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationResult(
        position: null,
        serviceEnabled: true,
        permission: permission,
        error: 'Location permission permanently denied. Enable in settings.',
      );
    }

    // One-time fetch
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    return LocationResult(
      position: pos,
      serviceEnabled: true,
      permission: permission,
      error: null,
    );
  }
}
