import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_battery_level_use_case.dart';
import '../../domain/usecases/watch_battery_use_case.dart';
import '../../../../core/utils/logger.dart';
import 'battery_event.dart';
import 'battery_state.dart';

/// Manages battery level state by reading from native platform channels.
///
/// Responds to [LoadBattery] by fetching the initial level and
/// subscribing to [WatchBatteryUseCase] for real-time updates.
class BatteryBloc extends Bloc<BatteryEvent, BatteryState> {
  static const _tag = 'BatteryBloc';

  final GetBatteryLevelUseCase _getBatteryLevel;
  final WatchBatteryUseCase _watchBattery;

  StreamSubscription<int>? _batterySubscription;

  BatteryBloc({
    required GetBatteryLevelUseCase getBatteryLevel,
    required WatchBatteryUseCase watchBattery,
  })  : _getBatteryLevel = getBatteryLevel,
        _watchBattery = watchBattery,
        super(const BatteryInitial()) {
    on<LoadBattery>(_onLoadBattery);
    on<BatteryChanged>(_onBatteryChanged);
  }

  Future<void> _onLoadBattery(
    LoadBattery event,
    Emitter<BatteryState> emit,
  ) async {
    emit(const BatteryLoading());
    try {
      final level = await _getBatteryLevel();
      emit(BatteryLoaded(level));

      await _batterySubscription?.cancel();
      _batterySubscription = _watchBattery().listen(
        (level) => add(BatteryChanged(level)),
        onError: (Object e) {
          AppLogger.error(_tag, 'Battery stream error', e);
        },
      );
    } catch (e) {
      AppLogger.error(_tag, 'LoadBattery failed', e);
      emit(BatteryError(e.toString()));
    }
  }

  void _onBatteryChanged(
    BatteryChanged event,
    Emitter<BatteryState> emit,
  ) {
    AppLogger.debug(_tag, 'Battery changed: ${event.level}%');
    emit(BatteryLoaded(event.level));
  }

  @override
  Future<void> close() {
    _batterySubscription?.cancel();
    return super.close();
  }
}
