import '../../../../shared/models/tracking_session.dart';
import '../repositories/tracking_repository.dart';

/// Creates a new GPS tracking session and returns it.
///
/// The native foreground service (Android) / background location
/// manager (iOS) should be started by the caller after this succeeds.
class StartTrackingUseCase {
  final TrackingRepository _repository;

  const StartTrackingUseCase(this._repository);

  /// Executes the use case and returns the newly created [TrackingSession].
  Future<TrackingSession> call() => _repository.startSession();
}
