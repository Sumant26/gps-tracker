/// Hive box and type adapter ID constants.
class HiveConstants {
  HiveConstants._();

  static const String trackingSessionBox = 'tracking_sessions';
  static const String locationPointBox = 'location_points';

  /// Hive type adapter IDs — must be unique across the entire project.
  static const int trackingSessionAdapterId = 0;
  static const int locationPointAdapterId = 1;
}
