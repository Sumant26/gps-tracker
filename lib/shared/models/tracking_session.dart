import 'package:hive/hive.dart';
import '../../config/constants/hive_constants.dart';

part 'tracking_session.g.dart';

/// Persisted data model for a GPS tracking session.
///
/// Stored in the [HiveConstants.trackingSessionBox] Hive box.
@HiveType(typeId: HiveConstants.trackingSessionAdapterId)
class TrackingSession extends HiveObject {
  /// Unique identifier for this session (UUID v4).
  @HiveField(0)
  final String id;

  /// When the session was started.
  @HiveField(1)
  final DateTime startTime;

  /// When the session was ended. Null if the session is still active.
  @HiveField(2)
  DateTime? endTime;

  /// Whether this session is currently recording locations.
  @HiveField(3)
  bool isActive;

  /// Total number of [LocationPoint] records associated with this session.
  @HiveField(4)
  int totalLocations;

  TrackingSession({
    required this.id,
    required this.startTime,
    this.endTime,
    this.isActive = true,
    this.totalLocations = 0,
  });

  /// Returns the elapsed duration of the session.
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  @override
  String toString() =>
      'TrackingSession(id: $id, isActive: $isActive, '
      'totalLocations: $totalLocations)';
}
