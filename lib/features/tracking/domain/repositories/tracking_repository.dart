import '../../../../shared/models/tracking_session.dart';
import '../../../../shared/models/location_point.dart';

/// Contract for tracking data operations.
///
/// Implemented in the data layer with Hive persistence and
/// native foreground service communication.
abstract class TrackingRepository {
  /// Creates and persists a new [TrackingSession], returning it.
  Future<TrackingSession> startSession();

  /// Marks the session identified by [sessionId] as complete.
  Future<void> stopSession(String sessionId);

  /// Appends a [LocationPoint] to the given session and
  /// increments [TrackingSession.totalLocations].
  Future<void> saveLocationPoint(LocationPoint point);

  /// Returns the currently active session, or null if none exists.
  Future<TrackingSession?> getActiveSession();

  /// Emits [LocationPoint] objects as they are captured by the
  /// native background service.
  Stream<LocationPoint> watchLocationPoints(String sessionId);
}
