/// Contract for battery data access.
///
/// Implemented in the data layer via native platform channels.
abstract class BatteryRepository {
  /// Returns the current battery level as a percentage (0–100).
  Future<int> getBatteryLevel();

  /// Emits battery level updates whenever the device battery changes.
  Stream<int> watchBatteryLevel();
}
