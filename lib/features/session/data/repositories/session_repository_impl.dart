import '../../../../shared/models/tracking_session.dart';
import '../../../../shared/models/location_point.dart';
import '../../domain/repositories/session_repository.dart';
import '../../../tracking/data/datasources/tracking_local_data_source.dart';

/// Delegates to [TrackingLocalDataSource] — sessions and points share the
/// same Hive boxes, so no duplication is needed.
class SessionRepositoryImpl implements SessionRepository {
  final TrackingLocalDataSource _dataSource;

  const SessionRepositoryImpl(this._dataSource);

  @override
  Future<List<TrackingSession>> getAllSessions() async =>
      _dataSource.getAllSessions();

  @override
  Future<List<LocationPoint>> getSessionPoints(String sessionId) async =>
      _dataSource.getPointsForSession(sessionId);

  @override
  Future<void> deleteSession(String sessionId) =>
      _dataSource.deleteSession(sessionId);
}
