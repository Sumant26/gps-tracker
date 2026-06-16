import 'package:equatable/equatable.dart';

/// Base class for all [BatteryBloc] states.
abstract class BatteryState extends Equatable {
  const BatteryState();

  @override
  List<Object?> get props => [];
}

/// The battery feature has not yet been initialised.
class BatteryInitial extends BatteryState {
  const BatteryInitial();
}

/// A battery level fetch is in progress.
class BatteryLoading extends BatteryState {
  const BatteryLoading();
}

/// The battery level has been successfully loaded.
class BatteryLoaded extends BatteryState {
  /// Battery percentage in the range 0–100.
  final int level;
  const BatteryLoaded(this.level);

  @override
  List<Object?> get props => [level];
}

/// An error occurred while reading battery information.
class BatteryError extends BatteryState {
  final String message;
  const BatteryError(this.message);

  @override
  List<Object?> get props => [message];
}
