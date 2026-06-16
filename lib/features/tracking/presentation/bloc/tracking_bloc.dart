import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/start_tracking_use_case.dart';
import '../../domain/usecases/stop_tracking_use_case.dart';
import '../../domain/usecases/get_active_session_use_case.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/models/location_point.dart';
import 'tracking_event.dart';
import 'tracking_state.dart';

/// Manages GPS tracking lifecycle: start, stop, and live location updates.
class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  static const _tag = 'TrackingBloc';

  final StartTrackingUseCase _startTracking;
  final StopTrackingUseCase _stopTracking;
  final GetActiveSessionUseCase _getActiveSession;

  TrackingBloc({
    required StartTrackingUseCase startTracking,
    required StopTrackingUseCase stopTracking,
    required GetActiveSessionUseCase getActiveSession,
  })  : _startTracking = startTracking,
        _stopTracking = stopTracking,
        _getActiveSession = getActiveSession,
        super(const TrackingInitial()) {
    on<InitTracking>(_onInit);
    on<StartTracking>(_onStart);
    on<StopTracking>(_onStop);
    on<TrackingUpdated>(_onUpdated);
  }

  Future<void> _onInit(
    InitTracking event,
    Emitter<TrackingState> emit,
  ) async {
    final session = await _getActiveSession();
    if (session != null) {
      AppLogger.info(_tag, 'Resuming active session ${session.id}');
      emit(TrackingRunning(session: session));
    } else {
      emit(const TrackingStopped());
    }
  }

  Future<void> _onStart(
    StartTracking event,
    Emitter<TrackingState> emit,
  ) async {
    emit(const TrackingLoading());
    try {
      final session = await _startTracking();
      AppLogger.info(_tag, 'Session started: ${session.id}');
      emit(TrackingRunning(session: session));
    } catch (e) {
      AppLogger.error(_tag, 'StartTracking failed', e);
      emit(TrackingError(e.toString()));
    }
  }

  Future<void> _onStop(
    StopTracking event,
    Emitter<TrackingState> emit,
  ) async {
    final current = state;
    if (current is! TrackingRunning) return;

    emit(const TrackingLoading());
    try {
      await _stopTracking(current.session.id);
      AppLogger.info(_tag, 'Session stopped: ${current.session.id}');
      emit(const TrackingStopped());
    } catch (e) {
      AppLogger.error(_tag, 'StopTracking failed', e);
      emit(TrackingError(e.toString()));
    }
  }

  void _onUpdated(
    TrackingUpdated event,
    Emitter<TrackingState> emit,
  ) {
    final current = state;
    if (current is TrackingRunning) {
      final updatedPoints = List<LocationPoint>.from(current.points)
        ..add(event.point);
      emit(current.copyWith(points: updatedPoints));
    }
  }
}
