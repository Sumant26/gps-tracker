import '../repositories/battery_repository.dart';

/// Returns the current device battery percentage.
///
/// Delegates to [BatteryRepository.getBatteryLevel].
class GetBatteryLevelUseCase {
  final BatteryRepository _repository;

  const GetBatteryLevelUseCase(this._repository);

  /// Executes the use case.
  Future<int> call() => _repository.getBatteryLevel();
}
