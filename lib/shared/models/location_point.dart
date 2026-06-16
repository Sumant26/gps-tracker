import 'package:hive/hive.dart';
import '../../config/constants/hive_constants.dart';

part 'location_point.g.dart';

/// A single captured GPS coordinate belonging to a [TrackingSession].
///
/// Stored in the [HiveConstants.locationPointBox] Hive box.
@HiveType(typeId: HiveConstants.locationPointAdapterId)
class LocationPoint extends HiveObject {
  /// Unique identifier for this point (UUID v4).
  @HiveField(0)
  final String id;

  /// The session this point belongs to.
  @HiveField(1)
  final String sessionId;

  /// WGS84 latitude in decimal degrees.
  @HiveField(2)
  final double latitude;

  /// WGS84 longitude in decimal degrees.
  @HiveField(3)
  final double longitude;

  /// Estimated horizontal accuracy in metres.
  @HiveField(4)
  final double accuracy;

  /// UTC timestamp when this coordinate was captured.
  @HiveField(5)
  final DateTime timestamp;

  LocationPoint({
    required this.id,
    required this.sessionId,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
  });

  @override
  String toString() =>
      'LocationPoint(id: $id, lat: $latitude, lon: $longitude, '
      'accuracy: ${accuracy}m)';
}
