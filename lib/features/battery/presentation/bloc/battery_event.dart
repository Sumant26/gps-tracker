import 'package:equatable/equatable.dart';

/// Base class for all [BatteryBloc] events.
abstract class BatteryEvent extends Equatable {
  const BatteryEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers an initial battery level fetch and starts the level stream.
class LoadBattery extends BatteryEvent {
  const LoadBattery();
}

/// Emitted by the EventChannel stream when the battery level changes.
class BatteryChanged extends BatteryEvent {
  final int level;
  const BatteryChanged(this.level);

  @override
  List<Object?> get props => [level];
}
