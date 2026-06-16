import 'package:equatable/equatable.dart';
import '../../../../shared/models/tracking_session.dart';
import '../../../../shared/models/location_point.dart';

/// Base class for all [TrackingBloc] states.
abstract class TrackingState extends Equatable {
  const TrackingState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any tracking operation has been performed.
class TrackingInitial extends TrackingState {
  const TrackingInitial();
}

/// A tracking operation is in progress (starting or stopping).
class TrackingLoading extends TrackingState {
  const TrackingLoading();
}

/// A tracking session is actively recording location points.
class TrackingRunning extends TrackingState {
  final TrackingSession session;
  final List<LocationPoint> points;

  const TrackingRunning({required this.session, this.points = const []});

  TrackingRunning copyWith({
    TrackingSession? session,
    List<LocationPoint>? points,
  }) =>
      TrackingRunning(
        session: session ?? this.session,
        points: points ?? this.points,
      );

  @override
  List<Object?> get props => [session, points];
}

/// No tracking session is currently active.
class TrackingStopped extends TrackingState {
  const TrackingStopped();
}

/// An error occurred during a tracking operation.
class TrackingError extends TrackingState {
  final String message;
  const TrackingError(this.message);

  @override
  List<Object?> get props => [message];
}
