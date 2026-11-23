import 'dart:math' as math;

/// মোবাইল ক্লায়েন্ট সাইডে জিও-ফেন্স ও দূরত্ব গণনার ইউটিলিটি
class GeofenceHelper {
  static const double earthRadiusMeters = 6371000;

  /// Haversine ফর্মুলা অনুযায়ী দুটি জিপিএস অবস্থানের মধ্যকার দূরত্ব (মিটারে)
  static double calculateDistanceMeters({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    double dLat = _degreesToRadians(endLat - startLat);
    double dLng = _degreesToRadians(endLng - startLng);

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(startLat)) *
            math.cos(_degreesToRadians(endLat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  /// ব্যবহারকারীর অবস্থান সাইটের সীমানার মধ্যে কি না
  static bool isInsideGeofence({
    required double userLat,
    required double userLng,
    required double siteLat,
    required double siteLng,
    required int radiusMeters,
  }) {
    double distance = calculateDistanceMeters(
      startLat: userLat,
      startLng: userLng,
      endLat: siteLat,
      endLng: siteLng,
    );
    return distance <= radiusMeters;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }
}
