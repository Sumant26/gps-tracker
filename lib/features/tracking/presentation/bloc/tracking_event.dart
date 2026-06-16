import 'package:equatable/equatable.dart';
import '../../../../shared/models/location_point.dart';

/// Base class for all [TrackingBloc] events.
abstract class TrackingEvent extends Equatable {
  const TrackingEvent();

  @override
  List<Object?> get props => [];
}

/// Requests initialisation — checks for an already-active session.
class InitTracking extends TrackingEvent {
  const InitTracking();
}

/// Requests that a new GPS tracking session begin.
class StartTracking extends TrackingEvent {
  const StartTracking();
}

/// Requests that the current GPS tracking session end.
class StopTracking extends TrackingEvent {
  const StopTracking();
}

/// Emitted internally when a new [LocationPoint] is captured.
class TrackingUpdated extends TrackingEvent {
  final LocationPoint point;
  const TrackingUpdated(this.point);

  @override
  List<Object?> get props => [point];
}
