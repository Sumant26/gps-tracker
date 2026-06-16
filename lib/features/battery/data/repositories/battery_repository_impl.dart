import '../../domain/repositories/battery_repository.dart';
import '../datasources/battery_data_source.dart';

/// Concrete implementation of [BatteryRepository].
///
/// Delegates all work to [BatteryDataSource] which communicates
/// with native platform channels.
class BatteryRepositoryImpl implements BatteryRepository {
  final BatteryDataSource _dataSource;

  const BatteryRepositoryImpl(this._dataSource);

  @override
  Future<int> getBatteryLevel() => _dataSource.getBatteryLevel();

  @override
  Stream<int> watchBatteryLevel() => _dataSource.watchBatteryLevel();
}
