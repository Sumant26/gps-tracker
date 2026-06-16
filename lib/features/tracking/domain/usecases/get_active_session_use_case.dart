import '../../../../shared/models/tracking_session.dart';
import '../repositories/tracking_repository.dart';

/// Returns the currently active [TrackingSession], or null if none is running.
class GetActiveSessionUseCase {
  final TrackingRepository _repository;

  const GetActiveSessionUseCase(this._repository);

  /// Executes the use case.
  Future<TrackingSession?> call() => _repository.getActiveSession();
}
