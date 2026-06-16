import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gps_tracker/core/utils/logger.dart';
import '../../domain/repositories/permission_repository.dart';

// ─── Events ──────────────────────────────────────────────────────────────────

abstract class PermissionEvent extends Equatable {
  const PermissionEvent();
  @override
  List<Object?> get props => [];
}

/// Check current permission status without prompting the user.
class CheckPermissions extends PermissionEvent {
  const CheckPermissions();
}

/// Prompt the user to grant required permissions.
class RequestPermissions extends PermissionEvent {
  const RequestPermissions();
}

// ─── States ──────────────────────────────────────────────────────────────────

abstract class PermissionState extends Equatable {
  const PermissionState();
  @override
  List<Object?> get props => [];
}

class PermissionUnknown extends PermissionState {
  const PermissionUnknown();
}

/// All required permissions are granted.
class PermissionGranted extends PermissionState {
  const PermissionGranted();
}

/// One or more required permissions are missing.
class PermissionDenied extends PermissionState {
  /// True when background location is missing specifically.
  final bool isBackgroundDenied;
  const PermissionDenied({this.isBackgroundDenied = false});

  @override
  List<Object?> get props => [isBackgroundDenied];
}

// ─── BLoC ────────────────────────────────────────────────────────────────────

/// Manages the permission check / request lifecycle.
class PermissionBloc extends Bloc<PermissionEvent, PermissionState> {
  static const _tag = 'PermissionBloc';

  final CheckPermissionsUseCase _checkPermissions;
  final RequestPermissionsUseCase _requestPermissions;
  final PermissionRepository _repository;

  PermissionBloc({
    required CheckPermissionsUseCase checkPermissions,
    required RequestPermissionsUseCase requestPermissions,
    required PermissionRepository repository,
  })  : _checkPermissions = checkPermissions,
        _requestPermissions = requestPermissions,
        _repository = repository,
        super(const PermissionUnknown()) {
    on<CheckPermissions>(_onCheck);
    on<RequestPermissions>(_onRequest);
  }

  Future<void> _onCheck(
    CheckPermissions event,
    Emitter<PermissionState> emit,
  ) async {
    final granted = await _checkPermissions();
    if (granted) {
      emit(const PermissionGranted());
    } else {
      final backgroundMissing =
          !(await _repository.hasBackgroundLocationPermission());
      emit(PermissionDenied(isBackgroundDenied: backgroundMissing));
    }
    AppLogger.info(_tag, 'Permission check result: $state');
  }

  Future<void> _onRequest(
    RequestPermissions event,
    Emitter<PermissionState> emit,
  ) async {
    final granted = await _requestPermissions();
    if (granted) {
      emit(const PermissionGranted());
    } else {
      final backgroundMissing =
          !(await _repository.hasBackgroundLocationPermission());
      emit(PermissionDenied(isBackgroundDenied: backgroundMissing));
    }
    AppLogger.info(_tag, 'Permission request result: $state');
  }
}
