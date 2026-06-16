import '../../../../shared/models/tracking_session.dart';
import '../../../../shared/models/location_point.dart';
import '../repositories/session_repository.dart';

/// Returns all stored [TrackingSession] records ordered newest-first.
class GetAllSessionsUseCase {
  final SessionRepository _repository;
  const GetAllSessionsUseCase(this._repository);

  Future<List<TrackingSession>> call() => _repository.getAllSessions();
}

/// Returns all [LocationPoint] records for a specific session.
class GetSessionPointsUseCase {
  final SessionRepository _repository;
  const GetSessionPointsUseCase(this._repository);

  Future<List<LocationPoint>> call(String sessionId) =>
      _repository.getSessionPoints(sessionId);
}

/// Permanently deletes a session and all its associated location points.
class DeleteSessionUseCase {
  final SessionRepository _repository;
  const DeleteSessionUseCase(this._repository);

  Future<void> call(String sessionId) =>
      _repository.deleteSession(sessionId);
}
