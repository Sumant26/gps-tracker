import '../repositories/battery_repository.dart';

/// Provides a [Stream] of battery level updates from the native platform.
///
/// Delegates to [BatteryRepository.watchBatteryLevel].
class WatchBatteryUseCase {
  final BatteryRepository _repository;

  const WatchBatteryUseCase(this._repository);

  /// Returns a stream that emits battery percentage values (0–100)
  /// whenever the native platform reports a change.
  Stream<int> call() => _repository.watchBatteryLevel();
}
