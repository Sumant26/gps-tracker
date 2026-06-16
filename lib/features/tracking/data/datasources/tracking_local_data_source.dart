import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../../config/constants/hive_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/models/tracking_session.dart';
import '../../../../shared/models/location_point.dart';

/// Hive-backed local data source for tracking sessions and location points.
class TrackingLocalDataSource {
  static const _tag = 'TrackingLocalDataSource';
  final _uuid = const Uuid();

  Box<TrackingSession> get _sessionBox =>
      Hive.box<TrackingSession>(HiveConstants.trackingSessionBox);

  Box<LocationPoint> get _pointBox =>
      Hive.box<LocationPoint>(HiveConstants.locationPointBox);

  /// Creates a new [TrackingSession] with a unique ID and saves it.
  Future<TrackingSession> createSession() async {
    try {
      final session = TrackingSession(
        id: _uuid.v4(),
        startTime: DateTime.now(),
        isActive: true,
        totalLocations: 0,
      );
      await _sessionBox.put(session.id, session);
      AppLogger.info(_tag, 'Session created: ${session.id}');
      return session;
    } catch (e) {
      AppLogger.error(_tag, 'createSession failed', e);
      throw StorageException('Failed to create session: $e');
    }
  }

  /// Marks the session as inactive and sets [endTime].
  Future<void> endSession(String sessionId) async {
    try {
      final session = _sessionBox.get(sessionId);
      if (session == null) throw StorageException('Session not found: $sessionId');
      session.isActive = false;
      session.endTime = DateTime.now();
      await session.save();
      AppLogger.info(_tag, 'Session ended: $sessionId');
    } catch (e) {
      AppLogger.error(_tag, 'endSession failed', e);
      throw StorageException('Failed to end session: $e');
    }
  }

  /// Saves a [LocationPoint] and increments the parent session's counter.
  Future<void> savePoint(LocationPoint point) async {
    try {
      await _pointBox.put(point.id, point);
      final session = _sessionBox.get(point.sessionId);
      if (session != null) {
        session.totalLocations += 1;
        await session.save();
      }
      AppLogger.debug(_tag,
          'Point saved for ${point.sessionId}: ${point.latitude}, ${point.longitude}');
    } catch (e) {
      AppLogger.error(_tag, 'savePoint failed', e);
      throw StorageException('Failed to save location point: $e');
    }
  }

  /// Returns all sessions ordered newest-first.
  List<TrackingSession> getAllSessions() {
    final sessions = _sessionBox.values.toList();
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    return sessions;
  }

  /// Returns the first session where [isActive] is true, or null.
  TrackingSession? getActiveSession() {
    try {
      return _sessionBox.values
          .firstWhere((s) => s.isActive);
    } catch (_) {
      return null;
    }
  }

  /// Returns all [LocationPoint] records belonging to [sessionId].
  List<LocationPoint> getPointsForSession(String sessionId) {
    return _pointBox.values
        .where((p) => p.sessionId == sessionId)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// Deletes a session and all its associated location points.
  Future<void> deleteSession(String sessionId) async {
    try {
      await _sessionBox.delete(sessionId);
      final pointKeys = _pointBox.values
          .where((p) => p.sessionId == sessionId)
          .map((p) => p.key)
          .toList();
      await _pointBox.deleteAll(pointKeys);
      AppLogger.info(_tag, 'Session deleted: $sessionId');
    } catch (e) {
      AppLogger.error(_tag, 'deleteSession failed', e);
      throw StorageException('Failed to delete session: $e');
    }
  }
}
