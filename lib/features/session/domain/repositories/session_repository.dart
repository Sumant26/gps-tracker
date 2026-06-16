import '../../../../shared/models/tracking_session.dart';
import '../../../../shared/models/location_point.dart';

/// Contract for session data access.
abstract class SessionRepository {
  /// Returns all [TrackingSession] records, newest first.
  Future<List<TrackingSession>> getAllSessions();

  /// Returns all [LocationPoint] records for the given [sessionId].
  Future<List<LocationPoint>> getSessionPoints(String sessionId);

  /// Permanently removes a session and all its location points.
  Future<void> deleteSession(String sessionId);
}
