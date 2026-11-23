import 'package:flutter_test/flutter_test.dart';
import 'package:project_khata/core/utils/geofence_helper.dart';

void main() {
  group('GeofenceHelper Tests (Haversine & Boundary Enforcement)', () {
    // Project Site: Dhaka Motijheel (23.7330, 90.4172)
    const double siteLat = 23.7330;
    const double siteLng = 90.4172;

    test('calculateDistanceMeters returns 0 for identical points', () {
      final distance = GeofenceHelper.calculateDistanceMeters(
        startLat: siteLat,
        startLng: siteLng,
        endLat: siteLat,
        endLng: siteLng,
      );
      expect(distance, closeTo(0.0, 0.01));
    });

    test('calculateDistanceMeters calculates accurate distance for nearby points', () {
      // Offset latitude by ~0.0009 degrees (~100 meters)
      const double workerLat = 23.7339;
      const double workerLng = 90.4172;

      final distance = GeofenceHelper.calculateDistanceMeters(
        startLat: siteLat,
        startLng: siteLng,
        endLat: workerLat,
        endLng: workerLng,
      );

      // Distance should be approximately 100 meters (within 90m to 110m)
      expect(distance, greaterThan(90.0));
      expect(distance, lessThan(110.0));
    });

    test('isInsideGeofence returns true when worker is within 150m radius', () {
      // 100 meters away
      const double workerLat = 23.7339;
      const double workerLng = 90.4172;

      final isInside = GeofenceHelper.isInsideGeofence(
        userLat: workerLat,
        userLng: workerLng,
        siteLat: siteLat,
        siteLng: siteLng,
        radiusMeters: 150,
      );

      expect(isInside, isTrue);
    });

    test('isInsideGeofence returns false when worker is outside 150m radius', () {
      // Offset latitude by ~0.0025 degrees (~278 meters away)
      const double farWorkerLat = 23.7355;
      const double farWorkerLng = 90.4172;

      final isInside = GeofenceHelper.isInsideGeofence(
        userLat: farWorkerLat,
        userLng: farWorkerLng,
        siteLat: siteLat,
        siteLng: siteLng,
        radiusMeters: 150,
      );

      expect(isInside, isFalse);
    });

    test('Boundary edge test: exactly on or near the perimeter', () {
      // Distance is ~100m, radius 100m vs 90m
      const double workerLat = 23.7339;
      const double workerLng = 90.4172;

      final distance = GeofenceHelper.calculateDistanceMeters(
        startLat: siteLat,
        startLng: siteLng,
        endLat: workerLat,
        endLng: workerLng,
      );

      final isInsideWithTighterRadius = GeofenceHelper.isInsideGeofence(
        userLat: workerLat,
        userLng: workerLng,
        siteLat: siteLat,
        siteLng: siteLng,
        radiusMeters: (distance - 1).floor(),
      );
      expect(isInsideWithTighterRadius, isFalse);

      final isInsideWithLargerRadius = GeofenceHelper.isInsideGeofence(
        userLat: workerLat,
        userLng: workerLng,
        siteLat: siteLat,
        siteLng: siteLng,
        radiusMeters: (distance + 1).ceil(),
      );
      expect(isInsideWithLargerRadius, isTrue);
    });
  });
}
