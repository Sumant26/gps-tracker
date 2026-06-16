import '../repositories/tracking_repository.dart';

/// Finalises an active GPS tracking session.
class StopTrackingUseCase {
  final TrackingRepository _repository;

  const StopTrackingUseCase(this._repository);

  /// Marks the session identified by [sessionId] as stopped.
  Future<void> call(String sessionId) =>
      _repository.stopSession(sessionId);
}
