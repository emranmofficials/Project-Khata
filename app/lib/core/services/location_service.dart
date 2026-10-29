import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double? latitude;
  final double? longitude;
  final double? distanceMeters;
  final bool isInside;
  final String locationStatus; // 'inside_site', 'outside_site', 'location_unavailable'
  final String? errorMessage;

  const LocationResult({
    this.latitude,
    this.longitude,
    this.distanceMeters,
    required this.isInside,
    required this.locationStatus,
    this.errorMessage,
  });

  factory LocationResult.unavailable([String? error]) {
    return LocationResult(
      isInside: false,
      locationStatus: 'location_unavailable',
      errorMessage: error,
    );
  }
}

class LocationService {
  Future<Position?> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  Future<LocationResult> verifySiteLocation({
    required double siteLat,
    required double siteLng,
    required int geofenceRadiusMeters,
  }) async {
    final position = await getCurrentPosition();
    if (position == null) {
      return LocationResult.unavailable('লোকেশন সংগ্রহ করা সম্ভব হয়নি');
    }

    final distance = calculateDistance(
      startLatitude: siteLat,
      startLongitude: siteLng,
      endLatitude: position.latitude,
      endLongitude: position.longitude,
    );

    final isInside = distance <= geofenceRadiusMeters;

    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      distanceMeters: distance,
      isInside: isInside,
      locationStatus: isInside ? 'inside_site' : 'outside_site',
    );
  }
}

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});
